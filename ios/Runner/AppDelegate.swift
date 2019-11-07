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
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        self.player.event.stateChange.addListener(self, self.handleAudioPlayerStateChange)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetooth])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        self.setupRemoteTransportControls()
        
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
                    self?.audioItem = DefaultAudioItem(audioUrl: stations[selection]["url"]!, sourceType: .stream)
                    do {
                        try self?.player.load(item: self!.audioItem, playWhenReady: true)
                        self?.player.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(true))
                    } catch {
                        print("The stream could not be loaded")
                    }
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
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "My Movie"
        
        if let image = UIImage(named: "lockscreen") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        //nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0//self.player.currentItem.currentTime().seconds
        //nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 3*60 //self.player.currentItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayerState) {
        var notifyState = "audio.onError"
        switch(state){
        case AudioPlayerState.playing:
            notifyState = self.action == "resume" ? "audio.onResume" : "audio.onCreate"
            break
        case AudioPlayerState.paused:
            notifyState = "audio.onPause"
            break
        default:
            break
        }
        self.audioCtlChannel.invokeMethod(notifyState, arguments: 0)

        print("handleAudioPlayerStateChange: \(state)")
    }
    
}
