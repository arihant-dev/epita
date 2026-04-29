//
//  LocationPickerView.swift
//  flashcard-learner
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LocationPickerViewModel()
    @State private var searchText = "Paris center"
    var onSelect: (Flashcard.Place) -> Void
    
    var body: some View {
        NavigationStack {
            List(viewModel.results, id: \.self) { item in
                Button {
                    let place = Flashcard.Place(
                        name: item.name ?? "Unknown Location",
                        latitude: item.location.coordinate.latitude,
                        longitude: item.location.coordinate.longitude
                    )
                    onSelect(place)
                    dismiss()
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Unknown")
                            .foregroundStyle(.primary)
                        Text(item.placemark.title ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, newValue in
                viewModel.search(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.search(query: searchText)
            }
        }
    }
}
