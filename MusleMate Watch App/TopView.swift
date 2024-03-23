//
//  TopView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI

struct TopView: View {
    @State private var isShowingContentView = false
    @State private var isShowingHistoryView = false // 履歴画面表示制御
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
            sessionDelegate.sendMessageToiPhone()
        }
    }
}

#Preview {
    TopView()
}
