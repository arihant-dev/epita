//
//  CreateFlashcardView.swift
//  flashcard-learner
//

import SwiftUI
import SwiftData
import MapKit
import Translation
import UIKit

struct CreateFlashcardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremium") private var isPremium = false
    
    @State private var frenchWord = ""
    @State private var translation = ""
    @State private var category: Category = .basics
    @State private var selectedPlace: Flashcard.Place?
    @State private var showingLocationPicker = false
    @State private var showingPremiumUpgrade = false
    @State private var translationConfig: TranslationSession.Configuration?
    @State private var showingTranslationError = false
    @State private var translationErrorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section("Flashcard Details") {
                    HStack {
                        TextField("French Word", text: $frenchWord)
                        
                        if !frenchWord.isEmpty && translation.isEmpty {
                            Button {
                                translationConfig = TranslationSession.Configuration(
                                    source: Locale.Language(identifier: "fr"),
                                    target: Locale.Language(identifier: "en")
                                )
                            } label: {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    TextField("Translation", text: $translation)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(Category.uiCases, id: \.self) { cat in
                            Text(cat.rawValue + (cat.isPremium && !isPremium ? " 🔒" : "")).tag(cat)
                        }
                    }
                    .onChange(of: category) { oldValue, newValue in
                        if newValue.isPremium && !isPremium {
                            showingPremiumUpgrade = true
                            category = oldValue
                        }
                    }
                }
                
                Section("Location (Optional)") {
                    if let place = selectedPlace {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(place.name)
                                Spacer()
                                Button("Change") { showingLocationPicker = true }
                            }
                            
                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))) {
                                Marker(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
                            }
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    } else {
                        Button("Select Location") {
                            showingLocationPicker = true
                        }
                    }
                }
            }
            if showSuccess {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    Text("Saved!")
                        .font(.headline)
                        .padding(.top, 8)
                }
                .padding(30)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
            }
            .navigationTitle("New Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newCard = Flashcard(frenchWord: frenchWord, translation: translation, category: category, place: selectedPlace)
                        modelContext.insert(newCard)
                        
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        withAnimation(.spring) {
                            showSuccess = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            dismiss()
                        }
                    }
                    .disabled(frenchWord.trimmingCharacters(in: .whitespaces).isEmpty || translation.trimmingCharacters(in: .whitespaces).isEmpty || showSuccess)
                }
            }
            .translationTask(translationConfig) { session in
                do {
                    let response = try await session.translate(frenchWord)
                    self.translation = response.targetText
                } catch {
                    print("Translation error: \(error.localizedDescription)")
                    translationErrorMessage = "Translation isn't supported on the current device or the language pairing failed. Please type the translation manually."
                    showingTranslationError = true
                }
            }
            .alert("Translation Failed", isPresented: $showingTranslationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(translationErrorMessage)
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView { place in
                    self.selectedPlace = place
                }
            }
            .sheet(isPresented: $showingPremiumUpgrade) {
                PremiumUpgradeView()
            }
        }
    }
}
