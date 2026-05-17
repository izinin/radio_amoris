import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    var action: String?

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Essential: Allow Flutter's base class to establish the scene framework first
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        
        // Safely capture the window scene and retrieve the verified view controller
        guard let _ = (scene as? UIWindowScene),
              let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        
        // Set up your MethodChannel now that the UI is bound safely
        setupAudioMethodChannel(with: controller)
    }
    
    private func setupAudioMethodChannel(with controller: FlutterViewController) {
        AppStateManager.shared.audioCtlChannel = FlutterMethodChannel(
            name: ChannelName.audio,
            binaryMessenger: controller.binaryMessenger)
        AppStateManager.shared.audioCtlChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            self?.action = call.method
            switch self?.action {
            case "exoPlayerStart":
                guard let args = call.arguments else {
                    return
                }
                guard let params = args as? [String: Any] else {
                    return
                }
                guard let radioItem = try? MyRadioItem(args: params) else {
                    return
                }
                AppStateManager.shared.playerStateEventHandler.playMedia(radioItem: radioItem)
            case "exoPlayerPause":
                AppStateManager.shared.playerStateEventHandler.currCmd = MyPlayerCommand.PAUSE
                AppStateManager.shared.player.pause()
                break
            case "exoPlayerResume":
                AppStateManager.shared.playerStateEventHandler.currCmd = MyPlayerCommand.PLAY
                AppStateManager.shared.player.play()
                break
            case "destroy":
                AppStateManager.shared.playerStateEventHandler.currCmd = MyPlayerCommand.IDLE
                AppStateManager.shared.player.pause()
                result("audio.onDestroy")
                break
            default:
                result(FlutterMethodNotImplemented)
                return
            }
            result(0)
        })
        let eventChPlaylistCtrl = FlutterEventChannel(
            name: ChannelName.stream_playlist_ctl, binaryMessenger: controller.binaryMessenger)
        let eventChPlayerState = FlutterEventChannel(
            name: ChannelName.stream_player_state, binaryMessenger: controller.binaryMessenger)

        eventChPlaylistCtrl.setStreamHandler(AppStateManager.shared.playlistStateEventHandler)
        eventChPlayerState.setStreamHandler(AppStateManager.shared.playerStateEventHandler)
    }
}
