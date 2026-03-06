//
//  indieeeApp.swift
//  indieee
//
//  Created by Yuki Hashizumi on 2026/03/05.
//

import SwiftUI
import SwiftData

@main
struct indieeeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 800, height: 600)
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
        .commands {
            // Fileメニューにコマンドを追加
            CommandGroup(after: .newItem) {
                Button("New Item") {
                    NotificationCenter.default.post(name: .addNewItem, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Divider()
                
                Button("Delete Selected Item") {
                    NotificationCenter.default.post(name: .deleteSelectedItem, object: nil)
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }
        }
    }
}
// MARK: - Notification Names
extension Notification.Name {
    static let addNewItem = Notification.Name("addNewItem")
    static let deleteSelectedItem = Notification.Name("deleteSelectedItem")
}

