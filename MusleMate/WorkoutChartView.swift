//
//  WorkoutChartView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/04.
//

import SwiftUI
import Charts

struct WorkoutChartView: View {
    @StateObject private var sessionDelegate = DataTransferManager(userDefaultsKey: "receivedData")
    @State private var chartData: LineChartData?

    var body: some View {
        VStack {
            if let data = chartData {
                LineChartView(data: data)
                    .frame(height: 300)
                    .padding()
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            generateChartData()
        }
    }

    private func generateChartData() {
        guard let userDefaultsData = UserDefaults.standard.dictionaryRepresentation() else {
            return
        }

        var entries: [ChartDataEntry] = []
        var dataSet: LineChartDataSet?

        for (key, value) in userDefaultsData {
            if key.hasPrefix("workout_") {
                let components = key.components(separatedBy: "_")
                if components.count > 1, let date = components.last {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddHHmmss"
                    if let workoutDate = dateFormatter.date(from: date) {
                        let workoutDateString = DateFormatter.localizedString(from: workoutDate, dateStyle: .short, timeStyle: .none)

                        // Calculate weight * reps and convert to pounds if unit is kg
                        var result: Double = 0
                        if let workoutData = value as? [String: Any],
                           let weight = workoutData["weight"] as? Double,
                           let reps = workoutData["reps"] as? Int,
                           let unit = workoutData["unit"] as? String {
                            if unit == "kg" {
                                result = weight * Double(reps) * 2.2046
                            } else {
                                result = weight * Double(reps)
                            }
                        }

                        let entry = ChartDataEntry(x: Double(workoutDateString) ?? 0, y: result)
                        entries.append(entry)
                    }
                }
            }
        }

        dataSet = LineChartDataSet(entries: entries)
        dataSet?.label = "Workout Data"
        dataSet?.colors = [NSUIColor.blue]

        if let dataSet = dataSet {
            let chartData = LineChartData(dataSet: dataSet)
            self.chartData = chartData
        }
    }
}

#Preview {
    WorkoutChartView()
}
