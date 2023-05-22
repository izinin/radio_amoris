import UIKit
import Flutter
import AVFoundation
import MediaPlayer

enum ChannelName {
  static let audio = "com.zindolla.radioamoris/audio"
  static let stream_player_state = "com.zindolla.radioamoris/player-state"
  static let stream_playlist_ctl = "com.zindolla.radioamoris/playlist-ctrl"
}

enum MyPlayerCommand : Int {
    case IDLE = 0
    case PLAY
    case PAUSE
}

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

    var currCmd: MyPlayerCommand = MyPlayerCommand.IDLE
    var playlistCtrlEvent: FlutterEventSink?
    var playerStateEventHandler = PlayerStateStreamHandler()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        playlistCtrlEvent = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        playlistCtrlEvent =  nil
        return nil
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
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
        self.audioCtlChannel = FlutterMethodChannel(name: ChannelName.audio,
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
                    self!.currCmd = MyPlayerCommand.PLAY
                } else {
                    self!.currCmd = MyPlayerCommand.IDLE
                    result("iOS could not extract flutter arguments in method: (sendParams)")
                }                
                break
            case "exoPlayerPause":
                self!.currCmd = MyPlayerCommand.PAUSE
                self?.player.pause()
                break
            case "exoPlayerResume":
                self!.currCmd = MyPlayerCommand.PLAY
                self?.player.play()
                break
            case "destroy":
                self!.currCmd = MyPlayerCommand.IDLE
                self?.player.stop()
                result("audio.onDestroy")
                break
            default:
                result(FlutterMethodNotImplemented)
                return
            }
            result(0)
        })
        let eventChPlaylistCtrl = FlutterEventChannel(name: ChannelName.stream_playlist_ctl, binaryMessenger: controller.binaryMessenger)
        let eventChPlayerState = FlutterEventChannel(name: ChannelName.stream_player_state, binaryMessenger: controller.binaryMessenger)

        eventChPlaylistCtrl.setStreamHandler(self)
        eventChPlayerState.setStreamHandler(playerStateEventHandler)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func handleAudioPlayerStateChange(state: AudioPlayerState) {
        let flutterAState = (state == AudioPlayerState.playing || state == AudioPlayerState.paused) ? 3 : 1;
        print("handleAudioPlayerStateChange: \(state)")
        guard playerStateEventHandler.getPlayerStateEvent != nil else {
            print("getPlayerStateEvent is nil")
            return
        }
        playerStateEventHandler.getPlayerStateEvent!(["state": flutterAState, "command": currCmd.rawValue])
    }
    
    func playSelecton(){
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
        self.currCmd = MyPlayerCommand.PLAY
        playlistCtrlEvent!(next)
    }
}

class PlayerStateStreamHandler: NSObject, FlutterStreamHandler {
    var playerStateEvent: FlutterEventSink?
    
    // Read-only  property
    var getPlayerStateEvent: FlutterEventSink? {
        get {
            return self.playerStateEvent
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.playerStateEvent = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.playerStateEvent =  nil
        return nil
    }
}               

