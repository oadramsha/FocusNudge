//
//  ReflectionEntryForm.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-17.
//
import SwiftUI
import CoreML

struct ReflectionEntryForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var focusLevel: Int = 5
    @State private var distraction: String = ""
    @State private var mood: String = ""
    @State private var moodLabels: [String] = []


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Focus Level (1–10)")) {
                    Slider(value: Binding(get: {
                        Double(focusLevel)
                    }, set: { newValue in
                        focusLevel = Int(newValue)
                    }), in: 1...10, step: 1)
                    Text("\(focusLevel)")
                }

                Section(header: Text("Biggest Distraction")) {
                    TextField("e.g. Social Media", text: $distraction)
                }

                Section(header: Text("Mood Description")) {
                    TextField("e.g. Calm, energized", text: $mood)
                }
            }
            .navigationTitle("New Reflection")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReflection()
                    }
                }
            }
        }
    }

    func saveReflection() {
        let newReflection = FocusReflection(context: viewContext)
        newReflection.date = Date()
        newReflection.focusLevel = Int16(focusLevel)
        newReflection.distractionSource = distraction
        newReflection.moodDescription = mood

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving reflection: \(error)")
        }
    }
}
