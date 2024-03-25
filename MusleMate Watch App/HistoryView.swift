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
        NavigationView {
            VStack {
                if historyItems.isEmpty {
                    Text("Oops! Looks like you haven't logged any workouts today.")
                        .font(.body)
                        .padding()
                } else {
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
                }
            }
            .navigationTitle(dateFormatter.string(from: Date()))
            .onAppear {
                loadDataFromUserDefaults()
                sessionDelegate.activateSession()
                sessionDelegate.sendMessageToiPhone()
            }
        }
    }
    
    private func loadDataFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("workout") }.sorted()
        
        var items: [HistoryItem] = []
        let todayDateString = dateFormatter.string(from: Date())
        
        for key in keys {
            if let data = userDefaults.object(forKey: key) as? [String: Any],
               let time = key.components(separatedBy: "_").last,
               let menu = data["menu"] as? String,
               let weight = data["weight"] as? Int,
               let unit = data["unit"] as? String,
               let reps = data["reps"] as? Int,
               let workoutDate = formatTimeToDate(time) {
                
                let workoutDateString = dateFormatter.string(from: workoutDate)
                
                if workoutDateString == todayDateString {
                    let formattedTime = formatTime(time)
                    items.append(HistoryItem(time: formattedTime, menu: menu, weight: weight, unit: unit, reps: reps))
                }
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
    
    private func formatTimeToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.date(from: time)
    }
}

#Preview {
    HistoryView()
}
