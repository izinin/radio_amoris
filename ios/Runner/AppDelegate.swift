import UIKit
import Flutter
import SwiftAudio
import MediaPlayer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var player: AudioPlayer = AudioPlayer()
    var audioItem: AudioItem!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
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
        let audioCtlChannel = FlutterMethodChannel(name: "com.zindolla.radio_amoris/audio",
                                                   binaryMessenger: controller.binaryMessenger)
        audioCtlChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            switch call.method{
            case "create":
                self?.audioItem = DefaultAudioItem(audioUrl: "https://p.scdn.co/mp3-preview/67b51d90ffddd6bb3f095059997021b589845f81?cid=d8a5ed958d274c2e8ee717e6a4b0971d", sourceType: .stream)
                do {
                    try self?.player.load(item: self!.audioItem, playWhenReady: true)
                    self?.setupNowPlaying()
                } catch {
                    print("The stream could not be loaded")
                }
                break
            case "pause":
                break
            case "resume":
                break
            case "destroy":
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
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0//self.player.currentItem.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 3*60 //self.player.currentItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
