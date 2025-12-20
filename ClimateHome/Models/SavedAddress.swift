// ABOUTME: SwiftData model for persisting saved property risk lookups
// ABOUTME: Stores address and all risk levels for offline comparison without re-querying APIs

import Foundation
import SwiftData

@Model
class SavedAddress {
    var address: String
    var formattedAddress: String?
    var latitude: Double
    var longitude: Double
    var savedAt: Date
    var nickname: String?

    // Store risk levels as strings for persistence
    var wildfireRiskLevel: String?
    var floodRiskLevel: String?
    var earthquakeRiskLevel: String?
    var volcanoRiskLevel: String?
    var airQualityRiskLevel: String?
    var overallRiskLevel: String

    // Additional context for display
    var wildfileSummary: String?
    var floodSummary: String?
    var earthquakeSummary: String?
    var volcanoSummary: String?
    var airQualitySummary: String?

    init(
        address: String,
        formattedAddress: String?,
        latitude: Double,
        longitude: Double,
        savedAt: Date = Date(),
        nickname: String? = nil,
        wildfireRiskLevel: String? = nil,
        floodRiskLevel: String? = nil,
        earthquakeRiskLevel: String? = nil,
        volcanoRiskLevel: String? = nil,
        airQualityRiskLevel: String? = nil,
        overallRiskLevel: String,
        wildfileSummary: String? = nil,
        floodSummary: String? = nil,
        earthquakeSummary: String? = nil,
        volcanoSummary: String? = nil,
        airQualitySummary: String? = nil
    ) {
        self.address = address
        self.formattedAddress = formattedAddress
        self.latitude = latitude
        self.longitude = longitude
        self.savedAt = savedAt
        self.nickname = nickname
        self.wildfireRiskLevel = wildfireRiskLevel
        self.floodRiskLevel = floodRiskLevel
        self.earthquakeRiskLevel = earthquakeRiskLevel
        self.volcanoRiskLevel = volcanoRiskLevel
        self.airQualityRiskLevel = airQualityRiskLevel
        self.overallRiskLevel = overallRiskLevel
        self.wildfileSummary = wildfileSummary
        self.floodSummary = floodSummary
        self.earthquakeSummary = earthquakeSummary
        self.volcanoSummary = volcanoSummary
        self.airQualitySummary = airQualitySummary
    }

    /// Helper to create SavedAddress from PropertyRiskReport
    static func from(_ report: PropertyRiskReport) -> SavedAddress? {
        guard let coordinate = report.coordinate else { return nil }

        return SavedAddress(
            address: report.address,
            formattedAddress: report.formattedAddress,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            wildfireRiskLevel: report.wildfireRisk?.level.rawValue,
            floodRiskLevel: report.floodRisk?.level.rawValue,
            earthquakeRiskLevel: report.earthquakeRisk?.level.rawValue,
            volcanoRiskLevel: report.volcanoRisk?.level.rawValue,
            airQualityRiskLevel: report.airQualityRisk?.level.rawValue,
            overallRiskLevel: report.overallRiskLevel.rawValue,
            wildfileSummary: report.wildfireRisk?.summary,
            floodSummary: report.floodRisk?.summary,
            earthquakeSummary: report.earthquakeRisk?.summary,
            volcanoSummary: report.volcanoRisk?.summary,
            airQualitySummary: report.airQualityRisk?.summary
        )
    }
}
