//
//  WatchSessionDelegate.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/23.
//

import Foundation
import WatchConnectivity

class DataTransferManager: NSObject, ObservableObject {
    // 受信したデータを保持するプロパティ
    @Published var receivedData: [String] = []
    
    // UserDefaultsキー
    private let userDefaultsKey: String // userDefaultsKeyを保持するプロパティを追加

    // WCSessionインスタンスを格納するプロパティ
    private let session = WCSession.default

    // DataTransferManagerの初期化時にuserDefaultsKeyを受け取る
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
}

// MARK: - WCSessionDelegate methods
extension DataTransferManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("WCSession activated successfully iphone")
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

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let dataArray = message["workoutDataArray"] as? [[String: Any]], let workoutData = dataArray.first, let key = workoutData["key"] as? String, let data = workoutData["data"] as? [String: Any] {
            // 受信したデータをUserDefaultsに保存
            UserDefaults.standard.set(data, forKey: key)
        }
    }


    // 以下のメソッドは必要に応じて実装
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {}
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {}
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {}
    func session(_ session: WCSession, didReceive file: WCSessionFile) {}
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {}
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {}

    func sessionReachabilityDidChange(_ session: WCSession) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}

