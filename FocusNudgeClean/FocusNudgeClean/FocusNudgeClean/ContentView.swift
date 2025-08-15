//
//  ContentView.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("selectedColor") private var selectedColor: String = "Purple"
    

    var body: some View {
        TabView {
            FocusHomeView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
            
          ReflectionTabView()
                .tabItem {
                    Label("Mood", systemImage: "face.smiling")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .accentColor(getColor(selectedColor))
    }
}
func getColor(_ colorName: String) -> Color {
    switch colorName {
    case "Purple": return .purple
    case "Blue": return .blue
    case "Green": return .green
    case "Orange": return .orange
    default: return .purple
    }
}


#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
