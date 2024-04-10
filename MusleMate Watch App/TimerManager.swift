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
    
    // 通知の許可が得られたかどうかを示すプロパティ
    @Published var notificationPermissionGranted = false

    override init() {
        super.init()
        // 通知の許可をリクエスト
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if granted {
                self?.notificationPermissionGranted = true
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }

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
        
        // 通知の許可が得られている場合のみ通知を送信
        if notificationPermissionGranted {
            sendNotification()
        }
    }
    
    func playHapticFeedback() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    func sendNotification() {
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
}
