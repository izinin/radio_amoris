import UIKit
import Flutter
import SwiftAudio

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var player: AudioPlayer = AudioPlayer()
    var audioItem: AudioItem!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        
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
}
