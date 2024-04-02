//
//  TopView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI

struct TopView: View {
    @State private var items = [
        "Workout Menu",
        "Record Your Workout",
        "Workout Log",
        "Graphs",
        "Settings"
    ]
    
    // 受信したデータを保持する配列
    @StateObject private var sessionDelegate = DataTransferManager(userDefaultsKey: "receivedData") // DataTransferManagerの初期化時にuserDefaultsKeyを渡す

    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                NavigationLink(destination: destinationView(for: item)) {
                    Text(item)
                }
            }
            .navigationTitle("MasleMate")
        }.onAppear {
            // WCSessionを有効化し、受信処理を開始する
            sessionDelegate.activateSession()
        }

    }
    
    // 遷移先のViewを選択肢に応じて切り替える関数
    private func destinationView(for item: String) -> some View {
        switch item {
        case "Workout Menu":
            return AnyView(ContentView())
        case "Record Your Workout":
            return AnyView(RecordWorkoutView())
        case "Workout Log":
            return AnyView(HistoryView())
        default:
            return AnyView(Text("Under Construction")) // その他の場合は仮のViewを表示
        }
    }
}

#Preview {
    TopView()
}
