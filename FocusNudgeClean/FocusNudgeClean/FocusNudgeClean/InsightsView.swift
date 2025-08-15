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

    // --- New: Weekly Best/Worst Day ---
    var bestDay: String? {
        weeklyData.max(by: { $0.value < $1.value })?.key
    }

    var worstDay: String? {
        weeklyData.min(by: { $0.value < $1.value })?.key
    }

    // --- New: AI Suggestion ---
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
            formatter.dateFormat = "h a" // e.g. "8 AM", "3 PM"
            let sampleDate = Calendar.current.date(bySettingHour: bestHour, minute: 0, second: 0, of: Date())!
            let bestHourFormatted = formatter.string(from: sampleDate)

        return "Try focusing around \(bestHourFormatted) – that’s when you’re most productive!"
    }

    // Format sessions into day-of-week buckets
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

    var weeklyMinutes: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!

        return focusSessions
            .filter { ($0.date ?? Date()) >= startOfWeek }
            .reduce(0) { $0 + Int($1.minutes) }
    }

    var sessionCount: Int {
        focusSessions.count
    }

    var longestStreak: Int {
        let sortedDates = focusSessions
            .compactMap { $0.date }
            .map { Calendar.current.startOfDay(for: $0) }
            .sorted()

        var streak = 0
        var maxStreak = 0
        var previousDate: Date?

        for date in sortedDates {
            if let prev = previousDate {
                let daysBetween = Calendar.current.dateComponents([.day], from: prev, to: date).day ?? 0
                streak = (daysBetween == 1) ? streak + 1 : 1
            } else {
                streak = 1
            }
            maxStreak = max(maxStreak, streak)
            previousDate = date
        }

        return maxStreak
    }

    var body: some View {
        let accent = ThemeManager.shared.getColor(named: selectedColor)

        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("Weekly Insights")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                 

                // Metrics Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Total Focus Time:", systemImage: "clock")
                        Spacer()
                        Text("\(totalMinutes / 60)h \(totalMinutes % 60)m")
                            .fontWeight(.medium)
                    }

                    HStack {
                        Label("Sessions Completed:", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(sessionCount)")
                            .fontWeight(.medium)
                    }

                    HStack {
                        Label("Longest Streak:", systemImage: "flame.fill")
                        Spacer()
                        Text("\(longestStreak) Day(s)")
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Goal Section + History
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weekly Goal Progress")
                        .font(.headline)

                    ProgressView(value: Double(weeklyMinutes), total: Double(weeklyGoalMinutes))
                        .accentColor(accent)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .animation(.easeOut(duration: 0.5), value: weeklyMinutes)

                    HStack {
                        Text("\(weeklyMinutes) min focused")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Goal: \(weeklyGoalMinutes) min")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Text("Goal Completion History")
                        .font(.headline)

                    ForEach(goalCompletions.prefix(2), id: \.self) { goal in
                        HStack {
                            Text(goal.date ?? Date(), style: .date)
                            Spacer()
                            let hours = Int(goal.goalMinutes) / 60
                            let minutes = Int(goal.goalMinutes) % 60
                            Text("\(hours)h \(minutes)m")
                                .font(.caption)
                                .foregroundColor(goal.achieved ? .green : .red)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Chart Section
                Text("Your Focus Per Day:")
                    .font(.headline)

                Chart {
                    ForEach(weeklyData.sorted(by: { $0.key < $1.key }), id: \.key) { day, minutes in
                        BarMark(x: .value("Day", day), y: .value("Minutes", minutes))
                            .foregroundStyle(accent)
                    }
                }
                .frame(height: 200)

                // --- New: Best/Worst Day ---
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Most Focused Day: \(bestDay ?? "–")")
                    Text("Your Least Focused Day: \(worstDay ?? "–")")
                }
                .font(.subheadline)
                .multilineTextAlignment(.center)
    
                .padding()
                .background(Color(.systemGray6))
               
                .cornerRadius(12)
                .frame(width: 250)
                .frame(maxWidth: .infinity, alignment: .center)
               

                // --- New: AI Suggestion ---
                Text(aiSuggestion)
                    .font(.caption)
                    .foregroundColor(accent)
                  
                if showGoalAchieved {
                    Text("🎉 You reached your weekly goal!")
                        .font(.headline)
                        .foregroundColor(accent)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(accent.opacity(0.1))
                        .cornerRadius(20)
                        .transition(.opacity)
                }

                // ✅ AI Weekly Summary Section (centered, with bullet points)
                // ✅ Centered title + grey block, but text inside block is left-aligned
                
                
                Spacer()
            }
            .padding()
            .onAppear {
                if weeklyMinutes >= weeklyGoalMinutes {
                    showGoalAchieved = true
                    saveGoalCompletion()
                }
            }
        }
    }

    private func saveGoalCompletion() {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!

        let request: NSFetchRequest<GoalCompletion> = GoalCompletion.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", startOfWeek as NSDate)

        do {
            let existing = try viewContext.fetch(request)
            if existing.isEmpty {
                let completion = GoalCompletion(context: viewContext)
                completion.date = Date()
                completion.goalMinutes = Int16(weeklyGoalMinutes)
                completion.achieved = true
                try viewContext.save()
                print("Weekly goal completion saved.")
            } else {
                print("Weekly goal already recorded.")
            }
        } catch {
            print("Failed to save goal completion: \(error.localizedDescription)")
        }
    }
} 
#Preview {
    NavigationStack {
        InsightsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            
    }
}
