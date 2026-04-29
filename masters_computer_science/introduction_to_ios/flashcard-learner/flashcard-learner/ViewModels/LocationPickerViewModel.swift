//
//  LocationPickerViewModel.swift
//  flashcard-learner
//

import SwiftUI
import MapKit

@Observable
class LocationPickerViewModel {
    var results: [MKMapItem] = []
    
    func search(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            self.results = response?.mapItems ?? []
        }
    }
}