//
//  ContentView.swift
//  flashcard-learner
//
//  Created by Arihant Jain on 29/04/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        FlashcardListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
