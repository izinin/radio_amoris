//
//  AppStateManager.swift
//  Runner
//
//  Created by Igor Zinin on 13.5.2026.
//

import Foundation
import AVFoundation
import Flutter

class AppStateManager {
    // Unique shared instance
    static let shared = AppStateManager()

    // Constant properties
    let player = AVPlayer()
    let nowPlayableBehavior = IOSNowPlayableBehavior()
    let playerCurrPlayingEventHandler = CurrentlyPlayingTrackEventHandler()
    let playerExceptionEventHandler = PlayerExceptionEventHandler()
    let playlistStateEventHandler = PlaylistStateEventHandler()

    // Variable properties
    var audioCtlChannel: FlutterMethodChannel!
    var playlistCtrlEvent: FlutterEventSink?
    var playerStateEventHandler: PlayerStateEventHandler
    
    
    // Private initializer prevents external instantiation
    private init() {
        playerStateEventHandler = PlayerStateEventHandler(
            player: player, nowPlayableBehavior: nowPlayableBehavior,
            playerExceptionEventHandler: playerExceptionEventHandler,
            currPlaying: playerCurrPlayingEventHandler)
    }
}
