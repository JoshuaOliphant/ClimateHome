// ABOUTME: Aggregates all risk data for a single property lookup
// ABOUTME: Tracks timing, errors, and data availability for PoC validation

import Foundation

struct PropertyRiskReport: Sendable {
    let address: String
    let formattedAddress: String?
    let coordinate: Coordinate?

    var wildfireRisk: WildfireRiskResult?
    var floodRisk: FloodRiskResult?
    var airQualityRisk: AirQualityRiskResult?

    var geocodingTimeMs: Int?
    var totalTimeMs: Int?

    var errors: [String] = []

    var overallRiskLevel: RiskLevel {
        let levels = [
            wildfireRisk?.level,
            floodRisk?.level,
            airQualityRisk?.level
        ].compactMap { $0 }

        if levels.contains(.high) {
            return .high
        } else if levels.contains(.moderate) {
            return .moderate
        } else if levels.contains(.low) {
            return .low
        } else {
            return .unknown
        }
    }

    var hasAnyData: Bool {
        wildfireRisk != nil || floodRisk != nil || airQualityRisk != nil
    }
}
