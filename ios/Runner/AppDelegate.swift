import UIKit
import Flutter
import SwiftAudio
import MediaPlayer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    // https://github.com/jorgenhenrichsen/SwiftAudio
    var player: AudioPlayer = AudioPlayer()
    var audioItem: AudioItem!
    var audioCtlChannel: FlutterMethodChannel!
    var action: String!
    var selection: Int = 0
    var stations: [[String: String]]!

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.player.event.stateChange.addListener(self, self.handleAudioPlayerStateChange)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetooth])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        player.remoteCommands=[.play, .pause, .next, .previous]
        player.remoteCommandController.handleNextTrackCommand = { (event) in
            self.playTrack(next: true)
            return .success
        }
        player.remoteCommandController.handlePreviousTrackCommand = { (event) in
            self.playTrack(next: false)
            return .success
        }
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        self.audioCtlChannel = FlutterMethodChannel(name: "com.zindolla.radio_amoris/audio",
                                                   binaryMessenger: controller.binaryMessenger)
        audioCtlChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            self?.action = call.method
            switch self?.action{
            case "create":
                self?.player.stop()
                guard let args = call.arguments else {
                    return
                }
                if let myArgs = args as? [String: Any],
                    let selection = myArgs["selection"] as? Int,
                    let stations = myArgs["stations"] as? [[String: String]] {
                    guard stations.indices.contains(selection),
                        stations[selection]["url"] != nil else {
                            print("setMethodCallHandler error : malformed 'create' request data")
                            return
                    }
                    self?.selection = selection
                    self?.stations = stations
                    self?.playSelecton()
                } else {
                    result("iOS could not extract flutter arguments in method: (sendParams)")
                }
                
                break
            case "pause":
                self?.player.pause()
                break
            case "resume":
                self?.player.play()
                break
            case "destroy":
                self?.player.stop()
                result("audio.onDestroy")
                break
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayerState) {
        var notifyState = "audio.onError"
        switch(state){
        case AudioPlayerState.playing:
            notifyState = self.action == "resume" ? "audio.onResume" : "audio.onCreate"
            self.audioCtlChannel.invokeMethod(notifyState, arguments: 0)
            break
        case AudioPlayerState.paused:
            notifyState = "audio.onPause"
            self.audioCtlChannel.invokeMethod(notifyState, arguments: 0)
            break
        default:
            break
        }

        print("handleAudioPlayerStateChange: \(state)")
    }
    
    func playSelecton(){
        let url = stations[selection]["url"]!
        let description = stations[selection]["descr"]!
        //     public init(audioUrl: String, artist: String? = nil, title: String? = nil, albumTitle: String? = nil, sourceType: SourceType, artwork: UIImage? = nil) {
        audioItem = DefaultAudioItem(audioUrl: url,
                                     artist: "Radio Anima Amoris",
                                     title: description,
                                     sourceType: .stream,
                                     artwork: UIImage(named: "LockedScr"))
        do {
            try player.load(item: audioItem, playWhenReady: true)
            player.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(true))
        } catch {
            print("The stream could not be loaded")
        }
    }
    
    func playTrack(next: Bool){
        selection += next ? 1 : -1
        if selection >= stations.count {
            selection = 0
        } else if selection < 0 {
            selection = stations.count - 1
        }
        playSelecton()
    }
}
