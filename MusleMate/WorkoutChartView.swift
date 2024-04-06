//
//  WorkoutChartView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/04.
//
import SwiftUI
import Charts

// データモデル
struct LineData: Identifiable {
    var id = UUID()
    var Date: String
    var totalWeightReps: Int
}

struct WorkoutChartView: View {
    // UserDefaultsから取得したワークアウト日付を使用
    let workoutDates: [String] = getWorkoutDatesFromUserDefaults()
    
    // ワークアウト日付と合計重量 x レップ数を元にLineDataを生成
    var lineData: [LineData] {
        var data: [LineData] = []
        for date in workoutDates {
            let totalWeightReps = getTotalWeightRepsForDate(date)
            data.append(LineData(Date: formatDate(date), totalWeightReps: totalWeightReps))
        }
        return data
    }
    
    // 日付を "M/d" 形式にフォーマットする関数
    private func formatDate(_ date: String) -> String {
        let components = date.components(separatedBy: "/")
        if components.count >= 3 {
            var month = components[1]
            if month.hasPrefix("0") {
                month.removeFirst()
            }
            var day = components[2]
            if day.hasPrefix("0") {
                day.removeFirst()
            }
            return month + "/" + day
        }
        return date
    }

    
    var body: some View {
        if lineData.isEmpty {
            Text("No data available")
        } else {
            Chart(lineData) { dataRow in
                LineMark (
                    x: .value("workoutDate", dataRow.Date), // ワークアウト日付を横軸に設定
                    y: .value("Total Weight x Reps", dataRow.totalWeightReps)
                )
            }
            .frame(height: 300)
        }
    }
}

// UserDefaultsからワークアウト情報を取得して、weightとrepsを乗算し、合計値を返す関数
func getTotalWeightRepsForDate(_ date: String) -> Int {
    // UserDefaultsからデータを取得し、weightとrepsを乗算して合計値を計算
    let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter({ $0.hasPrefix("workout_\(date)") })
    var totalWeightReps = 0
    for key in keys {
        if let workoutData = UserDefaults.standard.object(forKey: key) as? [String: Int] {
            if let weight = workoutData["weight"], let reps = workoutData["reps"] {
                totalWeightReps += weight * reps
            }
        }
    }
    return totalWeightReps
}

func getWorkoutDatesFromUserDefaults() -> [String] {
    // UserDefaultsからデータを取得し、ワークアウト日付を抽出
    let workoutDates = UserDefaults.standard.dictionaryRepresentation().keys.filter({ $0.hasPrefix("workout_") }).map { String($0) }
    
    var formattedDates: Set<String> = Set()
    
    // ワークアウト日付からyyyyMMddを取り出す
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    
    for workoutDate in workoutDates {
        if let date = dateFormatter.date(from: workoutDate.replacingOccurrences(of: "workout_", with: "")) {
            let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
            formattedDates.insert(formattedDate)
        }
    }
    
    // Setを配列に変換して、日付の小さい順にソート
    var sortedDates = Array(formattedDates)
    sortedDates.sort()
    print("formattedDates: \(sortedDates)")

    return sortedDates
}

#Preview {
    WorkoutChartView()
}
