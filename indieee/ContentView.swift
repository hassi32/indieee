//
//  ContentView.swift
//  indieee
//
//  Created by Yuki Hashizumi on 2026/03/05.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selectedItem: Item?
    @AppStorage("accentColor") private var accentColor: String = "blue"

    var body: some View {
        NavigationSplitView {
            // 左サイドバー: アイテム一覧
            List(selection: $selectedItem) {
                Section("Items") {
                    ForEach(items) { item in
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            .tag(item)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: deleteSelectedItem) {
                        Label("Delete Item", systemImage: "trash")
                    }
                  .disabled(selectedItem == nil)
                }
            }
        } detail: {
          // 右側: 詳細表示
          if let item = selectedItem {
            VStack(spacing: 20) {
              Image(systemName: "clock.fill")
                  .font(.system(size: 60))
                  .foregroundStyle(Color.from(string: accentColor))

              Text("Selected Item")
                  .font(.title)

              Text(item.timestamp, format: Date.FormatStyle(date: .long, time: .standard))
                  .font(.headline)

              Divider()

              Text("Created: \(item.timestamp, format: .relative(presentation: .named))")
                  .foregroundStyle(.secondary)
            }
          } else {
            // 何も選択されていない時
            VStack(spacing: 12) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 60))
                    .foregroundStyle(.tertiary)
                Text("Select an item")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
        .tint(Color.from(string: accentColor))
        .navigationTitle("indieee")
        // メニューバーからの通知を受け取る
        .onReceive(NotificationCenter.default.publisher(for: .addNewItem)) { _ in
            addItem()
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteSelectedItem)) { _ in
            deleteSelectedItem()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    private func deleteSelectedItem() {
        guard let item = selectedItem else { return }
        withAnimation {
            modelContext.delete(item)
            selectedItem = nil
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

// MARK: - Color Extension
extension Color {
    static func from(string: String) -> Color {
        switch string {
        case "blue":
            return .blue
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "orange":
            return .orange
        case "green":
            return .green
        default:
            return .blue
        }
    }
}
