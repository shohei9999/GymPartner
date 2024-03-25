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
    @State private var selectedWeight = 100
    @State private var selectedReps = 10
    @State private var items = [ListItem]()
    @State private var selectedWorkoutIndex = 0
    @State private var isModalPresented = false
    
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
                    HStack {
                        Text("Workout")
                        Spacer()
                        Button(action: {
                            isModalPresented = true
                        }) {
                            HStack {
                                Text(items.indices.contains(selectedWorkoutIndex) ? "\(items[selectedWorkoutIndex].name)" : "")
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
                    
                    Text("Date")
                    Text("Time")
                    Text("Weight")
                    Text("Reps")
                }
                .listStyle(InsetGroupedListStyle())
                .padding()
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        // キャンセルボタンのアクション
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.orange)
                    .background(Color.white)
                    .cornerRadius(50)
                    
                    Button("OK") {
                        // OKボタンのアクション
                        print("Selected Workout: \(items[selectedWorkoutIndex].name)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.orange)
                    .background(Color.white)
                    .cornerRadius(50)
                }
                .padding()
            }
            .navigationBarTitle("Record Workout")
            .onAppear {
                // UserDefaultsからitemsを読み込む
                if let savedData = UserDefaults.standard.data(forKey: "items"),
                   let decodedData = try? JSONDecoder().decode([ListItem].self, from: savedData) {
                    items = decodedData
                    print("items: \(items)")
                }
            }
        }
        .overlay(
            ModalView(isPresented: $isModalPresented, items: items, selectedIndex: $selectedWorkoutIndex)
        )
    }
}

struct ModalView: View {
    @Binding var isPresented: Bool
    var items: [ListItem]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack {
                    Picker(selection: $selectedIndex, label: Text("Select Workout")) {
                        ForEach(items.indices, id: \.self) { index in
                            Text(items[index].name).tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
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
                        }
                        .padding()
                        .foregroundColor(.orange)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 3)
                .background(Color.white)
                .cornerRadius(20)
                .padding()
            }
            
            Spacer()
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.easeInOut)
    }
}


#Preview {
    RecordWorkoutView()
}
