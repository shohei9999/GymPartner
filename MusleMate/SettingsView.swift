//
//  SettingsView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/05.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
//        NavigationView {
            VStack(alignment: .leading) { // Align content to the top
                List {
                    NavigationLink(destination: ContentView()) {
                        Text("Workout Menu")
                    }
                    Text("Others")
                }
//            }
//            .navigationTitle("Settings")
        }
        .navigationBarTitle("Settings")
    }
}


#Preview {
    SettingsView()
}
