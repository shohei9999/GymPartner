//
//  TopView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI

struct TopView: View {
    @State private var selectedTab = 1
    @State private var isShowingContentView = false
    @State private var isShowingHistoryView = false
    @State private var isShowingTimerView = false
    // 受信したデータを保持する配列
    @StateObject private var sessionDelegate = WatchSessionDelegate(userDefaultsKey: "receivedData") // WatchSessionDelegateの初期化時にuserDefaultsKeyを渡す

    var body: some View {
        NavigationView {
            VStack {
                // TabViewをNavigationViewの外に配置
                TabView(selection: $selectedTab) {
                    HistoryView()
                        .environmentObject(sessionDelegate) // WatchSessionDelegateをHistoryViewに渡す
                        .tabItem {
                            Image(systemName: "book.pages.fill")
                            Text("History")
                        }
                        .tag(0)
                    ContentView()
                        .environmentObject(sessionDelegate)
                        .tabItem {
                            Image(systemName: "dumbbell.fill")
                            Text("Workout")
                        }
                        .tag(1)
                    TimerView()
                        .environmentObject(sessionDelegate)
                        .tabItem {
                            Image(systemName: "timer")
                            Text("Timer")
                        }
                        .tag(2)
                }
            }
        }
        .onAppear {
            // WCSessionを有効化し、受信処理を開始する
            sessionDelegate.activateSession()
        }
    }
}


#Preview {
    TopView()
}
