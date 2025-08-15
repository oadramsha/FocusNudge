//
//  ReflectionTabView.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-17.
//
import SwiftUI
import CoreData

struct ReflectionTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FocusReflection.date, ascending: false)],
        animation: .default)
    private var reflections: FetchedResults<FocusReflection>

    @State private var showingAddReflection = false
    @State private var showDeleteConfirmation = false
    @State private var indexSetToDelete: IndexSet?

    var body: some View {
        NavigationView {
            VStack {
                Text("Mood Log")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)

                if reflections.isEmpty {
                    Text("No mood logs yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(reflections) { reflection in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Focus Level: \(reflection.focusLevel)")
                                Text("Distraction: \(reflection.distractionSource ?? "N/A")")
                                Text("Mood: \(reflection.moodDescription ?? "N/A")")
                                    .italic()
                                Text(reflection.date?.formatted(date: .abbreviated, time: .shortened) ?? "No Date")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            indexSetToDelete = indexSet
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                showingAddReflection.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddReflection) {
                ReflectionEntryForm()
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Mood Log"),
                    message: Text("Are you sure you want to delete this entry?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = indexSetToDelete {
                            deleteReflection(at: indexSet)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func deleteReflection(at offsets: IndexSet) {
        for index in offsets {
            let reflection = reflections[index]
            viewContext.delete(reflection)
        }

        do {
            try viewContext.save()
        } catch {
            print("❌ Error deleting reflection: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        ReflectionTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
