//
//  SplashView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/04/05.
//
import SwiftUI

struct SplashView: View {
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            ZStack {
                // 背景色を指定
                Color(UIColor(red: 252/255, green: 247/255, blue: 44/255, alpha: 1.0))
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea() // ステータスバーまで塗り潰すために必要
                Image("splash_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            TopView()
        }
    }
}

#Preview {
    SplashView()
}
