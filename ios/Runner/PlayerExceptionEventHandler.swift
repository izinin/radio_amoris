//
//  PlayerExceptionEventHandler.swift
//  Runner
//
//  Created by Igor Zinin on 12.1.2025.
//
import Foundation

class PlayerExceptionEventHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = eventSink
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        self.eventSink = nil
        return nil
    }
    
    func sendChannelFailed(id: Int) {
        eventSink?(["failed_id": id])
    }
}

