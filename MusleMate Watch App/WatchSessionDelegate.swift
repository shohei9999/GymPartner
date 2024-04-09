//
//  WatchSessionDelegate.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/23.
//
// WatchSessionDelegate.swift
import Foundation
import WatchConnectivity

class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
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
            print("WCSession activated successfully")
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

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let receivedData = message["data"] as? [String] {
            // 受信したデータを更新
            DispatchQueue.main.async {
                self.receivedData = receivedData
                print("received data from iphone")
                // UserDefaultsにデータを保存
                UserDefaults.standard.set(receivedData, forKey: self.userDefaultsKey)
            }
        }
    }
    
    // iPhoneにメッセージを送信するメソッド
    func sendMessageToiPhone() {
        // ワークアウトのデータを格納する配列
        var workoutDataArray: [[String: Any]] = []

        // UserDefaultsからデータを取得し、フィルタリングしてソート
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.starts(with: "workout_") }.sorted()

        // キーに対応するデータを取得して配列に保存
        for key in keys {
            if let data = userDefaults.dictionary(forKey: key), let sendStatus = data["sendStatus"] as? Bool, !sendStatus {
                workoutDataArray.append(["key": key, "data": data])
            }
        }
        
        // workoutDataArrayが空の場合は送信処理を行わない
        guard !workoutDataArray.isEmpty else {
            print("workoutDataArray is empty. Skipping sending message to iPhone.")
            return
        }
        
        print("iPhoneにデータ送信： \(workoutDataArray)")

        // iPhoneにメッセージを送信
        session.transferUserInfo(["workoutDataArray": workoutDataArray])
    }
}
