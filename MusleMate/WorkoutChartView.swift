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
    var date: String
    var totalWeightReps: Int
}

struct WorkoutData: Identifiable {
    var id = UUID()
    var date: String
    var totalWeight: Int
}

struct WorkoutChartView: View {
    // 選択された期間を保持するenum
    enum SelectedPeriod {
        case week, month, year
    }
    
    // UserDefaultsから取得したワークアウト情報を使用
    let workoutData: [(date: String, totalWeight: Int)] = getWorkoutDataFromUserDefaults()
    
    // 選択された期間を保持するState
    @State private var selectedPeriod: SelectedPeriod? = .week
    
    // ワークアウト日付と合計重量 x レップ数を元にLineDataを生成
    var lineData: [LineData] {
        var data: [LineData] = []
        for workout in workoutData {
            let totalWeightReps = workout.totalWeight
            data.append(LineData(date: formatDate(workout.date), totalWeightReps: totalWeightReps))
        }
        return data
    }
    
    var body: some View {
        VStack {
            // 選択項目を表示
            HStack(spacing: 20) {
                Text("週")
                    .padding(10)
                    .background(selectedPeriod == .week ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation {
                            selectedPeriod = .week
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedPeriod == .week ? Color.blue : Color.clear, lineWidth: 2)
                    )
                
                Text("月")
                    .padding(10)
                    .background(selectedPeriod == .month ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation {
                            selectedPeriod = .month
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedPeriod == .month ? Color.blue : Color.clear, lineWidth: 2)
                    )
                
                Text("年")
                    .padding(10)
                    .background(selectedPeriod == .year ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(10)
                    .onTapGesture {
                        withAnimation {
                            selectedPeriod = .year
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedPeriod == .year ? Color.blue : Color.clear, lineWidth: 2)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 2)
            )
            
            // チャート表示
            if lineData.isEmpty {
                Text("No data available")
            } else {
                Chart(lineData) { dataRow in
                    LineMark (
                        x: .value("workoutDate", formatDate(dataRow.date)), // ワークアウト日付をM/d形式にフォーマットして設定
                        y: .value("Total Weight x Reps", dataRow.totalWeightReps)
                    )
                }
                .frame(height: 300)
            }
        }
    }
}


func getWorkoutDataFromUserDefaults() -> [(date: String, totalWeight: Int)] {
    var workoutData: [(date: String, totalWeight: Int)] = []
    
    // UserDefaultsからデータを取得し、日付と関連するweightとrepsを取得
    let keys = UserDefaults.standard.dictionaryRepresentation().keys
        .filter({ $0.hasPrefix("workout_") })
        .sorted() // キーを昇順で並べ替える
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    
    for key in keys {
        guard let workoutDictionary = UserDefaults.standard.dictionary(forKey: key) else {
            print("Failed to get workout data for key:", key)
            continue
        }
        
        // keyからyyyyMMdd部分を抽出して日付とする
        guard let dateRange = key.range(of: "\\d{8}", options: .regularExpression),
              let datePart = Int(key[dateRange]) else {
            print("Failed to extract date from key:", key)
            continue
        }
        let formattedDate = String(datePart)
        // weightとrepsを合計する
        var totalWeight = 0
        if let weight = workoutDictionary["weight"] as? Int,
           let reps = workoutDictionary["reps"] as? Int {
            totalWeight = weight * reps
        } else {
            print("Weight or reps not found for key:", key)
            continue
        }
        
        // 既存の日付があれば合計にweight * repsを追加し、なければ新しいエントリを作成する
        if let index = workoutData.firstIndex(where: { $0.date == formattedDate }) {
            workoutData[index].totalWeight += totalWeight
        } else {
            workoutData.append((date: formattedDate, totalWeight: totalWeight))
        }
    }
    print("workoutData \(workoutData)")
    
    return workoutData
}

// 日付を "M/d" 形式にフォーマットする関数
private func formatDate(_ date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    if let formattedDate = dateFormatter.date(from: date) {
        dateFormatter.dateFormat = "M/d"
        return dateFormatter.string(from: formattedDate)
    }
    return date
}

#Preview {
    WorkoutChartView()
}
