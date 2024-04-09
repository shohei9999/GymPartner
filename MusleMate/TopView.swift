//
//  TopView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI
import FSCalendar

struct TopView: View {
    @StateObject private var sessionDelegate = DataTransferManager(userDefaultsKey: "receivedData")
    @State private var selectedDate = Date()
    @State private var plusIconSelected = false
    @State private var gearIconSelected = false
    @State private var chartIconSelected = false
    @State private var isPresented = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "gearshape")
                        .padding(.trailing)
                        .font(.system(size: 24))
                        .onTapGesture {
                            gearIconSelected = true
                            plusIconSelected = false
                            chartIconSelected = false
                            isPresented = true
                        }
                    Image(systemName: "plus")
                        .onTapGesture {
                            plusIconSelected = true
                            gearIconSelected = false
                            chartIconSelected = false
                            isPresented = true
                        }
                        .padding(.trailing)
                        .font(.system(size: 24))
                }
                .padding(.top)
                
                // カレンダーと履歴ビューを再描画
                CalendarView(selectedDate: $selectedDate)
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    .id(UUID()) // データが変更されるたびに再描画をトリガー
                HistoryView()
                    .padding(.top, 10)
                    .id(UUID()) // データが変更されるたびに再描画をトリガー
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isPresented) {
                if plusIconSelected {
                    RecordWorkoutView()
                } else if gearIconSelected {
                    SettingsView()
                } else {
                    EmptyView()
                }
            }
            .navigationTitle("Top")
        }
        .onAppear {
            sessionDelegate.activateSession()
        }
        .onReceive(sessionDelegate.$receivedData) { _ in
            // データが変更されたときに再描画をトリガー
            selectedDate = Date() // カレンダーの再描画をトリガー
        }
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date // 選択された日付を保持するBinding

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        calendar.appearance.todayColor = UIColor.clear // 今日の日付の背景色を設定
        calendar.appearance.titleTodayColor = .red // 日付の文字色を青に設定
        // FSCalendarが表示されるときに処理を行う
        DispatchQueue.main.async {
            context.coordinator.getWorkoutDatesFromUserDefaults(for: calendar)
        }
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 何もする必要がないので、このメソッドは空にする
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedDate: $selectedDate)
    }

    class Coordinator: NSObject, FSCalendarDataSource, FSCalendarDelegate {
        @Binding var selectedDate: Date // 選択された日付を保持するBinding
        var uniqueDates: Set<String> = [] // 重複をまとめた日付のセット
        
        init(selectedDate: Binding<Date>) {
            _selectedDate = selectedDate
        }

        // FSCalendarのデータソースメソッド: 日付に対応するイメージを返す
        func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let image = UIImage(systemName: "trophy")?.withTintColor(.brown, renderingMode: .alwaysOriginal)
            
            // uniqueDatesに含まれる日付にはイメージを表示する
            if uniqueDates.contains(dateFormatter.string(from: date)) {
                return image
//                ?.resize(to: CGSize(width: 15, height: 15)) // シミュレータだと日付と重なるが実機だと重ならない
            }
            return nil
        }

        // ワークアウト日付を取得し、カレンダーにマークを付ける
        func getWorkoutDatesFromUserDefaults(for calendar: FSCalendar) {
            // UserDefaultsからワークアウト日付を取得
            let workoutDates = UserDefaults.standard.dictionaryRepresentation().keys.filter({ $0.hasPrefix("workout_") }).map { String($0) }
            
            // ワークアウト日付からyyyyMMddを取り出し、時、分、秒を取り除き、重複をまとめる
            for workoutDate in workoutDates {
                let dateString = workoutDate.replacingOccurrences(of: "workout_", with: "").prefix(8)
                uniqueDates.insert(String(dateString))
            }
            
            // FSCalendarを更新
            calendar.reloadData()
        }
    }
}

#Preview {
    TopView()
}
