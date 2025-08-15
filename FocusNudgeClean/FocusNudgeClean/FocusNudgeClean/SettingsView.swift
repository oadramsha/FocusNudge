//
//  SettingsView.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//
import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("selectedColor") private var selectedColor: String = "Purple"
    @AppStorage("dailyReminder") private var dailyReminder: Bool = true
    @AppStorage("defaultSessionLength") private var defaultSessionLength: Int = 25
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    @State private var showResetAlert = false
    @AppStorage("weeklyGoalMinutes") private var weeklyGoalMinutes: Int = 300

    let colorOptions = ["Purple", "Blue", "Green", "Orange"]

    var body: some View {
        let accent = ThemeManager.shared.getColor(named: selectedColor)

        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
               
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top)

               
                VStack(alignment: .leading, spacing: 10) {
                    Text("Accent Color")
                        .font(.headline)
                        .padding(.bottom, 10)

                    Picker("Accent Color", selection: $selectedColor) {
                        ForEach(colorOptions, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                    .pickerStyle(.segmented)
                }

             
                VStack(alignment: .leading, spacing: 15) {
                    Text("Focus Options")
                        .font(.headline)
                        .padding(.top, 22)

                
                    Toggle("Daily Reminder", isOn: $dailyReminder)
                        .tint(accent)
                        .onChange(of: dailyReminder) { newValue in
                            if newValue {
                                scheduleDailyReminder()
                            } else {
                                cancelDailyReminders()
                            }
                        }

                    

                 
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weekly Focus Goal")
                            .font(.headline)
                        
                        Picker("Weekly Goal", selection: $weeklyGoalMinutes) {
                            ForEach([60, 120, 180, 240, 300, 360, 420, 480], id: \.self) { value in
                                Text("\(value) minutes").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                    .padding(.top, 20)
                    
                 

                  
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Default Session Length")
                            .font(.headline)
                            .padding(.bottom, 13)

                        Picker("Default Session Length", selection: $defaultSessionLength) {
                            ForEach([15, 25, 45, 60], id: \.self) { length in
                                Text("\(length) minutes").tag(length)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

               
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Text("Reset All Settings")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert("Reset All Settings?", isPresented: $showResetAlert) {
                    Button("Reset", role: .destructive, action: resetAllSettings)
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will reset your FocusNudge to default settings.")
                }

                Spacer()
            }
            .padding()
        }
    }

 
    private func resetAllSettings() {
        selectedColor = "Purple"
        dailyReminder = true
        defaultSessionLength = 25
        soundEnabled = true

        scheduleDailyReminder() 
    }

   
    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Stay Focused!"
        content.body = "It's time to start you FocusNudge session!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9 

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_focus_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            }
        }
    }

    private func cancelDailyReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_focus_reminder"])
    }
}

