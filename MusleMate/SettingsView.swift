//
//  SettingsView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/05.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading) { // Align content to the top
            List {
                NavigationLink(destination: ContentView()) {
                    Text("Workout Menu")
                }
                Button(action: {
                    // "Update"がタップされたときに処理を実行
                    DataSynchronization.printUserDefaultsItems()
                }) {
                    Text("Update")
                }
                Text("Others")
            }
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
