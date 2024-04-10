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
    @State private var isShowingTimerView = false
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
                Image(systemName: "timer")
                    .font(.system(size: 30))
                    .padding()
                    .onTapGesture {
                        isShowingTimerView = true
                    }
                
                Spacer()
            }
            
            Spacer()
            
            // アイコン3
            Image(systemName: "book.pages.fill")
                .font(.system(size: 30))
                .padding()
                .onTapGesture {
                    isShowingHistoryView = true
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
        .fullScreenCover(isPresented: $isShowingTimerView, content: {
            TimerView()
                .environmentObject(sessionDelegate)
        })
        .onAppear {
            // WCSessionを有効化し、受信処理を開始する
            sessionDelegate.activateSession()
        }
    }
}

#Preview {
    TopView()
}
