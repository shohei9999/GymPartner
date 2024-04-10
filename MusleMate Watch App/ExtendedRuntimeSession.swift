//
//  ExtendedRuntimeSession.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/04/10.
//
import Foundation
import WatchKit

final class ExtendedRuntimeSession: NSObject, ObservableObject {
    private var session: WKExtendedRuntimeSession!
    var sessionEndCompletion: (() -> Void)?
    
    func startSession() {
        session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start()
    }
    
    func endSession() {
        session.invalidate()
    }
}

extension ExtendedRuntimeSession: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {}
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        sessionEndCompletion?()
    }
        
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        sessionEndCompletion?()
    }
}
