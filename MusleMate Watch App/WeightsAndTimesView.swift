//
//  WeightsAndTimesView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI
import AVFoundation
import WatchKit

struct WeightsAndTimesView: View {
    var itemName: String
    @ObservedObject var timerManager = TimerManager()
    @State private var isTimerStarted = false // タイマーが開始されたかどうかを示すプロパティ

    @State private var selectedWeight: Int = 100
    @State private var selectedUnit: String = "kg"
    @State private var selectedRep: Int = 10
    @State private var isShowingModal = false // モーダルを表示するかどうかを制御するフラグ
    
    // PresentationModeを取得
    @Environment(\.presentationMode) var presentationMode
    
    // WatchSessionDelegateを環境オブジェクトとして宣言
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate
    
    // itemName を受け取るイニシャライザを追加
    init(itemName: String) {
        self.itemName = itemName
    }
    
    init() {
        // itemName にデフォルト値を設定
        self.itemName = "Default Item"
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Picker("Weight", selection: $selectedWeight) {
                        ForEach(0..<1000) { weight in
                            Text("\(weight)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.40)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("lb").tag("lb")
                        Text("kg").tag("kg")
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.25)
                    
                    Spacer()
                    
                    Picker("Reps", selection: $selectedRep) {
                        ForEach(0..<100) { rep in
                            Text("\(rep)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.25)
                }
                .padding()
                
                Spacer()
                
                Spacer()
                
                Button("OK") {
                    let data = prepareDataForWatch()
                    sessionDelegate.sendMessageToiPhone(with: data)
                    isShowingModal = true // モーダル表示
                }
                .padding()
                
            }
        }
        .navigationBarTitle(itemName) // タイトルを設定
        .sheet(isPresented: $isShowingModal) {
            // モーダル内部
            VStack {
                // 1段目: Next Set
                Text("More Workout?")
                    .font(.system(size: 20)) // フォントサイズを20に変更
                    .fontWeight(.bold) // フォントを太字に設定
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20)) // 上下左右のパディングを調整
                
                // 2段目: タイマー
                HStack {
                     Spacer()
                     Image(systemName: "goforward.30")
                         .font(.system(size: 40))
                         .onTapGesture {
                             timerManager.startTimer(duration: 30)
                             isTimerStarted = true
                         }
                     Spacer()
                     Image(systemName: "goforward.60")
                         .font(.system(size: 40))
                         .onTapGesture {
                             timerManager.startTimer(duration: 60)
                             isTimerStarted = true
                         }
                     Spacer()
                     Image(systemName: "goforward.90")
                         .font(.system(size: 40))
                         .onTapGesture {
                             timerManager.startTimer(duration: 90)
                             isTimerStarted = true
                         }
                     Spacer()
                 }
                 .padding()
                
                // 3段目: Endボタン
                Button("End") {
                    // モーダルを閉じる
                    isShowingModal = false
                    self.presentationMode.wrappedValue.dismiss()
                }
                .font(.title)
                .padding()
            }
            .sheet(isPresented: $isTimerStarted) {
                VStack {
                    Spacer()
                    if timerManager.remainingTime == 0 {
                        Text("Next!")
                            .font(.title)
                            .padding()
                        Button("OK") {
                            isShowingModal = false // モーダルを閉じる
                            self.presentationMode.wrappedValue.dismiss() // 表示しているすべてのモーダルを閉じる
                        }
                        .font(.title)
                        .padding()
                    } else {
                        TimerModalView(timerManager: timerManager)
                            .onDisappear {
                                timerManager.stopTimer()
                            }
                    }
                    Spacer()
                }
            }
            .onReceive(timerManager.$remainingTime) { remainingTime in
                if isTimerStarted && remainingTime == 0 {
                    // タイマーが終了したら振動を行う
                    WKInterfaceDevice.current().play(.notification)
                }
            }
        }
        .onAppear {
            loadDataFromUserDefaults()
        }
    }
        
    private func prepareDataForWatch() -> [String: Any] {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let key = "workout_\(dateFormatter.string(from: currentDate))"
        
        let value: [String: Any] = [
            "menu": itemName,
            "weight": selectedWeight,
            "unit": selectedUnit,
            "reps": selectedRep,
            "start_time": "",
            "end_time": "",
            "deleted_flg": false,
            "sendStatus": false,
        ]
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.set(selectedWeight, forKey: "\(itemName)_weight")
        UserDefaults.standard.set(selectedUnit, forKey: "\(itemName)_unit")
        UserDefaults.standard.set(selectedRep, forKey: "\(itemName)_reps")
        
        return ["key": key, "data": value]
    }

    
    private func loadDataFromUserDefaults() {
        if let weight = UserDefaults.standard.object(forKey: "\(itemName)_weight") as? Int {
            selectedWeight = weight
        }
        if let unit = UserDefaults.standard.object(forKey: "\(itemName)_unit") as? String {
            selectedUnit = unit
        }
        if let reps = UserDefaults.standard.object(forKey: "\(itemName)_reps") as? Int {
            selectedRep = reps
        }
    }
}

#Preview {
    WeightsAndTimesView()
}
