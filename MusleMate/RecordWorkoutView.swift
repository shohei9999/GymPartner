//
//  RecordWorkoutView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/25.
//
import SwiftUI

struct RecordWorkoutView: View {
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var isTimePickerModalPresented = false
    @State private var selectedWeight = 100
    @State private var selectedReps = 10
    @State private var items = [ListItem]()
    @State private var selectedWorkoutIndex = 0
    @State private var isWorkoutModalPresented = false
    @State private var isDatePickerModalPresented = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isWeightPickerModalPresented = false
    @State private var selectedUnit = weightUnits[0]
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月 d日"
        return formatter
    }
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "figure.run.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color.yellow)
                    .padding(.bottom, 10)
                
                List {
                    selectionRow(title: "Workout", action: { onWorkoutSelection() }, display: items.indices.contains(selectedWorkoutIndex) ? "\(items[selectedWorkoutIndex].name)" : "")
                    
                    selectionRow(title: "Date", action: { isDatePickerModalPresented = true }, display: dateFormatter.string(from: selectedDate))
                    
                    selectionRow(title: "Time", action: { isTimePickerModalPresented = true }, display: timeFormatter.string(from: selectedTime))
                    
                    selectionRow(title: "Weight", action: { isWeightPickerModalPresented = true }, display: "\(selectedWeight) \(selectedUnit)")

                    Text("Reps")
                }
                .listStyle(InsetGroupedListStyle())
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button("OK") {
                        if items.isEmpty {
                            showAlert = true
                        } else {
                            // Do something when OK button is tapped and items are not empty
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.orange)
                    .background(Color.white)
                    .cornerRadius(50)
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Record Workout")
            .onAppear {
                // UserDefaultsからitemsを読み込む
                if let savedData = UserDefaults.standard.data(forKey: "items"),
                   let decodedData = try? JSONDecoder().decode([ListItem].self, from: savedData) {
                    items = decodedData
                }
            }
        }
        .overlay(
            SelectionModalView(isPresented: $isWorkoutModalPresented) {
                SelectionView(items: items, selectedIndex: $selectedWorkoutIndex) { _ in
                    isWorkoutModalPresented = false
                }
            }
        )
        .overlay(
            SelectionModalView(isPresented: $isDatePickerModalPresented) {
                DatePickerView(selectedDate: $selectedDate)
            }
        )
        .overlay(
            SelectionModalView(isPresented: $isTimePickerModalPresented) {
                TimePickerView(selectedTime: $selectedTime, isPresented: $isTimePickerModalPresented)
            }
        )
        .overlay(
            SelectionModalView(isPresented: $isWeightPickerModalPresented) {
                WeightPickerView(selectedWeight: $selectedWeight, isPresented: $isWeightPickerModalPresented, selectedUnit: $selectedUnit)
            }
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("Please first register a Workout Menu."),
                dismissButton: .default(Text("OK")) {
                    // OKボタンがタップされたときの処理
                    presentationMode.wrappedValue.dismiss() // 親Viewへの遷移
                }
            )
        }
    }
    
    func onWorkoutSelection() {
        // UserDefaultsからitemsを読み込む
        if let savedData = UserDefaults.standard.data(forKey: "items"),
           let decodedData = try? JSONDecoder().decode([ListItem].self, from: savedData) {
            items = decodedData
        }
        if items.isEmpty {
            showAlert = true
        } else {
            isWorkoutModalPresented = true
        }
    }
    
    func selectionRow(title: String, action: @escaping () -> Void, display: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: action) {
                HStack {
                    Text(display)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Image(systemName: "greaterthan")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color.gray)
                }
                .padding(.trailing)
            }
        }
        .padding(.vertical, 5)
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(Color.white)
                .cornerRadius(20)
        }
        .frame(maxHeight: 300)
    }
}

public struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    @State private var temporaryTime: Date // モーダル内で選択された時間を一時的に保存するプロパティ
    
    public init(selectedTime: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedTime = selectedTime
        self._isPresented = isPresented
        self._temporaryTime = State(initialValue: selectedTime.wrappedValue)
    }
    
    public var body: some View {
        VStack {
            DatePicker("", selection: $temporaryTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(Color.white)
                .cornerRadius(20)
            
            HStack(spacing: 30) {
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
                
                Button("OK") {
                    isPresented = false
                    selectedTime = temporaryTime // OKボタンが押されたときに選択された時間を反映する
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
        }
        .frame(maxHeight: 300)
        .background(
            // モーダル外をタップしたときにモーダルを閉じるためのView
            Color.clear
                .onTapGesture {
                    isPresented = false
                }
        )
        .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))
        .onAppear {
            // モーダルが表示される際に選択された時間を一時的な時間に設定する
            temporaryTime = selectedTime
        }
    }
}


struct WeightPickerView: View {
    @Binding var selectedWeight: Int
    @Binding var isPresented: Bool
    @Binding var selectedUnit: String
    @State private var temporaryWeight: String // temporaryWeightをString型に変更

    public init(selectedWeight: Binding<Int>, isPresented: Binding<Bool>, selectedUnit: Binding<String>) {
        self._selectedWeight = selectedWeight
        self._isPresented = isPresented
        self._selectedUnit = selectedUnit
        _temporaryWeight = State(initialValue: "\(selectedWeight.wrappedValue)") // temporaryWeightをString型に初期化
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker(selection: $temporaryWeight, label: Text("")) {
                    ForEach(1..<1000) { index in
                        Text("\(index)").tag("\(index)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                .clipped()
                
                Picker(selection: $selectedUnit, label: Text("")) {
                    ForEach(weightUnits, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                .clipped()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            
            HStack(spacing: 30) {
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                    temporaryWeight = "\(selectedWeight)" // キャンセル時に一時的な選択を元に戻す
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
                
                Button("OK") {
                    isPresented = false
                    if let weight = Int(temporaryWeight) {
                        selectedWeight = weight // OKボタンが押されたときに選択された重さを反映する
                    }
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
        }
        .frame(maxHeight: 300)
        .background(
            // モーダル外をタップしたときにモーダルを閉じるためのView
            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPresented = false
                        selectedWeight = Int(temporaryWeight) ?? selectedWeight // モーダル外をタップしたときにピッカーの選択を元に戻す
                    }
            }
        )
        .onAppear {
            temporaryWeight = "\(selectedWeight)" // モーダルが表示される際に選択されている値を一時的な値に設定する
        }
    }
}

let weightUnits = ["kg", "lb"]
var selectedUnit = weightUnits[0]

struct SelectionView: View {
    var items: [ListItem]
    @Binding var selectedIndex: Int
    var dismiss: (Bool) -> Void
    
    var body: some View {
        VStack {
            Picker(selection: $selectedIndex, label: Text("Select")) {
                ForEach(items.indices, id: \.self) { (index: Int) in // indexの型を明示的に指定
                    Text(items[index].name).tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding()
            
            HStack(spacing: 30) {
                Spacer()
                
                Button("Cancel") {
                    dismiss(false)
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
                
                Button("OK") {
                    dismiss(false)
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
        }
    }
}

struct SelectionModalView<T: View>: View {
    @Binding var isPresented: Bool
    var content: () -> T
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                content()
            }
            
            Spacer()
        }
        .opacity(isPresented ? 1 : 0)
        .onTapGesture {
            withAnimation(.easeInOut) {
                isPresented = false
            }
        }
    }
}

#Preview {
    RecordWorkoutView()
}
