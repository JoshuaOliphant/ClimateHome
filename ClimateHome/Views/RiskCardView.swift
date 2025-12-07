// ABOUTME: Individual risk category display card with expandable details
// ABOUTME: Shows icon, level indicator, summary, and tappable detail sheet

import SwiftUI

struct RiskCardView: View {
    let title: String
    let icon: String
    let level: RiskLevel
    let summary: String
    let source: String
    var whatThisMeans: String? = nil
    var questionsToAsk: [String]? = nil

    @State private var showingDetail = false

    private var hasDetails: Bool {
        whatThisMeans != nil || (questionsToAsk != nil && !questionsToAsk!.isEmpty)
    }

    var body: some View {
        Button {
            if hasDetails {
                showingDetail = true
            }
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            RiskDetailSheet(
                title: title,
                icon: icon,
                level: level,
                summary: summary,
                source: source,
                whatThisMeans: whatThisMeans,
                questionsToAsk: questionsToAsk
            )
        }
    }

    private var cardContent: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 32)
                .foregroundStyle(level.color)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Label(level.rawValue, systemImage: level.systemImage)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(level.color)
                }

                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                HStack {
                    Text("Source: \(source)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if hasDetails {
                        Spacer()
                        Text("Tap for details")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RiskDetailSheet: View {
    let title: String
    let icon: String
    let level: RiskLevel
    let summary: String
    let source: String
    let whatThisMeans: String?
    let questionsToAsk: [String]?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.largeTitle)
                            .foregroundStyle(level.color)

                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Label(level.rawValue, systemImage: level.systemImage)
                                .font(.subheadline)
                                .foregroundStyle(level.color)
                        }
                    }
                    .padding(.bottom, 8)

                    // Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Status")
                            .font(.headline)
                        Text(summary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    // What This Means
                    if let explanation = whatThisMeans {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What This Means")
                                .font(.headline)
                            Text(explanation)
                                .font(.body)
                        }
                    }

                    // Questions to Ask
                    if let questions = questionsToAsk, !questions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Questions to Ask")
                                .font(.headline)
                            ForEach(questions, id: \.self) { question in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundStyle(.blue)
                                        .font(.body)
                                    Text(question)
                                        .font(.body)
                                }
                            }
                        }
                    }

                    // Data Source
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Data Source")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text(source)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("\(title) Risk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        RiskCardView(
            title: "Wildfire",
            icon: "flame.fill",
            level: .low,
            summary: "Not in Wildland-Urban Interface zone",
            source: "WA DNR WUI 2019",
            whatThisMeans: "This property is not in a mapped Wildland-Urban Interface zone, indicating lower wildfire risk.",
            questionsToAsk: ["Has wildfire smoke been an issue?", "What is the insurance cost?"]
        )
        RiskCardView(
            title: "Flood",
            icon: "drop.fill",
            level: .high,
            summary: "Zone AE - Special Flood Hazard Area",
            source: "FEMA NFHL",
            whatThisMeans: "This property is in a Special Flood Hazard Area (SFHA), meaning flood insurance is required.",
            questionsToAsk: ["What is the flood insurance premium?", "Has this property flooded before?"]
        )
        RiskCardView(
            title: "Air Quality",
            icon: "aqi.medium",
            level: .moderate,
            summary: "AQI 85 - Moderate",
            source: "EPA AirNow"
        )
    }
    .padding()
}
