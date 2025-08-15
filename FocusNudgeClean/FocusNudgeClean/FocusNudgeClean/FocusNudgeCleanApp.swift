//
//  FocusNudgeCleanApp.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//
import SwiftUI

@main
struct FocusNudgeCleanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
