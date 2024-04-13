//
//  HistoryView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/23.
//
import SwiftUI

struct HistoryView: View {
    // WorkoutItem構造体を定義し、Identifiableに準拠させる
    struct WorkoutItem: Identifiable {
        let id = UUID()
        let date: String  // 日付
        let time: String
        let menu: String
        let weight: Double
        let unit: String
        let reps: Int
    }
    
    // WorkoutItem型の配列を格納するプロパティ
    @State private var workoutItems: [WorkoutItem] = [] // ワークアウトアイテムを格納する配列
    var selectedDate: Date // 選択された日付を受け取る
    
    // ボディ部分
    var body: some View {
        VStack {
            if workoutItems.isEmpty {
                VStack {
                    Text("Selected date does not have any training records.")
                        .font(.body) // フォントをbodyに設定
                        .padding()
                    Spacer()
                }
            } else {
                // データがある場合はリストを表示
                List {
                    ForEach(workoutItems) { item in
                        HStack {
                            Image(systemName: "figure.cross.training")
                                .font(.system(size: 30))
                                .padding(.trailing, 5)
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(item.menu)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("\(item.date) \(item.time)")  // 日付と時間を結合して表示
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 5)
                                HStack {
                                    Text(String(format: "%.2f", item.weight) + "\(item.unit)")
                                        .foregroundColor(.blue)
                                    Text("\(item.reps) reps")
                                        .foregroundColor(.blue)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        // 右にスワイプして削除
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                // 削除処理を実行
                                deleteWorkoutItem(item)
                            } label: {
                                // 削除ボタンの表示
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // リストスタイルをプレーンに設定
            }
        }
        .onAppear {
            // UserDefaultsからデータを取得してworkoutItemsに格納
            loadDataFromUserDefaults()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            // UserDefaultsの変更があった場合にデータを再読み込みする
            loadDataFromUserDefaults()
        }
    }
    
    // UserDefaultsからデータを取得してworkoutItemsに格納するメソッド
    private func loadDataFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("selectedDate: \(formattedDate)")
        // workout_から始まるキーをフィルタリングしてソート
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.starts(with: "workout_") && $0.contains(formattedDate) }.sorted()
        print("keys: \(keys)")
        var items: [WorkoutItem] = []
        
        for key in keys {
            // キーが"workout_"で始まり、かつ対応するデータが存在する場合にのみ処理を行う
            if let data = userDefaults.dictionary(forKey: key) {
                
                // 各値を取得し、nilの場合はデフォルト値を設定する
                let menu = data["menu"] as? String ?? ""
                let weight = data["weight"] as? Double ?? 0
                let unit = data["unit"] as? String ?? ""
                let reps = data["reps"] as? Int ?? 0
                
                // 日付の取得
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                if let date = dateFormatter.date(from: String(key.suffix(14))) {
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    let dateString = dateFormatter.string(from: date)
                    
                    dateFormatter.dateFormat = "HH:mm:ss"
                    let time = dateFormatter.string(from: date)
                    
                    // ワークアウトアイテムを作成して配列に追加
                    let workoutItem = WorkoutItem(date: dateString, time: time, menu: menu, weight: weight, unit: unit, reps: reps)
                    items.append(workoutItem)
                }
            }
        }
        
        workoutItems = items
    }
    
    // ワークアウトアイテムを削除するメソッド
    private func deleteWorkoutItem(_ item: WorkoutItem) {
        // 削除対象のアイテムのインデックスを取得
        if let index = workoutItems.firstIndex(where: { $0.id == item.id }) {
            // 配列から削除
            workoutItems.remove(at: index)
            
            // UserDefaultsからも削除
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let formattedDate = dateFormatter.string(from: selectedDate)
            let userDefaults = UserDefaults.standard
            let key = "workout_\(formattedDate)\(item.time.replacingOccurrences(of: ":", with: ""))"
            userDefaults.removeObject(forKey: key)
        }
    }
}

#Preview {
    HistoryView(selectedDate: Date())
}
