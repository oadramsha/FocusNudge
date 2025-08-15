//
//  FocusSessionManager.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//
import SwiftUI
import CoreData

class FocusSessionManager {
    static let shared = FocusSessionManager()
    
    let context = PersistenceController.shared.container.viewContext
    
    // Save a new session
    func saveSession(minutes: Int, date: Date = Date()) {
        let newSession = FocusSession(context: context)
        newSession.minutes = Int16(minutes)
        newSession.date = date
        
        do {
            try context.save()
            print("✅ Focus session saved.")
        } catch {
            print("❌ Failed to save focus session: \(error.localizedDescription)")
            
        }
        
        // Fetch all sessions (newest first)
        func fetchSessions() -> [FocusSession] {
            let request: NSFetchRequest<FocusSession> = FocusSession.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            do {
                return try context.fetch(request)
            } catch {
                print("❌ Failed to fetch sessions: \(error.localizedDescription)")
                return []
            }
        }
        
        // Delete all sessions (if needed for reset)
        func deleteAllSessions() {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FocusSession.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("🗑️ All sessions deleted.")
            } catch {
                print("❌ Failed to delete sessions: \(error.localizedDescription)")
            }
        }
    }
}

