//
//  WatchSessionDelegate.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/23.
//

import Foundation
import WatchConnectivity

class DataTransferManager: NSObject, ObservableObject, WCSessionDelegate {
    // 受信したデータを保持するプロパティ
    @Published var receivedData: [String] = []
    
    // UserDefaultsキー
    private let userDefaultsKey: String // userDefaultsKeyを保持するプロパティを追加

    // WCSessionインスタンスを格納するプロパティ
    private let session = WCSession.default

    // WatchSessionDelegateの初期化時にuserDefaultsKeyを受け取る
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        super.init()
        session.delegate = self
    }
    
    // WCSessionの有効化
    func activateSession() {
        if WCSession.isSupported() {
            session.activate()
        }
    }
    
    // MARK: - WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("iphone WCSession activated successfully iphone")
        case .inactive:
            print("WCSession inactive")
        case .notActivated:
            print("WCSession not activated")
        @unknown default:
            print("Unknown activation state")
        }
        
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("iphone received userInfo")
        
        if let workoutDataArray = userInfo["workoutDataArray"] as? [[String: Any]] {
            for workoutData in workoutDataArray {
                if let key = workoutData["key"] as? String, let data = workoutData["data"] as? [String: Any] {
                    if let deleted = data["deleted"] as? Bool, deleted {
                        UserDefaults.standard.removeObject(forKey: key)
                    } else {
                        // 受信したデータをUserDefaultsに保存
                        UserDefaults.standard.set(data, forKey: key)
                    }
                }
            }
        }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Implement your code here
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        // Implement your code here
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Implement your code here
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // Implement your code here
    }

    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        // Implement your code here
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        // Implement your code here
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        // Implement your code here
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Implement your code here
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Implement your code here
    }
}
