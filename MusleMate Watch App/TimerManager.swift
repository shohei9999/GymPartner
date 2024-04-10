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

class TimerManager: ObservableObject {
    let extendedRuntimeSession = ExtendedRuntimeSession()
    
    // タイマーの状態を監視するプロパティ
    @Published var timerFinished = false

    func startTimer() {
        print("start timer")
        extendedRuntimeSession.startSession()
        
        // 1分後にタイマーが終了するように設定
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("timer end")
            self.timerDidFinish()
        }
    }

    func timerDidFinish() {
        // タイマーが終了したことを示すプロパティを更新
        timerFinished = true
        
        // Finish the extended runtime session
        extendedRuntimeSession.endSession()
        
        // ハプティックフィードバックを再生
        playHapticFeedback()
        
        // 通知の作成
        let content = UNMutableNotificationContent()
        content.title = "タイマー終了"
        content.body = "1分のタイマーが終了しました"
        
        // 通知リクエストの作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        // 通知を登録
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知の登録に失敗しました：\(error)")
            }
        }
    }
    
    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.notification)
    }
}
