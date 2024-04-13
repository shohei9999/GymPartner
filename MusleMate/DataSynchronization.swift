//
//  DataSynchronization.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/13.
//

import Foundation
import WatchConnectivity

class DataSynchronization {
    static func printUserDefaultsItems() {
        // UserDefaultsの値を取得してprintする処理を記述する
        if let savedData = UserDefaults.standard.data(forKey: "items"),
           let decodedData = try? JSONDecoder().decode([ListItem].self, from: savedData) {
            let items = decodedData
            
            // isFavoriteがtrueのデータのみ抽出してからnameを取得する
            let names = items.filter { $0.isFavorite }.map { $0.name }
            print("names: \(names)")
            // Apple Watchにデータを送信する
            if WCSession.default.isReachable {
                let message = ["data": names] // "data"というキーでnamesを送信
                WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                    print("Failed to send message to Apple Watch: \(error.localizedDescription)")
                })
            } else {
                print("Apple Watch is not reachable.")
            }
        }
    }
}
