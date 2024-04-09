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
    @State private var selectedWeight: Int = 100
    @State private var selectedUnit: String = "kg"
    @State private var selectedRep: Int = 10
    @State private var isShowingPopup = false
    @State private var remainingTime = 10 // 初期値10を追加
    @State private var timer: Timer? // 追加
    
    // WatchSessionDelegateを環境オブジェクトとして宣言
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate
    
    // itemName を受け取るイニシャライザを追加
    init(itemName: String) {
        self.itemName = itemName
    }
    
    var alarmPlayer: AVAudioPlayer? // アラーム音のプレイヤー
    
    init() {
        // 初期化の中で alarmPlayer をセットアップ
        if let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3") {
            do {
                self.alarmPlayer = try AVAudioPlayer(contentsOf: url)
                self.alarmPlayer?.prepareToPlay()
            } catch {
                print("Failed to load alarm sound: \(error)")
                self.alarmPlayer = nil
            }
        } else {
            self.alarmPlayer = nil
        }
        
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
                    saveDataToUserDefaults()
                    sessionDelegate.sendMessageToiPhone()
                    isShowingPopup = true
                }
                .padding()
                
            }
        }
        .navigationTitle(itemName)
        .sheet(isPresented: $isShowingPopup, onDismiss: {
            // シートが閉じられた際にタイマーをキャンセルする
            self.timer?.invalidate()
        }) {
            TimerModalView(alarmPlayer: alarmPlayer, remainingTime: $remainingTime, isShowingPopup: $isShowingPopup, timer: $timer)
        }
        .onAppear {
            loadDataFromUserDefaults()
        }
    }
    
    private func saveDataToUserDefaults() {
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

struct TimerModalView: View {
    let alarmPlayer: AVAudioPlayer?
    @Binding var remainingTime: Int
    @Binding var isShowingPopup: Bool // シートが表示されているかどうかの状態を追加
    @Binding var timer: Timer? // タイマーを受け取る
    
    init(alarmPlayer: AVAudioPlayer?, remainingTime: Binding<Int>, isShowingPopup: Binding<Bool>, timer: Binding<Timer?>) {
        self.alarmPlayer = alarmPlayer
        self._remainingTime = remainingTime
        self._isShowingPopup = isShowingPopup // 追加
        self._timer = timer // 追加
    }
    
    var body: some View {
        DigitalTimerView(alarmPlayer: alarmPlayer, remainingTime: $remainingTime, isShowingPopup: $isShowingPopup, timer: $timer) // 修正
    }
}


struct DigitalTimerView: View {
    let alarmPlayer: AVAudioPlayer?
    @Binding var remainingTime: Int
    @Binding var isShowingPopup: Bool // シートが表示されているかどうかの状態を追加
    @Binding var timer: Timer? // タイマーを受け取る
    
    @State private var showAlert = false
    @State private var isBlinking = false
    
    var body: some View {
        Text(timeString(time: remainingTime))
            .font(.system(size: 64))
            .foregroundColor(isBlinking ? .clear : (remainingTime == 0 ? .red : .yellow))
            .onAppear {
                startTimer()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Time's up!"), message: Text("Your timer has ended."), dismissButton: .default(Text("OK")) {
                    // "OK" ボタンが選択されたときの処理
                    // isShowingPopupの状態をfalseに設定してシートを閉じる
                    self.isShowingPopup = false
                    self.remainingTime = 10 // 初期値にリセット
                })
            }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if remainingTime > 0 {
                remainingTime -= 1
                if remainingTime == 0 {
                    playAlarm()
                    WKInterfaceDevice.current().play(.notification) // バイブレーションをトリガー
                    isBlinking.toggle()
                    showAlert.toggle()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func playAlarm() {
        alarmPlayer?.play()
    }
}

#Preview {
    WeightsAndTimesView()
}
