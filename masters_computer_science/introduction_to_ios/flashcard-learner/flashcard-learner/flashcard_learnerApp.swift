//
//  flashcard_learnerApp.swift
//  flashcard-learner
//
//  Created by Arihant Jain on 29/04/2026.
//

import SwiftUI
import SwiftData

@main
struct flashcard_learnerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Flashcard.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
