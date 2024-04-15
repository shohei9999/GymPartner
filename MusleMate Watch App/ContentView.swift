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
                Text("Please add a workout menu from your iPhone. Only menus enabled with a star will appear on the Apple Watch.")
                    .font(.body)
            } else {
                List(sessionDelegate.receivedData, id: \.self) { data in
                    NavigationLink(destination: WeightsAndTimesView(itemName: data)
                                        .environmentObject(sessionDelegate)) {
                        Text(data)
                    }
                }
            }
        }
        .onAppear {
            // UserDefaultsからデータを読み込む
            if let storedData = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
                sessionDelegate.receivedData = storedData
            }
        }
    }

}

#Preview {
    ContentView()
}

