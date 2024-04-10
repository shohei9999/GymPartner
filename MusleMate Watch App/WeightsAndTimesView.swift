//
//  WeightsAndTimesView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI
import AVFoundation
import WatchKit

struct WeightsAndTimesView: View {
    var itemName: String
    @State private var selectedWeight: Int = 100
    @State private var selectedUnit: String = "kg"
    @State private var selectedRep: Int = 10
    @State private var isShowingPopup = false
    
    // WatchSessionDelegateを環境オブジェクトとして宣言
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate
    
    // itemName を受け取るイニシャライザを追加
    init(itemName: String) {
        self.itemName = itemName
    }
    
    init() {
        // itemName にデフォルト値を設定
        self.itemName = "Default Item"
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Picker("Weight", selection: $selectedWeight) {
                        ForEach(0..<1000) { weight in
                            Text("\(weight)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.40)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("lb").tag("lb")
                        Text("kg").tag("kg")
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.25)
                    
                    Spacer()
                    
                    Picker("Reps", selection: $selectedRep) {
                        ForEach(0..<100) { rep in
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
                    let data = prepareDataForWatch()
                    sessionDelegate.sendMessageToiPhone(with: data)
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
        
    private func prepareDataForWatch() -> [String: Any] {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let key = "workout_\(dateFormatter.string(from: currentDate))"
        
        let value: [String: Any] = [
            "menu": itemName,
            "weight": selectedWeight,
            "unit": selectedUnit,
            "reps": selectedRep,
            "start_time": "",
            "end_time": "",
            "deleted_flg": false,
            "sendStatus": false,
        ]
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.set(selectedWeight, forKey: "\(itemName)_weight")
        UserDefaults.standard.set(selectedUnit, forKey: "\(itemName)_unit")
        UserDefaults.standard.set(selectedRep, forKey: "\(itemName)_reps")
        
        return ["key": key, "data": value] 
    }

    
    private func loadDataFromUserDefaults() {
        if let weight = UserDefaults.standard.object(forKey: "\(itemName)_weight") as? Int {
            selectedWeight = weight
        }
        if let unit = UserDefaults.standard.object(forKey: "\(itemName)_unit") as? String {
            selectedUnit = unit
        }
        if let reps = UserDefaults.standard.object(forKey: "\(itemName)_reps") as? Int {
            selectedRep = reps
        }
    }
}

#Preview {
    WeightsAndTimesView()
}
