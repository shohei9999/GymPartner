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
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let receivedData = userInfo["data"] as? [String] {
            // 受信したデータを更新
            DispatchQueue.main.async {
                self.receivedData = receivedData
                print("received data from iPhone")
                // UserDefaultsにデータを保存
                UserDefaults.standard.set(receivedData, forKey: self.userDefaultsKey)
            }
        }
    }
    
    // iPhoneにメッセージを送信するメソッド
    func sendMessageToiPhone() {
        // UserDefaultsからデータを取得し、フィルタリングして降順でソート
        let workoutDataArray = UserDefaults.standard.dictionaryRepresentation()
            .filter { $0.key.starts(with: "workout_") } // workout_で始まるキーに絞り込み
            .sorted { $0.key > $1.key } // キーで降順にソート
            .compactMap { (key, value) -> [String: Any]? in // 戻り値の型を明示的に指定
                guard let data = value as? [String: Any], let sendStatus = data["sendStatus"] as? Bool, !sendStatus else {
                    return nil // sendStatusがfalseでない場合はnilを返す
                }
                return ["key": key, "data": data] // データを返す
            }
        
        // workoutDataArrayが空の場合は送信処理を行わない
        guard !workoutDataArray.isEmpty else {
            print("workoutDataArray is empty. Skipping sending message to iPhone.")
            return
        }
        
        // 一番目のデータを取得
        let firstData = workoutDataArray[0]
        print("iPhoneにデータ送信： \(firstData)")

        // iPhoneにメッセージを送信
        session.transferUserInfo(["workoutDataArray": [firstData]])
    }

}
