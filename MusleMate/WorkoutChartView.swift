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
    @State private var dataPoints: [DataPoint] = [] // 追加
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self.selectedWeek)!
                    self.dataPoints = self.generateDataPoints() // データを更新
                }) {
                    Image(systemName: "chevron.left")
                }
                Text(getDateRange())
                    .font(.title)
                    .padding()
                Button(action: {
                    self.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self.selectedWeek)!
                    self.dataPoints = self.generateDataPoints() // データを更新
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            LineChart(dataPoints: dataPoints) // 修正
                .frame(height: 300)
        }
        .onAppear {
            self.dataPoints = self.generateDataPoints() // 初期表示時にデータを読み込む
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
        // UserDefaultからデータを取得
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("workout_") }
        
        var dataPoints: [DataPoint] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 追加
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedWeek)
        let daysToMonday = (weekday == 1 ? 6 : weekday - 2) // 今日から月曜日までの日数
        let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!
        let mondayWithoutTime = calendar.startOfDay(for: monday) // 追加

        // データを抽出
        var data: [String: [ChartDataEntry]] = [:]
        for key in keys {
            let dateStr = String(key.dropFirst(8)).prefix(8) // 最初の8文字だけを取り出す
            if let date = dateFormatter.date(from: String(dateStr)) {
                let dateValue = calendar.startOfDay(for: date)
                let daysFromMonday = calendar.dateComponents([.day], from: mondayWithoutTime, to: dateValue).day! // 修正
                if daysFromMonday >= 0 && daysFromMonday <= 6 {
                    let workoutData = userDefaults.dictionary(forKey: key)!
                    let menu = workoutData["menu"] as! String
                    var weight = workoutData["weight"] as! Double
                    let reps = workoutData["reps"] as! Double // 追加: repsを取得
                    weight *= reps // 追加: weightにrepsを乗算
                    let unit = workoutData["unit"] as! String
                    if unit == "kg" {
                        weight *= 2.20462 // kgをポンドに変換
                    }
                    weight = round(weight)
                    let dataEntry = ChartDataEntry(x: Double(daysFromMonday), y: weight)
                    if var existingData = data[menu] {
                        // すでに存在するメニューの場合は追加
                        if let index = existingData.firstIndex(where: { $0.x == dataEntry.x }) {
                            // 同じ日のデータが存在する場合はweightを加算
                            existingData[index].y += dataEntry.y
                        } else {
                            // 同じ日のデータが存在しない場合は新規追加
                            existingData.append(dataEntry)
                        }
                        existingData.sort { $0.x < $1.x } // xの値（日付）でソート
                        data[menu] = existingData
                    } else {
                        // 新しいメニューの場合は新規作成
                        data[menu] = [dataEntry]
                    }
                }
            } else {
                print("Invalid date format: \(dateStr)")
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
