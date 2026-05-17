//
//  CurrentlyPlayingTrackEventHandler.swift
//  Runner
//
//  Created by Igor Zinin on 12.1.2025.
//

import Foundation

class CurrentlyPlayingTrackEventHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

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
    
    func sendTrackMetadata(title: String) {
        eventSink?(["title": title, "url": ""])
    }
}
