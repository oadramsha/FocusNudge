//
//  FocusHomeView.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//
import SwiftUI
import CoreData

struct FocusHomeView: View {
    @State private var isRunning = false
    @State private var timeRemaining: Int = 25 * 60
    @State private var elapsedSeconds: Int = 0

    @AppStorage("selectedColor") private var selectedColor: String = "Purple"
    @AppStorage("defaultSessionLength") private var defaultSessionLength: Int = 25
    @Environment(\.managedObjectContext) private var viewContext

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: CGFloat {
        guard defaultSessionLength > 0 else { return 0 }
        return CGFloat(timeRemaining) / CGFloat(defaultSessionLength * 60)
    }

    var body: some View {
        let accent = ThemeManager.shared.getColor(named: selectedColor)
        let sessionDuration = defaultSessionLength * 60

        VStack(spacing: 30) {
            Spacer()

            // App title
            Text("FocusNudge")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(accent)
                .padding(.bottom, 20)

            // Subtitle
            Text("Stay present, stay focused!")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                .onChange(of: defaultSessionLength) { oldValue, newValue in
                    if !isRunning {
                        timeRemaining = newValue * 60
                    }
                }

            // Timer ring + text
            ZStack {
                
                
                Circle()
                    .stroke(lineWidth: 25)
                    .opacity(0.1)
                    .foregroundColor(accent)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(accent)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                Text(formatTime(seconds: timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }
            .frame(width: 250, height: 250)
            .onReceive(timer) { _ in
                if isRunning && timeRemaining > 0 {
                    timeRemaining -= 1
                    elapsedSeconds += 1
                }
            }

            // Start / Stop Button
            Button(action: {
                isRunning.toggle()
                if !isRunning {
                    saveSession()
                } else {
                    elapsedSeconds = 0
                }
            }) {
                Text(isRunning ? "End Session" : "Start Focus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(isRunning ? Color.red : accent)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }

            // Manual Reset Button
            Button(action: {
                isRunning = false
                timeRemaining = defaultSessionLength * 60
                elapsedSeconds = 0
            }) {
                Text("Reset Session")
                    .font(.subheadline)
                    .foregroundColor(accent)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
    }

    // Format time as MM:SS
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    // Save to Core Data
    private func saveSession() {
        let session = FocusSession(context: viewContext)
        session.minutes = Int16(elapsedSeconds / 60)
        session.date = Date()
      

        do {
            try viewContext.save()
            print("Session saved: \(session.minutes) minute(s)")
        } catch {
            print("Failed to save session: \(error.localizedDescription)")
        }
    }
}

