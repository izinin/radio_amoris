import UIKit
import Flutter
import AVFoundation
import MediaPlayer

enum ChannelName {
  static let audio = "com.zindolla.radioamoris/audio"
  static let stream_player_state = "com.zindolla.radioamoris/player-state"
  static let stream_playlist_ctl = "com.zindolla.radioamoris/playlist-ctrl"
}

enum MyPlayerCommand: Int {
    case IDLE = 0
    case PLAY
    case PAUSE
}

enum MyradioProcessingState: Int {
    case idle = 1  //  ExoPlayer.STATE_IDLE
    case buffering = 2  //  ExoPlayer.STATE_BUFFERING
    case ready = 3  //  ExoPlayer.STATE_READY
    case ended = 4  //  ExoPlayer.STATE_ENDED
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        AppStateManager.shared.playlistCtrlEvent = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        AppStateManager.shared.playlistCtrlEvent = nil
        return nil
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        // see example: https://developer.apple.com/documentation/mediaplayer/becoming-a-now-playable-app
        let registeredCommands: [NowPlayableCommand] = [
            .togglePausePlay,
            .nextTrack,
            .previousTrack,
        ]
        // Configure the app for Now Playing Info and Remote Command Center behaviors.
        try? AppStateManager.shared.nowPlayableBehavior.handleNowPlayableConfiguration(
            commands: registeredCommands,
            disabledCommands: [
                .play,
                .pause,
                .stop,
                .skipBackward,
                .skipForward,
                .changePlaybackPosition,
                .changePlaybackRate,
                .enableLanguageOption,
                .disableLanguageOption,
            ],
            commandHandler: handleCommand(command:event:),
            interruptionHandler: handleInterrupt(with:))
        observePlayingState()
        Task {
            await observeRateChanges()
        }

    }

    private func observePlayingState() {
        AppStateManager.shared.player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { status in
                AppStateManager.shared.playerStateEventHandler.mapPlayerStatus(status)
            }
            .store(in: &AppStateManager.shared.playerStateEventHandler.subscriptions)
    }

    // Observe changes to the playback rate asynchronously.
    private func observeRateChanges() async {
        let name = AVPlayer.rateDidChangeNotification
        for await notification in NotificationCenter.default.notifications(named: name) {
            guard
                let reason = notification.userInfo?[AVPlayer.rateDidChangeReasonKey]
                    as? AVPlayer.RateDidChangeReason
            else {
                continue
            }
            switch reason {
            case .appBackgrounded:
                NSLog("%@", "The app transitioned to the background.")
            case .audioSessionInterrupted:
                NSLog("%@", "The system interrupts the app’s audio session.")
            case .setRateCalled:
                NSLog("%@", "The app set the player’s rate.")
            case .setRateFailed:
                NSLog("%@", "An attempt to change the player’s rate failed.")
            default:
                break
            }
        }
    }

    // MARK: Remote Commands
    // Handle a command registered with the Remote Command Center.
    private func handleCommand(command: NowPlayableCommand, event: MPRemoteCommandEvent)
        -> MPRemoteCommandHandlerStatus
    {
        print(command)

        switch command {
        case .stop:
            AppStateManager.shared.player.pause()

        case .togglePausePlay:
            AppStateManager.shared.playerStateEventHandler.togglePausePlay()

        case .pause:
            AppStateManager.shared.player.pause()
        case .play:
            AppStateManager.shared.player.play()

        case .nextTrack:
            AppStateManager.shared.playlistStateEventHandler.sendNextTrack(isForward: true)

        case .previousTrack:
            AppStateManager.shared.playlistStateEventHandler.sendNextTrack(isForward: true)

        default:
            break
        }

        return .success
    }

    // MARK: Interruptions

    // Handle a session interruption.

    private func handleInterrupt(with interruption: NowPlayableInterruption) {

        switch interruption {

        case .began:
            print("isInterrupted = true")

        case .ended(let _shouldPlay):
            print("isInterrupted = false")

        /* TODO: restoreme
            switch playerState {
        
            case .stopped:
                break
        
            case .playing where shouldPlay:
                player.play()
        
            case .playing:
                playerState = .paused
        
            case .paused:
                break
            }
             */
        case .failed(let error):
            print(error.localizedDescription)
        }
    }
}
