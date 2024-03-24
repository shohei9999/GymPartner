//
//  ContentView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/20.
//
// ContentView.swift
import SwiftUI

struct ContentView: View {
    // UserDefaultsキー
    private let userDefaultsKey = "receivedData"
    
    // WatchSessionDelegateの単一のインスタンスを共有する
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate

    var body: some View {
        NavigationView {
            if sessionDelegate.receivedData.isEmpty {
                Text("Please add a new workout menu on your iPhone.")
                    .font(.body)
                    .navigationTitle("Workout menu")
            } else {
                List(sessionDelegate.receivedData, id: \.self) { data in
                    NavigationLink(destination: WeightsAndTimesView(itemName: data)
                                        .environmentObject(sessionDelegate)) { // WatchSessionDelegateを環境オブジェクトとして渡す
                        Text(data)
                    }
                }
                .navigationTitle("Workout menu")
            }
        }
        .padding()
        .onAppear {
            // UserDefaultsからデータを読み込む
            if let storedData = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
                sessionDelegate.receivedData = storedData
            }
            sessionDelegate.sendMessageToiPhone()
        }
    }
}

#Preview {
    ContentView()
}

