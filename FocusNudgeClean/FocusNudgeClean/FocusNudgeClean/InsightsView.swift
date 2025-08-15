//
//  Insights.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//import SwiftUI
import SwiftUI
import Charts
import CoreData

struct InsightsView: View {
    
    @AppStorage("selectedColor") private var selectedColor: String = "Purple"
    @AppStorage("weeklyGoalMinutes") private var weeklyGoalMinutes: Int = 300

    @State private var showGoalAchieved = false
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: FocusSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FocusSession.date, ascending: true)]
    ) var focusSessions: FetchedResults<FocusSession>

    @FetchRequest(
        entity: GoalCompletion.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \GoalCompletion.date, ascending: false)]
    ) var goalCompletions: FetchedResults<GoalCompletion>

   
    var bestDay: String? {
        weeklyData.max(by: { $0.value < $1.value })?.key
    }

    var worstDay: String? {
        weeklyData.min(by: { $0.value < $1.value })?.key
    }

    
    var aiSuggestion: String {
        let calendar = Calendar.current
        let hourData = focusSessions.compactMap { session -> Int? in
            guard let date = session.date else { return nil }
            return calendar.component(.hour, from: date)
        }

        guard !hourData.isEmpty else { return "Track more sessions for personalized tips!" }

        let bestHour = hourData.reduce(into: [:]) { counts, hour in
            counts[hour, default: 0] += 1
        }.max(by: { $0.value < $1.value })?.key ?? 0
        let formatter = DateFormatter()
            formatter.dateFormat = "h a" 
            let sampleDate = Calendar.current.date(bySettingHour: bestHour, minute: 0, second: 0, of: Date())!
            let bestHourFormatted = formatter.string(from: sampleDate)

        return "Try focusing around \(bestHourFormatted) – that’s when you’re most productive!"
    }

    
    var weeklyData: [String: Int] {
        var result: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        for session in focusSessions {
            if let date = session.date {
                let day = formatter.string(from: date)
                result[day, default: 0] += Int(session.minutes)
            }
        }

        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for day in days {
            result[day] = result[day, default: 0]
        }

        return result
    }

    var totalMinutes: Int {
        focusSessions.reduce(0) { $0 + Int($1.minutes) }
    }
    
...
  
