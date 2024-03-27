//
//  RecordWorkoutView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/25.
//
import SwiftUI
import Combine

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
    @State private var initialTime = Date()
    
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

                    selectionRow(title: "Time", action: {
                        // TimePickerViewを表示する前にinitialTimeをselectedTimeに設定する
                        initialTime = selectedTime
                        isTimePickerModalPresented = true
                    }, display: timeFormatter.string(from: selectedTime))

                    Text("Weight")
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
                TimePickerView(selectedTime: $selectedTime, isPresented: $isTimePickerModalPresented, initialTime: $initialTime)

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

struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    @Binding var initialTime: Date
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    init(selectedTime: Binding<Date>, isPresented: Binding<Bool>, initialTime: Binding<Date>) {
        _selectedTime = selectedTime
        _isPresented = isPresented
        _initialTime = initialTime
        print("init")
    }
    
    var body: some View {
        VStack {
            DatePicker("", selection: $initialTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .onAppear {
                    // 初期時間を選択時間に設定
                    initialTime = selectedTime
                    print("DatePicker onAppear initialTime:\(initialTime)")
                    print("DatePicker onAppear selectedTime:\(selectedTime)")
                }
            
            HStack(spacing: 30) {
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                    print("Cancel initialTime:\(initialTime)")
                    print("Cancel selectedTime:\(selectedTime)")
                }
                .padding()
                .foregroundColor(.orange)
                
                Spacer()
                
                Button("OK") {
                    isPresented = false
                    selectedTime = initialTime
                    print("OK initialTime:\(initialTime)")
                    print("OK selectedTime:\(selectedTime)")
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
        .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all))
        .onTapGesture {
            isPresented = false
        }
        .onAppear {
            // モーダルが表示される際にリストの時間を選択時間に設定
            initialTime = selectedTime
            print("Modal onAppear initialTime:\(initialTime)")
            print("Modal onAppear selectedTime:\(selectedTime)")
        }
    }
}

struct SelectionView: View {
    var items: [ListItem]
    @Binding var selectedIndex: Int
    var dismiss: (Bool) -> Void
    
    var body: some View {
        VStack {
            Picker(selection: $selectedIndex, label: Text("Select")) {
                ForEach(items.indices, id: \.self) { index in
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

struct RecordWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        RecordWorkoutView()
    }
}


#Preview {
    RecordWorkoutView()
}
