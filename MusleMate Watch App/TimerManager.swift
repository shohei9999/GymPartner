//
//  TimerManager.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/04/10.
//

// TimerManager.swift
import UserNotifications
import SwiftUI
import Combine
import WatchKit

class TimerManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    let extendedRuntimeSession = ExtendedRuntimeSession()
    
    // タイマーの状態を監視するプロパティ
    @Published var timerFinished = false
    @Published var remainingTime: TimeInterval = 0 // タイマーの残り時間を管理するプロパティ
    private var timer: Timer? // タイマーを保持するプロパティ
    
    override init() {
        super.init()
        // 通知の許可をリクエスト
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }

    func startTimer(duration: TimeInterval) {
        print("start timer")
        extendedRuntimeSession.startSession()
        
        remainingTime = duration // 残り時間を設定
        
        // タイマーの更新ロジック
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1 // 1秒減らす
            } else {
                self.timerDidFinish()
                timer.invalidate() // タイマーを停止
            }
        }
    }

    func stopTimer() {
        timer?.invalidate() // タイマーを停止
        remainingTime = 0 // 残り時間をリセット
    }

    func timerDidFinish() {
        // タイマーが終了したことを示すプロパティを更新
        timerFinished = true
        
        // Finish the extended runtime session
        extendedRuntimeSession.endSession()
        
        // ハプティックフィードバックを再生
        playHapticFeedback()
    }
    
    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.notification)
    }
}
