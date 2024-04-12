//
//  HistoryView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/23.
//
import SwiftUI

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

struct HistoryView: View {
    // WorkoutItem型の配列を格納するプロパティ
    @State private var workoutItems: [String: [WorkoutItem]] = [:] // 日付ごとのワークアウトアイテムを格納する辞書
    var selectedDate: Date // 選択された日付を受け取る
    
    // ボディ部分
    var body: some View {
        VStack {
            // データを表示するForEach
            ScrollView {
                VStack(alignment: .leading) {
                    if workoutItems.isEmpty {
                        Text("Selected date does not have any training records.")
                            .font(.body) // フォントをbodyに設定
                            .padding()
                    } else {
                        ForEach(workoutItems.keys.sorted(), id: \.self) { key in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(key)
                                    .font(.headline)
                                    .padding(.leading, 10)
                                    .padding(.top, 10)
                                ForEach(workoutItems[key]!, id: \.id) { item in
                                    VStack(alignment: .leading, spacing: 5) {
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
                                    }
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
        }
        .onAppear {
            // UserDefaultsからデータを取得してworkoutItemsに格納
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
        var itemsDictionary: [String: [WorkoutItem]] = [:]
        
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
                    
                    // ワークアウトアイテムを作成して辞書に追加
                    let workoutItem = WorkoutItem(date: dateString, time: time, menu: menu, weight: weight, unit: unit, reps: reps)
                    if itemsDictionary[dateString] != nil {
                        itemsDictionary[dateString]!.append(workoutItem)
                    } else {
                        itemsDictionary[dateString] = [workoutItem]
                    }
                }
            }
        }
        
        workoutItems = itemsDictionary
    }
}


#Preview {
    HistoryView(selectedDate: Date())
}
