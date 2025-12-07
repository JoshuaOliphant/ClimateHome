// ABOUTME: Individual risk category display card
// ABOUTME: Shows icon, level indicator, summary, and data source

import SwiftUI

struct RiskCardView: View {
    let title: String
    let icon: String
    let level: RiskLevel
    let summary: String
    let source: String

    var body: some View {
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

                Text("Source: \(source)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 12) {
        RiskCardView(
            title: "Wildfire",
            icon: "flame.fill",
            level: .low,
            summary: "Not in Wildland-Urban Interface zone",
            source: "WA DNR WUI 2019"
        )
        RiskCardView(
            title: "Flood",
            icon: "drop.fill",
            level: .high,
            summary: "Zone AE - Special Flood Hazard Area",
            source: "FEMA NFHL"
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
