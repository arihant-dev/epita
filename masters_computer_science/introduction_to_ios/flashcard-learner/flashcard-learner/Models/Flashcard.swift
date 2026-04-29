//
//  Flashcard.swift
//  flashcard-learner
//

import Foundation
import SwiftData

enum Category: String, Codable, CaseIterable {
    // Current cases
    case basics = "Basics"
    case food = "Food"
    case travel = "Travel"
    case work = "Work"
    
    // Old cases to prevent SwiftData crashes with existing data
    case vocabulary = "Vocabulary"
    case phrase = "Phrase"
    case verb = "Verb"
    case grammar = "Grammar"
    case other = "Other"
    
    var isPremium: Bool {
        return self == .travel || self == .work
    }
    
    // Only show these cases in the UI
    static var uiCases: [Category] {
        return [.basics, .food, .travel, .work]
    }
}

@Model
final class Flashcard {
    var id: UUID
    var frenchWord: String
    var translation: String
    var category: Category
    var dateAdded: Date
    var place: Place?
    
    init(id: UUID = UUID(), frenchWord: String, translation: String, category: Category, dateAdded: Date = Date(), place: Place? = nil) {
        self.id = id
        self.frenchWord = frenchWord
        self.translation = translation
        self.category = category
        self.dateAdded = dateAdded
        self.place = place
    }
    
    struct Place: Codable {
        var name: String
        var latitude: Double
        var longitude: Double
    }
}