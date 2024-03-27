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
    @State private var selectedWeight = 100
    @State private var selectedReps = 10
    @State private var items = [ListItem]()
    @State private var selectedWorkoutIndex = 0
    @State private var isWorkoutModalPresented = false
    @State private var isDatePickerModalPresented = false
    @Environment(\.presentationMode) var presentationMode
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月 d日"
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
                    selectionRow(title: "Workout", action: { isWorkoutModalPresented = true }, display: items.indices.contains(selectedWorkoutIndex) ? "\(items[selectedWorkoutIndex].name)" : "")
                    
                    selectionRow(title: "Date", action: { isDatePickerModalPresented = true }, display: dateFormatter.string(from: selectedDate))
                    
                    Text("Time")
                    Text("Weight")
                    Text("Reps")
                }
                .listStyle(InsetGroupedListStyle())
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
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
                    print("items１: \(items)")
                } else {
                    print("items１: \(items)")
                    // UserDefaultsにitemsが存在しない場合、itemsを空の配列に設定
                    items = []
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
