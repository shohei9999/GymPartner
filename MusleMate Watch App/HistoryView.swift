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
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    // WatchSessionDelegateのインスタンスを共有する
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate

    struct HistoryItem: Identifiable {
        let id = UUID()
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
        List(historyItems) { item in
            VStack(alignment: .leading) {
                Text(item.time)
                    .font(.caption)
                Text(item.menu)
                    .font(.caption)
                Text("\(item.weight) \(item.unit), \(item.reps) reps")
                    .font(.caption)
            }
            .padding()
        }
        .navigationTitle(dateFormatter.string(from: Date()))
        .onAppear {
            loadDataFromUserDefaults()
            sessionDelegate.activateSession()
            // 他の画面でデータの受信や保存を行う処理を追加できます
        }
    }
    
    private func loadDataFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("workout") }.sorted()
        
        var items: [HistoryItem] = []
        
        for key in keys {
            if let data = userDefaults.object(forKey: key) as? [String: Any],
               let time = key.components(separatedBy: "_").last,
               let menu = data["menu"] as? String,
               let weight = data["weight"] as? Int,
               let unit = data["unit"] as? Int,
               let reps = data["reps"] as? Int {
                
                let unitString = unit == 0 ? "kg" : "lb"
                let formattedTime = formatTime(time)
                items.append(HistoryItem(time: formattedTime, menu: menu, weight: weight, unit: unitString, reps: reps))
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
}


#Preview {
    HistoryView()
}
