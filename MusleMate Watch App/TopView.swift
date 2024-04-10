//
//  TopView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI
import Foundation

struct TopView: View {
    @State private var isShowingContentView = false
    @State private var isShowingHistoryView = false
    @ObservedObject var timerManager = TimerManager()
    @State private var showAlert = false
    // 受信したデータを保持する配列
    @StateObject private var sessionDelegate = WatchSessionDelegate(userDefaultsKey: "receivedData") // WatchSessionDelegateの初期化時にuserDefaultsKeyを渡す

    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // アイコン1
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 30))
                    .padding()
                    .onTapGesture {
                        isShowingContentView = true
                    }
                
                Spacer()

                // アイコン2
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 30))
                    .padding()
                    .onTapGesture {
                        isShowingHistoryView = true
                    }
                
                Spacer()

                Button("timer") {
                    timerManager.startTimer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Timer Finished"), message: Text("1 minute timer has finished."), dismissButton: .default(Text("OK")))
                }

                Spacer()
            }
            
            Spacer()
        }
        .fullScreenCover(isPresented: $isShowingContentView, content: {
            ContentView()
                .environmentObject(sessionDelegate) // WatchSessionDelegateをContentViewに渡す
        })
        .fullScreenCover(isPresented: $isShowingHistoryView, content: {
            HistoryView()
                .environmentObject(sessionDelegate) // WatchSessionDelegateをHistoryViewに渡す
        })
        .onAppear {
            // WCSessionを有効化し、受信処理を開始する
            sessionDelegate.activateSession()
            
            // iPhoneにメッセージを送信する
//            sessionDelegate.sendMessageToiPhone()
        }
    }
}

#Preview {
    TopView()
}
