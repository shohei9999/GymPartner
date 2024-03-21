//
//  WeightsAndTimesView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI

struct WeightsAndTimesView: View {
    var itemName: String // itemNameを保持するプロパティ
    @State private var selectedWeight: Int = 50
    @State private var selectedUnit: WeightUnit = .kg
    @State private var selectedRep: Int = 10 // 回数を保持するプロパティを追加
    @State private var isDoneShowing = false // Doneポップアップの表示制御
    @State private var isContentHidden = false // コンテンツの非表示制御
    
    enum WeightUnit: Int { // 列挙型WeightUnitのイニシャライザを追加
        case kg, lb
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if !isContentHidden { // コンテンツが表示されている場合
                    HStack {
                        Picker("Weight", selection: $selectedWeight) {
                            ForEach(1..<1000) { weight in
                                Text("\(weight)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: geometry.size.width * 0.40) // 画面幅の40%を使用
                        
                        Picker("Unit", selection: $selectedUnit) {
                            Text("kg").tag(WeightUnit.kg.rawValue) // rawValueを指定
                            Text("lb").tag(WeightUnit.lb.rawValue)
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: geometry.size.width * 0.25) // 画面幅の25%を使用
                        
                        Spacer() // 残りのスペースを埋めるためのSpacer
                        
                        Picker("Reps", selection: $selectedRep) {
                            ForEach(1..<100) { rep in // 1から99までの回数を選択できるようにする
                                Text("\(rep)")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: geometry.size.width * 0.25) // 画面幅の25%を使用
                    }
                    .padding()
                    
                    Spacer() // 上下の余白を調整
                    
                    Spacer() // OKボタンとDoneポップアップの間のスペースを追加
                    
                    Button("OK") {
                        saveDataToUserDefaults()
                        isContentHidden = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            // ContentViewに戻る
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .padding()
                } else { // コンテンツが非表示の場合
                    Text("Done!")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
            }
        }
        .navigationTitle(itemName)
        .onAppear {
            loadDataFromUserDefaults()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private func saveDataToUserDefaults() {
        // UserDefaultsにデータを保存
        UserDefaults.standard.set(selectedWeight, forKey: "\(itemName)_weight")
        UserDefaults.standard.set(selectedUnit.rawValue, forKey: "\(itemName)_unit")
        UserDefaults.standard.set(selectedRep, forKey: "\(itemName)_reps")
        UserDefaults.standard.set(Date(), forKey: "\(itemName)_date")
    }
    
    private func loadDataFromUserDefaults() {
        // UserDefaultsからデータを読み込む
        if let weight = UserDefaults.standard.object(forKey: "\(itemName)_weight") as? Int {
            selectedWeight = weight
        }
        if let unitRawValue = UserDefaults.standard.object(forKey: "\(itemName)_unit") as? Int,
           let unit = WeightUnit(rawValue: unitRawValue) {
            selectedUnit = unit
        }
        if let reps = UserDefaults.standard.object(forKey: "\(itemName)_reps") as? Int {
            selectedRep = reps
        }
    }
}

#Preview {
    WeightsAndTimesView(itemName: "sample")
}
