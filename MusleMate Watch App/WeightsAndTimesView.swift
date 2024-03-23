//
//  WeightsAndTimesView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI

struct WeightsAndTimesView: View {
    var itemName: String // itemNameを保持するプロパティ
    @State private var selectedWeight: Int = 99
    @State private var selectedUnit: WeightUnit = .kg
    @State private var selectedRep: Int = 9
    @State private var isShowingPopup = false // ポップアップ表示制御
    
    enum WeightUnit: Int {
        case kg, lb
    }
    
    // WatchSessionDelegateの単一のインスタンスを共有する
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Picker("Weight", selection: $selectedWeight) {
                        ForEach(1..<1000) { weight in
                            Text("\(weight)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.40)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("lb").tag(WeightUnit.lb.rawValue)
                        Text("kg").tag(WeightUnit.kg.rawValue)
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.25)
                    
                    Spacer()
                    
                    Picker("Reps", selection: $selectedRep) {
                        ForEach(1..<100) { rep in
                            Text("\(rep)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.25)
                }
                .padding()
                
                Spacer()
                
                Spacer()
                
                Button("OK") {
                    saveDataToUserDefaults()
                    sessionDelegate.sendMessageToiPhone()
                    isShowingPopup = true // ポップアップ表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // 1秒後にポップアップを閉じる
                        isShowingPopup = false
                        // 1秒後に遷移する処理
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
            }
        }
        .navigationTitle(itemName)
        .alert(isPresented: $isShowingPopup) {
            Alert(title: Text("Done!"))
        }
        .onAppear {
            loadDataFromUserDefaults()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private func saveDataToUserDefaults() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let key = "workout_\(dateFormatter.string(from: currentDate))"
        
        let value: [String: Any] = [
            "menu": itemName,
            "weight": selectedWeight,
            "unit": selectedUnit.rawValue,
            "reps": selectedRep,
            "start_time": "",
            "end_time": "",
            "deleted_flg": false,
            "sendStatus": false,
            "memo": ""
        ]
        
        UserDefaults.standard.set(value, forKey: key)
    }
    
    private func loadDataFromUserDefaults() {
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
