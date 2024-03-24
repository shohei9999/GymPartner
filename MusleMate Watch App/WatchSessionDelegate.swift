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
                
                // UserDefaultsにデータを保存
                UserDefaults.standard.set(receivedData, forKey: self.userDefaultsKey)
            }
        }
    }
    
    // iPhoneにメッセージを送信するメソッド
    func sendMessageToiPhone() {
        // UserDefaultsからデータを取得
        let userDefaults = UserDefaults.standard.dictionaryRepresentation()
        // ワークアウトのデータを格納する配列
        var workoutDataArray: [[String: Any]] = []
        
        // UserDefaultsから取得したデータをフィルタリング
        for (key, value) in userDefaults {
            // キーが"workout_"で始まり、かつsendStatusがfalseのデータを抽出
            if key.starts(with: "workout_"), let data = value as? [String: Any], let sendStatus = data["sendStatus"] as? Int, sendStatus == 0 {
                var updatedData: [String: Any] = [:]
                updatedData["key"] = key // キーをデータに追加
                updatedData["data"] = data // データを追加
                workoutDataArray.append(updatedData)
                print(workoutDataArray)
                // iPhoneにメッセージを送信
                print("iPhoneにメッセージを送信")
                let session = WCSession.default
                if session.activationState == .activated {
                    print("WatchConnectivityセッションがアクティブです。")
                } else {
                    print("WatchConnectivityセッションがアクティブではありません。")
                }
                session.sendMessage(["workoutDataArray": workoutDataArray], replyHandler: { replyMessage in
                    // 送信が成功した場合、該当データのsendStatusをtrueに変更
                    if let sentKey = replyMessage["sentKey"] as? String, sentKey == key {
                        print("Message sent successfully for key: \(sentKey)")
                        DispatchQueue.main.async {
                            // 該当データのsendStatusをtrueに更新
                            if var updatedValue = UserDefaults.standard.dictionary(forKey: sentKey) {
                                updatedValue["sendStatus"] = 1
                                UserDefaults.standard.set(updatedValue, forKey: sentKey)
                            }
                        }
                    }
                }, errorHandler: { error in
                    // メッセージの送信が失敗した場合の処理
                    print("Error sending message: \(error.localizedDescription)")
                })
            }
        }
    }
}
