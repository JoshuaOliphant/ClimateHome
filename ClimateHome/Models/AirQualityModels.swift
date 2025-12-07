// ABOUTME: Decodes EPA AirNow current observation API response
// ABOUTME: Returns array of observations for different parameters (PM2.5, O3)

import Foundation

struct AirNowObservation: Codable {
    let DateObserved: String
    let HourObserved: Int
    let LocalTimeZone: String
    let ReportingArea: String
    let StateCode: String
    let Latitude: Double
    let Longitude: Double
    let ParameterName: String  // "PM2.5", "O3"
    let AQI: Int
    let Category: AQICategory
}

struct AQICategory: Codable {
    let Number: Int
    let Name: String  // "Good", "Moderate", "Unhealthy for Sensitive Groups", etc.
}

struct AirQualityRiskResult: Sendable {
    let level: RiskLevel
    let currentAQI: Int?
    let category: String?
    let reportingArea: String?
    let summary: String
    let dataSource: String
}
