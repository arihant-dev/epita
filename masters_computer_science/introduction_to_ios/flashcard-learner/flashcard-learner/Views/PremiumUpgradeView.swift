//
//  PremiumUpgradeView.swift
//  flashcard-learner
//

import SwiftUI

struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremium") private var isPremium = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding(.top, 40)
                
                Text("Unlock Premium Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Get access to all categories like Travel and Work to expand your French vocabulary on the go!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "airplane", title: "Travel Category", subtitle: "Learn essential travel phrases.")
                    FeatureRow(icon: "briefcase.fill", title: "Work Category", subtitle: "Master professional vocabulary.")
                    FeatureRow(icon: "infinity", title: "Unlimited Cards", subtitle: "No limits on your learning.")
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                Button(action: {
                    isPremium = true
                    dismiss()
                }) {
                    Text("Upgrade for $4.99")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PremiumUpgradeView()
}
