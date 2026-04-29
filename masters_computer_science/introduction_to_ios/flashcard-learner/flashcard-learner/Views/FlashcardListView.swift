//
//  FlashcardListView.swift
//  flashcard-learner
//

import SwiftUI
import SwiftData

struct FlashcardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var flashcards: [Flashcard]
    @AppStorage("isPremium") private var isPremium = false
    
    @State private var showingCreateForm = false
    @State private var selectedCategory: Category? = nil
    @State private var showingPremiumUpgrade = false
    
    @State private var viewMode: ViewMode = .list
    @State private var searchText = ""
    
    enum ViewMode { case list, map }
    
    var filteredFlashcards: [Flashcard] {
        var result = flashcards
        if let selectedCategory = selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.frenchWord.localizedCaseInsensitiveContains(searchText) || $0.translation.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View Mode Picker
                Picker("View Mode", selection: $viewMode) {
                    Text("List").tag(ViewMode.list)
                    Text("Map").tag(ViewMode.map)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: { selectedCategory = nil }) {
                            Text("All")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.blue : Color(uiColor: .secondarySystemFill))
                                .foregroundStyle(selectedCategory == nil ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        
                        ForEach(Category.uiCases, id: \.self) { category in
                            Button(action: {
                                if category.isPremium && !isPremium {
                                    showingPremiumUpgrade = true
                                } else {
                                    selectedCategory = category
                                }
                            }) {
                                HStack {
                                    Text(category.rawValue)
                                    if category.isPremium && !isPremium {
                                        Image(systemName: "lock.fill")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.blue : Color(uiColor: .secondarySystemFill))
                                .foregroundStyle(selectedCategory == category ? .white : .primary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                if viewMode == .list {
                    Group {
                        if filteredFlashcards.isEmpty {
                            ContentUnavailableView(
                                "No Flashcards",
                                systemImage: "rectangle.stack.badge.plus",
                                description: Text("Tap the + button to add a new flashcard.")
                            )
                        } else {
                            List {
                                ForEach(filteredFlashcards) { flashcard in
                                    FlashcardCardView(flashcard: flashcard)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                                .onDelete(perform: deleteItems)
                            }
                            .listStyle(.plain)
                        }
                    }
                } else {
                    FlashcardMapView(flashcards: filteredFlashcards)
                }
            }
            .navigationTitle("Flashcards")
            .searchable(text: $searchText, prompt: "Search flashcards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateForm = true }) {
                        Label("Add Flashcard", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateForm) {
                CreateFlashcardView()
            }
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredFlashcards[index])
            }
        }
    }
}

struct FlashcardCardView: View {
    let flashcard: Flashcard
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            // Front (French)
            CardFace(text: flashcard.frenchWord, subtitle: flashcard.category.rawValue, color: .blue, languageToSpeak: "fr-FR")
                .opacity(isFlipped ? 0 : 1)
            
            // Back (English)
            CardFace(text: flashcard.translation, subtitle: "Translation", color: .green, languageToSpeak: "en-US")
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: 180)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: isFlipped)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardFace: View {
    let text: String
    let subtitle: String
    let color: Color
    var languageToSpeak: String? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let language = languageToSpeak {
                    Spacer()
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                        .highPriorityGesture(
                            TapGesture().onEnded {
                                SpeechService.shared.speak(text: text, language: language)
                            }
                        )
                }
            }
            .padding(.top, 8)
            Spacer()
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}
