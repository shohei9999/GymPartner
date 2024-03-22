//
//  HistoryView.swift
//  MusleMate Watch App
//
//  Created by 林翔平 on 2024/03/22.
//

import SwiftUI

struct HistoryView: View {
    @State private var historyItems: [HistoryItem] = []
    
    struct HistoryItem: Identifiable {
        let id = UUID()
        let date: Date
        let itemName: String
        let weight: Int
        let unit: WeightUnit
        let reps: Int
        
        var formattedDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
    }
    
    enum WeightUnit: Int {
        case kg, lb
        
        var description: String {
            switch self {
            case .kg:
                return "kg"
            case .lb:
                return "lb"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(historyItems) { item in
                    HStack {
                        Text(item.formattedDate)
                        Text("\(item.itemName)")
                        Text("\(item.weight) \(item.unit.description)")
                        Text("\(item.reps) reps")
                    }
                    .padding()
                }
            }
            .padding()
        }
        .onAppear {
            loadDataFromUserDefaults()
        }
        .navigationTitle("Workout Log")
    }
    
    private func loadDataFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        let itemNames = userDefaults.dictionaryRepresentation().keys.filter { $0.contains("_weight") }.map { $0.replacingOccurrences(of: "_weight", with: "") }

        var items: [HistoryItem] = []
        
        for itemName in itemNames {
            if let weight = userDefaults.object(forKey: "\(itemName)_weight") as? Int,
               let unitRawValue = userDefaults.object(forKey: "\(itemName)_unit") as? Int,
               let unit = WeightUnit(rawValue: unitRawValue),
               let reps = userDefaults.object(forKey: "\(itemName)_reps") as? Int,
               let date = userDefaults.object(forKey: "\(itemName)_date") as? Date {
                
                items.append(HistoryItem(date: date, itemName: itemName, weight: weight, unit: unit, reps: reps))
            } else {
                print("Failed to load data for item: \(itemName)")
            }
        }
        
        // 日付の昇順でソート
        historyItems = items.sorted(by: { $0.date < $1.date })
    }
}

#Preview {
    HistoryView()
}
