//
//  WeightsAndTimesView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/21.
//
import SwiftUI

struct WeightsAndTimesView: View {
    var itemName: String // itemNameを保持するプロパティ
    @State private var selectedWeight: Int = 100
    @State private var selectedUnit: String = "kg" // String型に変更
    @State private var selectedRep: Int = 10
    @State private var isShowingPopup = false // ポップアップ表示制御
    
    // WatchSessionDelegateの単一のインスタンスを共有する
    @EnvironmentObject var sessionDelegate: WatchSessionDelegate
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Picker("Weight", selection: $selectedWeight) {
                        ForEach(0..<1000) { weight in // 修正: 0から999までの範囲に変更
                            Text("\(weight)") // 表示の調整: 0から始めるため、加算なし
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.40)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        Text("lb").tag("lb") // enumをStringに変更
                        Text("kg").tag("kg") // enumをStringに変更
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width * 0.25)
                    
                    Spacer()
                    
                    Picker("Reps", selection: $selectedRep) {
                        ForEach(0..<100) { rep in // 修正: 0から99までの範囲に変更
                            Text("\(rep)") // 表示の調整: 0から始めるため、加算なし
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
            "unit": selectedUnit, // enumのrawValueからStringに変更
            "reps": selectedRep,
            "start_time": "",
            "end_time": "",
            "deleted_flg": false,
            "sendStatus": false,
        ]
        
        // itemNameに対応するキーでデータを保存
        UserDefaults.standard.set(value, forKey: key)
        
        // itemNameに対応するweight、unit、repsのデータを個別に保存
        UserDefaults.standard.set(selectedWeight, forKey: "\(itemName)_weight")
        UserDefaults.standard.set(selectedUnit, forKey: "\(itemName)_unit")
        UserDefaults.standard.set(selectedRep, forKey: "\(itemName)_reps")
    }

    
    private func loadDataFromUserDefaults() {
        if let weight = UserDefaults.standard.object(forKey: "\(itemName)_weight") as? Int {
            selectedWeight = weight
        }
        if let unit = UserDefaults.standard.object(forKey: "\(itemName)_unit") as? String { // enumのrawValueからStringに変更
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
