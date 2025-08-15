//
//  Persistence.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//
import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Create sample data for previews
        let viewContext = controller.container.viewContext
        for i in 0..<5 {
            let session = FocusSession(context: viewContext)
            session.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            session.minutes = Int16(25 + i * 5)

            let goal = GoalCompletion(context: viewContext)
            goal.date = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date())
            goal.goalMinutes = 300
            goal.achieved = Bool.random()
            
            //reflection page mock data preview 
            let reflection = FocusReflection(context: viewContext)
                    reflection.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
                    reflection.focusLevel = Int16(Int.random(in: 1...5))
                    reflection.distractionSource = ["Social Media", "Noise", "Fatigue", "None"].randomElement()
                    reflection.moodDescription = ["Calm", "Anxious", "Productive", "Tired"].randomElement()
        }

        try? viewContext.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FocusNudgeClean")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
         
    }
}
