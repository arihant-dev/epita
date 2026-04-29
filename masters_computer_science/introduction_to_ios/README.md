# French Pin

A location-based flashcard iOS application built in Swift and SwiftUI. The app is a final project for EPITA, adhering strictly to a "no external libraries" rule. 

## Features

- **Flashcard List & Creation:** Users can add new French words and their English translations.
- **Native Translation:** Automatically translates a French word into English using Apple's native `Translation` framework.
- **Text-to-Speech:** Uses `AVFoundation` to pronounce words with the native speaker accent. A tap on the speaker icon pronounces the word aloud.
- **Map View:** Uses `MapKit` to pin the exact location where a word was learned. Users can switch between a standard list view and a map view. Map pins cluster flashcards saved at the same location using a swipeable interface (`TabView`).
- **Freemium Monetization Model:** Words are grouped into categories. "Basics" and "Food" are free. "Travel" and "Work" are premium categories. Tapping a premium category shows an upgrade paywall screen.
- **Local Persistence:** Data is stored locally on the device using `SwiftData`.
- **Search:** A native search bar allows quick filtering of flashcards by French word or English translation.
- **Haptic Feedback:** Device vibrates lightly when cards are flipped and gives a success vibration when saving a new word.

## Architecture

The project uses a standard MVVM (Model-View-ViewModel) pattern tailored for SwiftUI:

- **Models:** 
  - `Flashcard.swift`: The main data model decorated with `@Model` for `SwiftData`. Defines the properties (word, translation, category, date, and `Place`).
- **ViewModels/Services:**
  - `SpeechService.swift`: A singleton wrapper around `AVSpeechSynthesizer` handling text-to-speech.
  - `LocationPickerViewModel.swift`: Handles `MKLocalSearch` requests to find map coordinates based on user input.
- **Views:**
  - `ContentView.swift`: Root view wrapping the list.
  - `FlashcardListView.swift`: The main screen containing the search bar, category filters, and a toggle between List and Map modes.
  - `FlashcardMapView.swift`: The alternative main screen rendering `MapKit` annotations and a sheet with swipeable grouped cards.
  - `CreateFlashcardView.swift`: The form to input new words, trigger translations, and pick a location.
  - `LocationPickerView.swift`: The search UI for finding places on the map.
  - `PremiumUpgradeView.swift`: The mock paywall for the freemium model.

## How It Works

1. **Adding a Word:** The user taps `+`. They type a French word and tap the sparkle icon to fetch an English translation. They select a category and use the map search to pin a location. Tapping "Save" writes the object to `SwiftData`, triggering a success animation and haptic feedback.
2. **Reviewing Words:** On the home screen, users see all cards in a list. Tapping a card flips it with a 3D animation to reveal the translation.
3. **Using the Map:** Tapping "Map" switches the view. Pins are clustered by location name. Tapping a pin opens a bottom sheet. If multiple words share that location, the user can swipe left and right to view them.
4. **Monetization:** An `@AppStorage` boolean tracks if the user is premium. Tapping a locked category (or trying to save a word in one) opens the `PremiumUpgradeView`. Clicking "Upgrade for $4.99" toggles the boolean and unlocks the app.

## Caveats and Limitations

- **Simulator Data:** The app was updated to prevent a `SwiftData` crash from old enum data. If the app is uninstalled, those old fallback enum cases (`vocabulary`, `phrase`, etc.) could technically be removed from the code, but they are left in to ensure backward compatibility during grading.
- **Translation Framework:** Apple's `TranslationSession` requires iOS 17.4+ and an active internet connection or downloaded language models. If the translation fails or the device does not support it, an error alert is shown to the user, instructing them to type the translation manually.
- **App Icon:** The Xcode project has an empty `AppIcon.appiconset`. To complete the polish, a 1024x1024 PNG must be dragged into this asset catalog via Xcode before building the final release.
- **Accent Color:** The app relies on the system default `.blue`. For custom branding, the `AccentColor.colorset` in `Assets.xcassets` should be updated in Xcode.
- **Map Search:** `MKLocalSearch` relies on Apple Maps data. Highly specific or obscure queries might not return results depending on the user's region.

## Setup Instructions

1. Open `flashcard-learner.xcodeproj` in Xcode 15.3 or later.
2. Select a simulator running iOS 17.4+.
3. Build and run (Cmd + R).
