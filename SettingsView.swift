//
//  SettingsView.swift
//  indieee
//
//  Created by Claude on 2026/03/06.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("accentColor") private var accentColor: String = "blue"
    @AppStorage("showCompletedItems") private var showCompletedItems: Bool = true
    @AppStorage("defaultPriority") private var defaultPriority: String = "medium"
    
    var body: some View {
        TabView {
            // 一般設定タブ
            generalSettingsView
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            // 表示設定タブ
            appearanceSettingsView
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
        }
        .frame(width: 450, height: 300)
    }
    
    // MARK: - General Settings
    private var generalSettingsView: some View {
        Form {
            Section("Items") {
                Toggle("Show completed items", isOn: $showCompletedItems)
                
                Picker("Default priority:", selection: $defaultPriority) {
                    Text("Low").tag("low")
                    Text("Medium").tag("medium")
                    Text("High").tag("high")
                    Text("Urgent").tag("urgent")
                }
                .pickerStyle(.segmented)
            }
            
            Section("About") {
                HStack {
                    Text("Version:")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build:")
                    Spacer()
                    Text("2026.03.06")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    // MARK: - Appearance Settings
    private var appearanceSettingsView: some View {
        Form {
            Section("Theme") {
                Picker("Accent color:", selection: $accentColor) {
                    Label("Blue", systemImage: "circle.fill")
                        .foregroundStyle(.blue)
                        .tag("blue")
                    
                    Label("Purple", systemImage: "circle.fill")
                        .foregroundStyle(.purple)
                        .tag("purple")
                    
                    Label("Pink", systemImage: "circle.fill")
                        .foregroundStyle(.pink)
                        .tag("pink")
                    
                    Label("Orange", systemImage: "circle.fill")
                        .foregroundStyle(.orange)
                        .tag("orange")
                    
                    Label("Green", systemImage: "circle.fill")
                        .foregroundStyle(.green)
                        .tag("green")
                }
                .pickerStyle(.inline)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    SettingsView()
}
