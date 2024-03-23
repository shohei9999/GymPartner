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
    let time: String
    let menu: String
    let weight: Int
    let unit: String
}

struct HistoryView: View {
    // WorkoutItem型の配列を格納するプロパティ
    @State private var workoutItems: [WorkoutItem] = []
    @State private var selectedDate = Date() // 選択された日付
    @State private var memoText = "" // メモのテキスト

    // ボディ部分
    var body: some View {
        VStack {
            // カレンダー
            DatePicker("Selected Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            // ヘッダー
            HStack {
                Text("Time").frame(maxWidth: .infinity)
                Text("Menu").frame(maxWidth: .infinity)
                Text("Weight").frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            // データを表示するForEach
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(workoutItems) { item in
                        HStack {
                            Text(item.time).frame(maxWidth: .infinity)
                            Text(item.menu).frame(maxWidth: .infinity)
                            Text("\(item.weight) \(item.unit)").frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // メモ入力欄
            TextEditor(text: $memoText)
                .frame(height: 100)
                .padding()
        }
        .navigationTitle("Workout History")
        .onAppear {
            // UserDefaultsからデータを取得してworkoutItemsに格納
            loadDataFromUserDefaults()
        }
    }

    // UserDefaultsからデータを取得してworkoutItemsに格納するメソッド
    private func loadDataFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        
        // workout_から始まるキーをフィルタリングしてソート
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.starts(with: "workout_") }.sorted()

        var items: [WorkoutItem] = []

        for key in keys {
            // キーが"workout_"で始まり、かつ対応するデータが存在する場合にのみ処理を行う
            if let data = userDefaults.dictionary(forKey: key) {
                // 各値を取得し、nilの場合はデフォルト値を設定する
                let menu = data["menu"] as? String ?? ""
                let weight = data["weight"] as? Int ?? 0
                let unit = data["unit"] as? String ?? ""
                
                // 時刻の取得
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                if let date = dateFormatter.date(from: String(key.suffix(14))) {
                    dateFormatter.dateFormat = "HH:mm:ss"
                    let time = dateFormatter.string(from: date)
                    // ワークアウトアイテムを作成してリストに追加
                    items.append(WorkoutItem(time: time, menu: menu, weight: weight, unit: unit))
                }
            }
        }

        workoutItems = items
    }
}


#Preview {
    HistoryView()
}
