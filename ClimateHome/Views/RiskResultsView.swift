// ABOUTME: Displays aggregated risk results in card layout
// ABOUTME: Shows timing data for PoC validation

import SwiftUI
import SwiftData

struct RiskResultsView: View {
    let report: PropertyRiskReport

    @Environment(\.modelContext) private var modelContext
    @State private var showingSaveConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let formatted = report.formattedAddress {
                Text(formatted)
                    .font(.headline)
            }

            if let totalMs = report.totalTimeMs {
                HStack {
                    Image(systemName: "clock")
                    Text("Loaded in \(totalMs)ms")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            HStack {
                Text("Overall Risk:")
                    .font(.subheadline)
                Label(report.overallRiskLevel.rawValue, systemImage: report.overallRiskLevel.systemImage)
                    .font(.subheadline.bold())
                    .foregroundStyle(report.overallRiskLevel.color)

                Spacer()

                Button(action: saveAddress) {
                    Label("Save", systemImage: "bookmark")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)

            if showingSaveConfirmation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Property saved")
                        .font(.caption)
                }
                .transition(.opacity)
            }

            VStack(spacing: 12) {
                if let wildfire = report.wildfireRisk {
                    RiskCardView(
                        title: "Wildfire",
                        icon: "flame.fill",
                        level: wildfire.level,
                        summary: wildfire.summary,
                        source: wildfire.dataSource,
                        whatThisMeans: wildfire.whatThisMeans,
                        questionsToAsk: wildfire.questionsToAsk,
                        externalLinks: wildfire.externalLinks
                    )
                }

                if let flood = report.floodRisk {
                    RiskCardView(
                        title: "Flood",
                        icon: "drop.fill",
                        level: flood.level,
                        summary: flood.summary,
                        source: flood.dataSource,
                        whatThisMeans: flood.whatThisMeans,
                        questionsToAsk: flood.questionsToAsk,
                        externalLinks: flood.externalLinks
                    )
                }

                if let earthquake = report.earthquakeRisk {
                    RiskCardView(
                        title: "Earthquake",
                        icon: "waveform.path.ecg",
                        level: earthquake.level,
                        summary: earthquake.summary,
                        source: earthquake.dataSource,
                        whatThisMeans: earthquake.whatThisMeans,
                        questionsToAsk: earthquake.questionsToAsk,
                        externalLinks: earthquake.externalLinks
                    )
                }

                if let volcano = report.volcanoRisk {
                    RiskCardView(
                        title: "Volcano",
                        icon: "mountain.2.fill",
                        level: volcano.level,
                        summary: volcano.summary,
                        source: volcano.dataSource,
                        whatThisMeans: volcano.whatThisMeans,
                        questionsToAsk: volcano.questionsToAsk,
                        externalLinks: volcano.externalLinks
                    )
                }

                if let air = report.airQualityRisk {
                    RiskCardView(
                        title: "Air Quality",
                        icon: "aqi.medium",
                        level: air.level,
                        summary: air.summary,
                        source: air.dataSource,
                        whatThisMeans: air.whatThisMeans,
                        questionsToAsk: air.questionsToAsk,
                        externalLinks: air.externalLinks
                    )
                }
            }

            if !report.errors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Data Issues", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .fontWeight(.semibold)
                    ForEach(report.errors, id: \.self) { error in
                        Text("- \(error)")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private func saveAddress() {
        guard let savedAddress = SavedAddress.from(report) else { return }

        modelContext.insert(savedAddress)

        withAnimation {
            showingSaveConfirmation = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showingSaveConfirmation = false
            }
        }
    }
}

#Preview {
    var report = PropertyRiskReport(
        address: "700 5th Ave, Seattle, WA",
        formattedAddress: "700 5TH AVE, SEATTLE, WA 98104",
        coordinate: Coordinate(latitude: 47.6062, longitude: -122.3321)
    )
    report.wildfireRisk = WildfireRiskResult(
        level: .low,
        wuiClassification: nil,
        summary: "Not in Wildland-Urban Interface zone",
        dataSource: "WA DNR WUI 2019"
    )
    report.floodRisk = FloodRiskResult(
        level: .low,
        floodZone: "X",
        isSpecialFloodHazardArea: false,
        summary: "Zone X - Minimal flood hazard area",
        dataSource: "FEMA NFHL"
    )
    report.earthquakeRisk = EarthquakeRiskResult(
        level: .high,
        liquefactionSusceptibility: "high",
        summary: "High liquefaction susceptibility - significant ground failure risk",
        dataSource: "WA DNR Ground Response 2007"
    )
    report.volcanoRisk = VolcanoRiskResult(
        level: .low,
        inLaharZone: false,
        volcano: nil,
        hazardDescription: nil,
        summary: "Not in a mapped lahar hazard zone",
        dataSource: "WA DNR/USGS Volcanic Hazards 2016"
    )
    report.airQualityRisk = AirQualityRiskResult(
        level: .low,
        currentAQI: 42,
        category: "Good",
        reportingArea: "Seattle",
        summary: "AQI 42 - Good",
        dataSource: "EPA AirNow"
    )
    report.totalTimeMs = 1250

    return RiskResultsView(report: report)
        .padding()
}
