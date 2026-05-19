//
//  PlayerStateEventHandler.swift
//  Runner
//
//  Created by Igor Zinin on 12.1.2025.
//

import Foundation
import AVFoundation
import Combine

class PlayerStateEventHandler: NSObject, FlutterStreamHandler, AVPlayerItemMetadataOutputPushDelegate {
    private var eventSink: FlutterEventSink?
    
    @Published var playerState: MyradioProcessingState = .idle
    var currCmd: MyPlayerCommand = MyPlayerCommand.IDLE
    
    private var radioItem: MyRadioItem!
    private let player: AVPlayer
    private let nowPlayableBehavior: IOSNowPlayableBehavior
    private let playerExceptionEventHandler: PlayerExceptionEventHandler
    private let currPlaying: CurrentlyPlayingTrackEventHandler

    private var itemObserver: NSKeyValueObservation!
    private var rateObserver: NSKeyValueObservation!
    private var statusObserver: NSObjectProtocol!
    var subscriptions = Set<AnyCancellable>()
    
    init(player: AVPlayer, nowPlayableBehavior: IOSNowPlayableBehavior, playerExceptionEventHandler: PlayerExceptionEventHandler, currPlaying: CurrentlyPlayingTrackEventHandler) {
        self.player = player
        self.nowPlayableBehavior = nowPlayableBehavior
        self.playerExceptionEventHandler = playerExceptionEventHandler
        self.currPlaying = currPlaying
    }
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        self.eventSink = nil
        return nil
    }
    
    private func sendIdle() {
        let state = MyradioProcessingState.idle.rawValue
        let command = MyPlayerCommand.IDLE.rawValue
        eventSink?(["state": state, "command": command])
    }
    
    private func sendState() {
        eventSink?(["state": playerState.rawValue, "command": currCmd.rawValue])
    }
    
    func togglePausePlay(){
        playerState = .ready
        if currCmd == MyPlayerCommand.PLAY {
            currCmd = MyPlayerCommand.PAUSE
            player.pause()
        } else {
            currCmd = MyPlayerCommand.PLAY
            player.play()
        }
        sendState()
    }

    func playMedia(radioItem: MyRadioItem) {
        currCmd = MyPlayerCommand.PLAY
        sendIdle()
        self.radioItem = radioItem
        
        let asset = AVAsset(url: radioItem.url)
        let playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: [.tracks, .duration, .commonMetadata]
        )
        // Register to observe the status property before associating with player.
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:

                    // Start a playback session.
                    try? nowPlayableBehavior.handleNowPlayableSessionStart()

                    // Observe changes to the current item and playback rate.

                    if player.currentItem != nil {

                        itemObserver = player.observe(\.currentItem, options: .initial) {
                            [unowned self] _, _ in
                            self.handlePlayerItemChange()
                        }

                        rateObserver = player.observe(\.rate, options: .initial) {
                            [unowned self] _, _ in
                            self.handlePlaybackChange()
                        }

                        statusObserver = player.observe(\.currentItem?.status, options: .initial) {
                            [unowned self] _, _ in
                            self.handlePlaybackChange()
                        }
                    }

                    // Ready to play. Present playback UI.
                    player.play()
                case .failed:
                    // A failure while loading media occurred.
                    playerExceptionEventHandler.sendChannelFailed(id: radioItem.id)
                default:
                    break
                }
            }
            .store(in: &subscriptions)

        // Create and configure metadata output
        let metadataOutput = AVPlayerItemMetadataOutput()
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(metadataOutput)

        // Set the item as the player's current item.
        player.replaceCurrentItem(with: playerItem)
    }

    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from: AVPlayerItemTrack?) {
        if let item = groups.first?.items.first
        {
            item.value(forKeyPath: "value")
            if let song = (item.value(forKeyPath: "value")!) as? String {
                currPlaying.sendTrackMetadata(title: song)
                radioItem.updateCurrentSong(with: song)
                nowPlayableBehavior.handleNowPlayableItemChange(
                    metadata: radioItem.toNowPlayableStaticMetadata())
            }
        } else {
            print("MetaData Error")
        }
    }
    
    func mapPlayerStatus(_ status: AVPlayer.TimeControlStatus) {
        playerState = MyradioProcessingState.idle
        switch status {
        case .playing: playerState = MyradioProcessingState.ready
        case .paused: playerState = MyradioProcessingState.ended
        case .waitingToPlayAtSpecifiedRate: playerState = MyradioProcessingState.buffering
        @unknown default: playerState = MyradioProcessingState.idle
        }

        sendState()
    }

    // MARK: Now Playing Info
    // Helper method: update Now Playing Info when the current item changes.
    private func handlePlayerItemChange() {
        nowPlayableBehavior.handleNowPlayableItemChange(
            metadata: radioItem.toNowPlayableStaticMetadata())
    }
    // Helper method: update Now Playing Info when playback rate or position changes.
    private func handlePlaybackChange() {
        guard let currentItem = player.currentItem else { return }
        guard currentItem.status == .readyToPlay else { return }
        let metadata = NowPlayableDynamicMetadata(
            rate: player.rate,
            position: Float(currentItem.currentTime().seconds),
            duration: Float(currentItem.duration.seconds),
            currentLanguageOptions: [],
            availableLanguageOptionGroups: [])

        nowPlayableBehavior.handleNowPlayablePlaybackChange(
            playing: (currCmd == MyPlayerCommand.PLAY), metadata: metadata)
    }

}
