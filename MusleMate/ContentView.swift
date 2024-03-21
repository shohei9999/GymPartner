//
//  ContentView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/20.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var items = [
        ListItem(name: "Apple", isFavorite: false),
        ListItem(name: "Banana", isFavorite: false),
        ListItem(name: "Orange", isFavorite: false),
        ListItem(name: "Grapes", isFavorite: false),
        ListItem(name: "Pineapple", isFavorite: false)
    ]

    @StateObject private var sessionDelegate = WatchSessionDelegate()

    var body: some View {
        NavigationView {
            List(items.indices, id: \.self) { index in
                Button(action: {
                    self.items[index].isFavorite.toggle()
                    self.sessionDelegate.sendFavoriteItemsToWatch(favoriteItems: self.favoriteItems)
                }) {
                    HStack {
                        Text(self.items[index].name)
                        Spacer()
                        Image(systemName: self.items[index].isFavorite ? "star.fill" : "star")
                            .foregroundColor(self.items[index].isFavorite ? .yellow : .gray)
                    }
                }
            }
            .navigationTitle("Workout Menu")
        }
        .onAppear {
            self.sessionDelegate.activateSession()
        }
    }

    private var favoriteItems: [String] {
        return self.items.filter { $0.isFavorite }.map { $0.name }
    }
}

class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    private let session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
    }

    // WCSessionが非アクティブになったときの処理
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession did become inactive")
    }
    
    // WCSessionが無効になったときの処理
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession did deactivate")
    }
    
    internal func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // Apple Watchからのデータを処理する
        print("session - no1")
        if applicationContext["favoriteData"] is String {
            print("session - no2")
            // データをアプリケーションの状態に反映するなどの処理を行う
            // 例えば、お気に入りのデータをローカルのリストに追加するなど
        }
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            session.activate()
        }
    }

    func sendFavoriteItemsToWatch(favoriteItems: [String]) {
        guard session.activationState == .activated else { return }
        do {
//            let message: [String: Any] = ["data": [favoriteItems]]
            let message: [String: Any] = ["data": ["Message from iphone"]]
            print(message)
//            try session.updateApplicationContext(message)
            try session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        } catch {
            print("Error sending favorite items to Apple Watch: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Apple Watchからのメッセージを処理する
        print("didReceiveMessage!!!")
    }
}

struct ListItem: Identifiable {
    let id = UUID()
    let name: String
    var isFavorite: Bool
}



#Preview {
    ContentView()
}
