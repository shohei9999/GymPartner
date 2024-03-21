//
//  TopView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//

import SwiftUI

struct TopView: View {
    @State private var isShowingContentView = false
    
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
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 30))
                    .padding()
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                // アイコン3
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 30))
                    .padding()
                
                Spacer()
            }
            
            Spacer()
        }
        .fullScreenCover(isPresented: $isShowingContentView, content: {
            ContentView()
        })
    }
}

#Preview {
    TopView()
}
