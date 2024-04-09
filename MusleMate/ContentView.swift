//
//  ContentView.swift
//  MusleMate
//
//  Created by 林翔平 on 2024/03/20.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var items = [ListItem]()
    @State private var newItemName = ""
    @StateObject private var sessionDelegate = WatchSessionDelegate()
    @State private var isAddingNewItem = false // 入力フィールドを制御するためのフラグ

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack {
                    if items.isEmpty { // itemsが空の場合の表示
                        Text("Please add a new workout menu.")
                            .font(.body) // フォントをbodyに設定
                    } else {
                        Text("Only items with a star enabled will be displayed in the Apple Watch Workout menu.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        List {
                            ForEach(items) { item in
                                Button(action: {
                                    toggleFavorite(item: item)
                                }) {
                                    HStack {
                                        Text(item.name)
                                        Spacer()
                                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                                            .foregroundColor(item.isFavorite ? .yellow : .gray)
                                    }
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }
                }
                .navigationTitle("Workout Menu")
                .navigationBarItems(trailing: Button(action: {
                    isAddingNewItem = true // ボタンがタップされたら入力フィールドを表示する
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $isAddingNewItem) { // 入力フィールドをモーダルで表示する
                    VStack {
                        TextField("Enter new item name", text: $newItemName)
                            .padding()
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                isAddingNewItem = false // 入力フィールドを閉じる
                            }
                            .padding()
                            Button("Add Item") {
                                addItem()
                                isAddingNewItem = false // 入力フィールドを閉じる
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                loadItems()
                sessionDelegate.activateSession()
            }
        }
    }

    private func toggleFavorite(item: ListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveItems()
            sessionDelegate.sendFavoriteItemsToWatch(favoriteItems: favoriteItems)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }

    private func addItem() {
        guard !newItemName.isEmpty else { return }
        let newItem = ListItem(name: newItemName, isFavorite: false)
        items.append(newItem)
        saveItems()
        newItemName = ""
    }

    private var favoriteItems: [String] {
        return items.filter { $0.isFavorite }.map { $0.name }
    }

    private func saveItems() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: "items")
        }
    }

    private func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: "items"),
           let decodedData = try? JSONDecoder().decode([ListItem].self, from: savedData) {
            items = decodedData
        }
    }
}

class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    private let session = WCSession.default

    override init() {
        super.init()
        session.delegate = self
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("WCSession activated successfully")
        case .inactive:
            print("WCSession inactive")
        case .notActivated:
            print("WCSession not activated")
        @unknown default:
            print("Unknown activation state")
        }
        
        if let error = error {
            print("Activation error: \(error.localizedDescription)")
        }
    }

    func sendFavoriteItemsToWatch(favoriteItems: [String]) {
        guard session.activationState == .activated else { return }
        
        // ユーザー情報としてお気に入りアイテムを転送します
        let userInfo: [String: Any] = ["data": favoriteItems]
        
        // ユーザー情報を転送します
        session.transferUserInfo(userInfo)
    }


    func activateSession() {
        if WCSession.isSupported() {
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage!!!")
    }
}

struct ListItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    var isFavorite: Bool
}

#Preview {
    ContentView()
}
