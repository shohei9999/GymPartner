//
//  HistoryView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/22.
//
import SwiftUI

struct HistoryView: View {
    @State private var historyItems: [HistoryItem] = []
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    // WatchSessionDelegateのインスタンスを共有する
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate

    struct HistoryItem: Identifiable {
        let id: String // キーをidに使用する
        let time: String
        let menu: String
        let weight: Int
        let unit: String
        let reps: Int
        
        var formattedString: String {
            "\(time)\n\(menu)\n\(weight) \(unit), \(reps) reps"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if historyItems.isEmpty {
                    Text("Oops! Looks like you haven't logged any workouts today.")
                        .font(.body)
                        .padding()
                } else {
                    List {
                        ForEach(historyItems) { item in
                            VStack(alignment: .leading) {
                                Text(item.time)
                                    .font(.caption)
                                Text(item.menu)
                                    .font(.caption)
                                Text("\(item.weight) \(item.unit), \(item.reps) reps")
                                    .font(.caption)
                            }
                            .padding()
                            .id(item.id) // 各項目にキーを割り当てる
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    print("item id : \(item.id)")
                                    deleteItem(with: item.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("History") // タイトルを変更
            .navigationBarHidden(true) // ナビゲーションバーを非表示にする
            .onAppear {
                loadDataFromUserDefaults()
                sessionDelegate.activateSession()
            }
        }
    }
    
    private func loadDataFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        let todayDateString = dateFormatter.string(from: Date())
        print("todayDateString: \(todayDateString)")
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("workout_\(todayDateString)") }.sorted()
        print("Keys: \(keys)")
        var items: [HistoryItem] = []
        
        for key in keys {
            if let data = userDefaults.object(forKey: key) as? [String: Any],
               let time = key.components(separatedBy: "_").last,
               let menu = data["menu"] as? String,
               let weight = data["weight"] as? Int,
               let unit = data["unit"] as? String,
               let reps = data["reps"] as? Int {
                
                let formattedTime = formatTime(time)
                items.append(HistoryItem(id: key, time: formattedTime, menu: menu, weight: weight, unit: unit, reps: reps))
            }
        }
        
        historyItems = items
    }
    
    private func formatTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "HH:mm:ss"
            return formatter.string(from: date)
        }
        return time
    }
    
    private func deleteItem(with id: String) {
        // 削除したことをiphoneに伝える
        let value: [String: Any] = [
            "deleted": true as Any
        ]
        let sendData = ["key": id, "data": value] as [String : Any]
        sessionDelegate.sendMessageToiPhone(with: sendData )
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: id)
        // UserDefaultsの変更を即時に反映する
        userDefaults.synchronize()
        // 削除したアイテムをリストからも削除する
        historyItems.removeAll { $0.id == id }
    }
}




#Preview {
    HistoryView()
}
