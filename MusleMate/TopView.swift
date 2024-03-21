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
        "Workout Log",
        "Graphs",
        "Settings"
    ]
    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                NavigationLink(destination: destinationView(for: item)) {
                    Text(item)
                }
            }
            .navigationTitle("MasleMate")
        }
    }
    
    // 遷移先のViewを選択肢に応じて切り替える関数
    private func destinationView(for item: String) -> some View {
        switch item {
        case "Workout Menu":
            return AnyView(ContentView())
        default:
            return AnyView(Text("Under Construction")) // その他の場合は仮のViewを表示
        }
    }
}


#Preview {
    TopView()
}
