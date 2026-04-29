//
//  FlashcardMapView.swift
//  flashcard-learner
//

import SwiftUI
import MapKit

struct LocationGroup: Identifiable {
    let id = UUID()
    let place: Flashcard.Place
    var cards: [Flashcard]
}

struct FlashcardMapView: View {
    var flashcards: [Flashcard]
    
    // We only map flashcards that have a location
    var mappedCards: [Flashcard] {
        flashcards.filter { $0.place != nil }
    }
    
    // Group flashcards by place name
    var locationGroups: [LocationGroup] {
        let grouped = Dictionary(grouping: mappedCards) { $0.place!.name }
        return grouped.map { (name, cards) in
            LocationGroup(place: cards.first!.place!, cards: cards)
        }
    }
    
    @State private var selectedGroup: LocationGroup?
    
    var body: some View {
        Map {
            ForEach(locationGroups) { group in
                Annotation(group.place.name, coordinate: CLLocationCoordinate2D(latitude: group.place.latitude, longitude: group.place.longitude)) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(group.cards.contains(where: { $0.category.isPremium }) ? .purple : .blue)
                        
                        Text(group.cards.count > 1 ? "\(group.cards.count) Words" : group.cards.first!.frenchWord)
                            .font(.caption)
                            .bold()
                            .padding(4)
                            .background(.background)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 2)
                    }
                    .onTapGesture {
                        selectedGroup = group
                    }
                }
            }
        }
        .sheet(item: $selectedGroup) { group in
            VStack {
                Text("📍 \(group.place.name)")
                    .font(.headline)
                    .padding(.top, 24)
                
                TabView {
                    ForEach(group.cards) { card in
                        VStack {
                            Text(card.frenchWord)
                                .font(.largeTitle)
                                .bold()
                                .multilineTextAlignment(.center)
                            
                            Text(card.translation)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                            
                            Text(card.category.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(uiColor: .secondarySystemFill))
                                .clipShape(Capsule())
                                .padding(.top, 16)
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .presentationDetents([.medium])
        }
    }
}

