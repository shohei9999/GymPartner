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
    var week: String
    var sales: Int
}

struct WorkoutChartView: View {
    let lineData_test: [LineData] = [
        .init(week: "月曜日", sales: 2000),
        .init(week: "火曜日", sales: 3000),
        .init(week: "水曜日", sales: 4000),
    ]
    
    var body: some View {
        Chart(lineData_test) { dataRow in
            LineMark (
                x: .value("week", dataRow.week),
                y: .value("Sales", dataRow.sales)
            )
        }
        .frame(height: 300)
    }
}

#Preview {
    WorkoutChartView()
}
