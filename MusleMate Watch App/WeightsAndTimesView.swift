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
    @State private var selectedRep: Int = 10
    
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
                        Text("kg").tag(WeightUnit.kg.rawValue)
                        Text("lb").tag(WeightUnit.lb.rawValue)
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
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
        }
        .navigationTitle(itemName)
        .onAppear {
            loadDataFromUserDefaults()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private func saveDataToUserDefaults() {
        UserDefaults.standard.set(selectedWeight, forKey: "\(itemName)_weight")
        UserDefaults.standard.set(selectedUnit.rawValue, forKey: "\(itemName)_unit")
        UserDefaults.standard.set(selectedRep, forKey: "\(itemName)_reps")
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
