//
//  TopView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI
import FSCalendar

struct TopView: View {
    @State private var items = [
        "Workout Menu",
        "Workout Log",
        "Graphs",
        "Settings"
    ]
    
    // 受信したデータを保持する配列
    @StateObject private var sessionDelegate = DataTransferManager(userDefaultsKey: "receivedData")
    
    @State private var selectedDate = Date()
    
    @State private var plusIconSelected = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "gearshape")
                        .padding(.trailing)
                        .font(.system(size: 24))
                    Image(systemName: "chart.bar.xaxis")
                        .padding(.trailing)
                        .font(.system(size: 24))
                    Image(systemName: "plus")
                        .onTapGesture {
                            print("plus")
                            plusIconSelected = true
                        }
                        .padding(.trailing)
                        .font(.system(size: 24))
                }
                .padding(.top)
                // カレンダーを表示
                CalendarView(selectedDate: $selectedDate)
                    .padding(.top, 10)
                
                List(items, id: \.self) { item in
                    NavigationLink(destination: destinationView(for: item)) {
                        Text(item)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: RecordWorkoutView(),
                    isActive: $plusIconSelected,
                    label: { EmptyView() }
                )
                .hidden()
            )
        }
        .onAppear {
            // WCSessionを有効化し、受信処理を開始する
            sessionDelegate.activateSession()
        }
    }
    
    private func destinationView(for item: String) -> some View {
        switch item {
        case "Workout Menu":
            return AnyView(ContentView())
        case "Workout Log":
            return AnyView(HistoryView())
        default:
            return AnyView(Text("Under Construction")) // その他の場合は仮のViewを表示
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
