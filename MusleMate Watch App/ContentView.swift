//
//  ContentView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/20.
//
import SwiftUI
import WatchConnectivity

struct ContentView: View {
    // UserDefaultsキー
    private let userDefaultsKey = "receivedData"
    
    // 受信したデータを保持する配列
    @StateObject private var sessionDelegate = WatchSessionDelegate(userDefaultsKey: "receivedData") // WatchSessionDelegateの初期化時にuserDefaultsKeyを渡す

    var body: some View {
        VStack {
            // メッセージ送信用のボタン
//            Button("Send Message to iPhone") {
//                sessionDelegate.sendMessageToiPhone()
//            }
            
            // 受信したデータをリスト表示する
            List(sessionDelegate.receivedData, id: \.self) { data in
                Text(data)
            }
        }
        .padding()
        .onAppear {
            print("onAppear")
            // WCSessionを有効化し、受信処理を開始する
            sessionDelegate.activateSession()
            
            // UserDefaultsからデータを読み込む
            if let storedData = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
                sessionDelegate.receivedData = storedData
            }
        }
    }
}

class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
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

    // メッセージ受信時の処理
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
        let message = ["data": ["Message from Apple Watch"]]
        print(message)
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
}



#Preview {
    ContentView()
}

