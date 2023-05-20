import UIKit
import Flutter
import SwiftAudio
import MediaPlayer

let CURR_PLAYING_STREAM_CHANNEL = "com.zindolla.radioamoris/currently-playing"
let PLAYLIST_CTRL_STREAM_CHANNEL = "com.zindolla.radioamoris/playlist-ctrl"
let MAIN_METHOD_CHANNEL = "com.zindolla.radioamoris/audio"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    // https://github.com/jorgenhenrichsen/SwiftAudio
    var player: AudioPlayer = AudioPlayer()
    var audioItem: AudioItem!
    var audioCtlChannel: FlutterMethodChannel!
    var action: String!
    
    var id: Int!
    var url: String!
    var name: String!
    var assetLogo: String!
    var logo: String!

    var playlistCtrlEvent: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.playlistCtrlEvent = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.playlistCtrlEvent =  nil
        return nil
    }

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
        self.audioCtlChannel = FlutterMethodChannel(name: MAIN_METHOD_CHANNEL,
                                                   binaryMessenger: controller.binaryMessenger)
        audioCtlChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            self?.action = call.method
            switch self?.action{
            case "exoPlayerStart":
                self?.player.stop()
                guard let args = call.arguments else {
                    return
                }
                if let myArgs = args as? [String: Any] {
                    self?.id = myArgs["id"] as? Int
                    let invalidDomainUrl = myArgs["url"] as? String // This is a bug in domain SSL certificate registration
                    print(invalidDomainUrl ?? "ERROR: nil url")
                    let fixedDomainUrl = invalidDomainUrl!.replacingOccurrences(of: ".sknt.ru/", with: ".sytes.net/")
                    self?.url = fixedDomainUrl
                    self?.name = myArgs["name"] as? String
                    self?.assetLogo = myArgs["assetLogo"] as? String
                    self?.logo = myArgs["logo"] as? String
                    self?.playSelecton()
                } else {
                    result("iOS could not extract flutter arguments in method: (sendParams)")
                }                
                break
            case "exoPlayerPause":
                self?.player.pause()
                break
            case "exoPlayerResume":
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
        let eventChPlayerCtrl = FlutterEventChannel(name: PLAYLIST_CTRL_STREAM_CHANNEL, binaryMessenger: controller.binaryMessenger)

        eventChPlayerCtrl.setStreamHandler(self)

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
        //     public init(audioUrl: String, artist: String? = nil, title: String? = nil, albumTitle: String? = nil, sourceType: SourceType, artwork: UIImage? = nil) {
        audioItem = DefaultAudioItem(audioUrl: self.url,
                                     artist: "Radio Anima Amoris",
                                     title: name,
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
        playlistCtrlEvent!(next)
    }
}
