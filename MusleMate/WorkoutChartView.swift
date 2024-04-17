//
//  WorkoutChartView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/04.
//
import SwiftUI
import DGCharts

struct WorkoutChartView: View {
    @State private var selectedWeek: Date = Date()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self.selectedWeek)!
                }) {
                    Image(systemName: "chevron.left")
                }
                Text(getDateRange())
                    .font(.title)
                    .padding()
                Button(action: {
                    self.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self.selectedWeek)!
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            LineChart(dataPoints: generateDataPoints())
                .frame(height: 300)
        }
    }
    
    func getDateRange() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedWeek)
        let daysToMonday = (weekday == 1 ? 6 : weekday - 2) // 今日から月曜日までの日数
        let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 追加
        
        return "\(dateFormatter.string(from: monday))-\(dateFormatter.string(from: sunday))"
    }
    
    func generateDataPoints() -> [DataPoint] {
        let dummyData: [(String, String, Int)] = [
            ("20240413", "squat", 200), // 土
            ("20240414", "squat", 300), // 日
            ("20240415", "squat", 350), // 月
            ("20240416", "squat", 450), // 火
            ("20240417", "squat", 500), // 水
            ("20240418", "squat", 350), // 木
            ("20240419", "squat", 500), // 金
            ("20240420", "squat", 600), // 土
            ("20240421", "squat", 700),
            ("20240422", "squat", 800),
            ("20240423", "squat", 900),
            ("20240424", "squat", 1000),
            ("20240425", "squat", 1100),
            ("20240426", "squat", 1200),
            ("20240427", "squat", 1300),
            ("20240428", "squat", 1400),
            ("20241019", "squat", 1500),
            ("20240413", "chestPress", 100),
            ("20240414", "chestPress", 110),
            ("20240415", "chestPress", 120),
            ("20240416", "chestPress", 130),
            ("20240417", "chestPress", 140),
            ("20240418", "chestPress", 150),
            ("20240419", "chestPress", 160),
            ("20240420", "chestPress", 170),
            ("20240421", "chestPress", 100),
            ("20240422", "chestPress", 110),
            ("20240423", "chestPress", 120),
            ("20240424", "chestPress", 130),
            ("20240425", "chestPress", 140),
            ("20240426", "chestPress", 150),
            ("20240427", "chestPress", 160),
            ("20240428", "chestPress", 170),
            ("20240515", "chestPress", 600),
            ("20240615", "chestPress", 700),
            ("20240815", "chestPress", 800),
            ("20240915", "chestPress", 900),
            ("20241015", "chestPress", 1000)
        ]
        
        var dataPoints: [DataPoint] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 追加
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedWeek)
        let daysToMonday = (weekday == 1 ? 6 : weekday - 2) // 今日から月曜日までの日数
        let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!
        let mondayWithoutTime = calendar.startOfDay(for: monday) // 追加

        // ダミーデータからデータを抽出
        var data: [String: [ChartDataEntry]] = [:]
        for (date, menu, totalWeight) in dummyData {
            let dateValue = calendar.startOfDay(for: dateFormatter.date(from: date)!)
            let daysFromMonday = calendar.dateComponents([.day], from: mondayWithoutTime, to: dateValue).day! // 修正
            if daysFromMonday >= 0 && daysFromMonday <= 6 {
                let dataEntry = ChartDataEntry(x: Double(daysFromMonday), y: Double(totalWeight))
                if var existingData = data[menu] {
                    // すでに存在するメニューの場合は追加
                    existingData.append(dataEntry)
                    data[menu] = existingData
                } else {
                    // 新しいメニューの場合は新規作成
                    data[menu] = [dataEntry]
                }
            }
        }

        // データをDataPoint形式に変換
        for (menu, dataEntries) in data {
            let dataPoint = DataPoint(menu: menu, dataEntries: dataEntries)
            dataPoints.append(dataPoint)
        }
        
        return dataPoints
    }
}

struct DataPoint {
    let menu: String
    let dataEntries: [ChartDataEntry]
}

class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 追加
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

struct LineChart: UIViewRepresentable {
    var dataPoints: [DataPoint]
    
    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = true
        chartView.leftAxis.axisMinimum = 0 // Y軸の最小値を0に設定
        chartView.xAxis.axisMinimum = 0 // Y軸の最小値を0に設定
        chartView.xAxis.valueFormatter = DateValueFormatter() // 日付をフォーマットする
        return chartView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        var dataSets: [LineChartDataSet] = []
        
        for dataPoint in dataPoints {
            let dataSet = LineChartDataSet(entries: dataPoint.dataEntries, label: dataPoint.menu)
            dataSet.colors = [UIColor.random()]
            dataSet.circleColors = [UIColor.random()]
            dataSets.append(dataSet)
        }
        
        let calendar = Calendar.current
        let selectedWeek = Date() // 追加
        let weekday = calendar.component(.weekday, from: selectedWeek)
        let daysToMonday = (weekday == 1 ? 6 : weekday - 2) // 今日から月曜日までの日数
        let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!

        // 月曜日から日曜日までの表示に設定
        uiView.xAxis.axisMinimum = 0
        uiView.xAxis.axisMaximum = 6

        // X軸のラベルを月曜日から日曜日までの曜日に設定
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 追加
        uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: (0...6).map { (value) -> String in
            let date = calendar.date(byAdding: .day, value: value, to: monday)!
            return dateFormatter.string(from: date)
        })
        
        // Y軸の0番目に項目表示を追加
        uiView.leftAxis.axisMinimum = 0
        uiView.leftAxis.drawLabelsEnabled = true
        uiView.leftAxis.drawAxisLineEnabled = true
        uiView.leftAxis.drawGridLinesEnabled = true
        uiView.leftAxis.labelPosition = .outsideChart
        
        let chartData = LineChartData(dataSets: dataSets)
        uiView.data = chartData
        uiView.notifyDataSetChanged()
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

struct WorkoutChartView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutChartView()
    }
}
