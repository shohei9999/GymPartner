//
//  WorkoutChartView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/04.
//
import SwiftUI
import DGCharts

enum Period: String, CaseIterable { // 追加
//    case day, week, month, year
    case week, month
}

struct WorkoutChartView: View {
    @State private var selectedWeek: Date = Date()
    @State private var dataPoints: [DataPoint] = []
    @State private var selectedMenu: String = "all"
    @State private var chartId = UUID()
    @State private var isKg: Bool = true {
        didSet {
            self.dataPoints = self.generateDataPoints()
            self.chartId = UUID()
        }
    }
    @State private var selectedPeriod: Period = .week
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Period.allCases, id: \.self) { period in
                    Button(action: {
                        withAnimation {
                            self.selectedPeriod = period
                            if period == .month {
                                // 月を選択した場合、今月の1日から月末までの期間に設定する
                                let calendar = Calendar.current
                                let components = calendar.dateComponents([.year, .month], from: Date())
                                let startOfMonth = calendar.date(from: components)!
                                let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
                                self.selectedWeek = startOfMonth
                            } else if period == .week {
                                // 週を選択した場合、今日を含む1週間の期間に設定する
                                let calendar = Calendar.current
                                let today = calendar.startOfDay(for: Date())
                                let weekday = calendar.component(.weekday, from: today)
                                let daysToMonday = (weekday == 1 ? 6 : weekday - 2)
                                let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today)!
                                self.selectedWeek = monday
                            }
                            self.dataPoints = self.generateDataPoints()
                            self.chartId = UUID()
                        }
                    }) {
                        Text(period.rawValue.capitalized)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(self.selectedPeriod == period ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            )
                    }
                }
            }
            Toggle(isOn: $isKg) {
                Text("Unit: \(isKg ? "Kg" : "Lb")")
            }
            .padding()
            .onChange(of: isKg) { _ in
                self.dataPoints = self.generateDataPoints()
                self.chartId = UUID()
            }
            if selectedPeriod != .month {
                HStack {
                    Button(action: {
                        self.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self.selectedWeek)!
                        self.dataPoints = self.generateDataPoints()
                        self.chartId = UUID()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    Text(getDateRange())
                        .font(.title)
                        .padding()
                    Button(action: {
                        self.selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self.selectedWeek)!
                        self.dataPoints = self.generateDataPoints()
                        self.chartId = UUID()
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            else {
                let year = Calendar.current.component(.year, from: selectedWeek)
                let formattedYear = String(year)
                let month = Calendar.current.component(.month, from: selectedWeek)
                HStack {
                    Button(action: {
                        self.selectedWeek = Calendar.current.date(byAdding: .month, value: -1, to: self.selectedWeek)!
                        self.dataPoints = self.generateDataPoints()
                        self.chartId = UUID()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    Text("\(formattedYear)/\(month)")
                        .font(.title)
                        .padding()
                    Button(action: {
                        self.selectedWeek = Calendar.current.date(byAdding: .month, value: 1, to: self.selectedWeek)!
                        self.dataPoints = self.generateDataPoints()
                        self.chartId = UUID()
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            HStack {
                Text("Max: \(Int(getMaxValue()))")
                Text("Avg: \(Int(getAvgValue()))")
                Text("Min: \(Int(getMinValue()))")
            }
            .padding()
            LineChart(dataPoints: selectedMenu == "all" ? dataPoints : dataPoints.filter { $0.menu == selectedMenu }, isKg: isKg, selectedPeriod: selectedPeriod, selectedWeek: selectedWeek)
                .frame(height: 300)
                .id(chartId)
            Picker("Menu", selection: $selectedMenu) {
                ForEach(getMenus(), id: \.self) { menu in
                    Text(menu).tag(menu)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
        .onAppear {
            self.dataPoints = self.generateDataPoints()
        }
    }
    
    func getDateRange() -> String {
        if selectedPeriod == .month {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedWeek)
            let startOfMonth = calendar.date(from: components)!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            return "\(dateFormatter.string(from: startOfMonth))-\(dateFormatter.string(from: endOfMonth))"
        } else {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: selectedWeek)
            let daysToMonday = (weekday == 1 ? 6 : weekday - 2)
            let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!
            let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            return "\(dateFormatter.string(from: monday))-\(dateFormatter.string(from: sunday))"
        }
    }

    
    func generateDataPoints() -> [DataPoint] {
        // UserDefaultからデータを取得
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("workout_") }
        
        var dataPoints: [DataPoint] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 追加
        
        var data: [String: [ChartDataEntry]] = [:]
        
        if selectedPeriod == .month {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedWeek)
            let startOfMonth = calendar.date(from: components)!
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1, hour: 23, minute: 59, second: 59), to: startOfMonth)!

            print("Start of Month: \(startOfMonth)")
            print("End of Month: \(endOfMonth)")
            
            for key in keys {
                let dateStr = String(key.dropFirst(8)).prefix(8)
                if let date = dateFormatter.date(from: String(dateStr)) {
                    if date >= startOfMonth && date <= endOfMonth {
                        print("date: \(date)")
                        let workoutData = userDefaults.dictionary(forKey: key)!
                        let menu = workoutData["menu"] as! String
                        var weight = workoutData["weight"] as! Double
                        let reps = workoutData["reps"] as! Double
                        weight *= reps
                        let unit = workoutData["unit"] as! String
                        if unit == "kg" && !isKg {
                            weight *= 2.20462
                        } else if unit == "lb" && isKg {
                            weight /= 2.20462
                        }
                        weight = round(weight)
                        let secondsPerDay = 24.0 * 60.0 * 60.0
                        let dataEntry = ChartDataEntry(x: date.timeIntervalSince(startOfMonth) / secondsPerDay, y: weight)
                        print("Data entry created with x = \(dataEntry.x) and y = \(dataEntry.y)")
                        if var existingData = data[menu] {
                            if let index = existingData.firstIndex(where: { $0.x == dataEntry.x }) {
                                existingData[index].y += dataEntry.y
                            } else {
                                existingData.append(dataEntry)
                            }
                            existingData.sort { $0.x < $1.x }
                            data[menu] = existingData
                        } else {
                            data[menu] = [dataEntry]
                        }
                    }
                } else {
                    print("Invalid date format: \(dateStr)")
                }
            }
        } else {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: selectedWeek)
            let daysToMonday = (weekday == 1 ? 6 : weekday - 2)
            let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!
            let mondayWithoutTime = calendar.startOfDay(for: monday)
            
            for key in keys {
                let dateStr = String(key.dropFirst(8)).prefix(8)
                if let date = dateFormatter.date(from: String(dateStr)) {
                    let dateValue = calendar.startOfDay(for: date)
                    let daysFromMonday = calendar.dateComponents([.day], from: mondayWithoutTime, to: dateValue).day!
                    if daysFromMonday >= 0 && daysFromMonday <= 6 {
                        let workoutData = userDefaults.dictionary(forKey: key)!
                        let menu = workoutData["menu"] as! String
                        var weight = workoutData["weight"] as! Double
                        let reps = workoutData["reps"] as! Double
                        weight *= reps
                        let unit = workoutData["unit"] as! String
                        if unit == "kg" && !isKg {
                            weight *= 2.20462
                        } else if unit == "lb" && isKg {
                            weight /= 2.20462
                        }
                        weight = round(weight)
                        let dataEntry = ChartDataEntry(x: Double(daysFromMonday), y: weight)
                        if var existingData = data[menu] {
                            if let index = existingData.firstIndex(where: { $0.x == dataEntry.x }) {
                                existingData[index].y += dataEntry.y
                            } else {
                                existingData.append(dataEntry)
                            }
                            existingData.sort { $0.x < $1.x }
                            data[menu] = existingData
                        } else {
                            data[menu] = [dataEntry]
                        }
                    }
                } else {
                    print("Invalid date format: \(dateStr)")
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


    
    func getMenus() -> [String] { // 追加
        var menus: [String] = ["all"]
        menus.append(contentsOf: dataPoints.map { $0.menu })
        return menus
    }
    
    func getMaxValue() -> Double {
        let filteredDataPoints = selectedMenu == "all" ? dataPoints : dataPoints.filter { $0.menu == selectedMenu }
        let maxValue = filteredDataPoints.flatMap { $0.dataEntries }.map { $0.y }.max() ?? 0
        return floor(maxValue)
    }

    func getAvgValue() -> Double {
        let filteredDataPoints = selectedMenu == "all" ? dataPoints : dataPoints.filter { $0.menu == selectedMenu }
        let dataEntries = filteredDataPoints.flatMap { $0.dataEntries }
        let avgValue = dataEntries.count > 0 ? dataEntries.map { $0.y }.reduce(0, +) / Double(dataEntries.count) : 0
        return floor(avgValue)
    }

    func getMinValue() -> Double {
        let filteredDataPoints = selectedMenu == "all" ? dataPoints : dataPoints.filter { $0.menu == selectedMenu }
        let minValue = filteredDataPoints.flatMap { $0.dataEntries }.map { $0.y }.min() ?? 0
        return floor(minValue)
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
    var isKg: Bool
    var selectedPeriod: Period
    var selectedWeek: Date?

    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = true
        chartView.leftAxis.axisMinimum = 0
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.valueFormatter = DateValueFormatter()
        return chartView
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {
        var dataSets: [LineChartDataSet] = []

        for dataPoint in dataPoints {
            print("DataPoint: \(dataPoint.menu), Number of entries: \(dataPoint.dataEntries.count)")
            let dataSet = LineChartDataSet(entries: dataPoint.dataEntries, label: dataPoint.menu)
            dataSet.colors = [UIColor.random()]
            dataSet.circleColors = [UIColor.random()]
            dataSets.append(dataSet)
        }

        if selectedPeriod == .week {
           let calendar = Calendar.current
           let selectedWeek = self.selectedWeek ?? Date()
           let weekday = calendar.component(.weekday, from: selectedWeek)
           let daysToMonday = (weekday == 1 ? 6 : weekday - 2)
           let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: selectedWeek)!

           uiView.xAxis.axisMinimum = 0
           uiView.xAxis.axisMaximum = 6

           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "E"
           dateFormatter.locale = Locale(identifier: "en_US_POSIX")
           uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: (0...6).map { (value) -> String in
               let date = calendar.date(byAdding: .day, value: value, to: monday)!
               return dateFormatter.string(from: date)
           })
        } else if selectedPeriod == .month {
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedWeek ?? Date()))!
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
            let numDays = range.count

            print("Number of days in the month: \(numDays)")

            uiView.xAxis.axisMinimum = 0
            let numDaysInMonth = range.count
            uiView.xAxis.axisMaximum = Double(numDays - 1)
            uiView.xAxis.labelCount = 7

            print("Axis minimum: \(uiView.xAxis.axisMinimum), Axis maximum: \(uiView.xAxis.axisMaximum)")

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: (1...numDays).map { (value) -> String in
                let date = calendar.date(byAdding: .day, value: value - 1, to: startOfMonth)!
                let dateString = dateFormatter.string(from: date)
                print("Mapping value \(value) to date: \(dateString)")
                return dateString
            })
        }

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
