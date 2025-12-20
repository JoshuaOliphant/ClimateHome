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

    /// Detailed explanation of what this risk level means for homebuyers
    var whatThisMeans: String {
        guard let aqi = currentAQI else {
            return "Air quality data shows current conditions. Washington experiences seasonal air quality issues from wildfire smoke (typically July-September) and winter inversions in some valleys."
        }

        switch aqi {
        case 0...50:
            return "Current air quality is Good. However, Washington experiences seasonal smoke events from wildfires that can dramatically worsen air quality for days or weeks. The Puget Sound region also experiences winter inversions that trap pollution. Consider researching historical air quality patterns for this area."
        case 51...100:
            return "Current air quality is Moderate. Unusually sensitive people should consider reducing prolonged outdoor exertion. This area may experience periodic air quality issues - research historical patterns and consider whether you or family members have respiratory sensitivities."
        case 101...150:
            return "Current air quality is Unhealthy for Sensitive Groups. People with respiratory or heart conditions, children, and older adults should limit prolonged outdoor exertion. If this is typical for the area, consider the health implications carefully."
        case 151...200:
            return "Current air quality is Unhealthy. Everyone may begin to experience health effects. This level is concerning if it's a common occurrence in this area - investigate whether this is due to a temporary event (wildfire) or a persistent issue."
        default:
            return "Current air quality is Very Unhealthy to Hazardous. This represents a serious health concern. Investigate whether this is due to a temporary event or if the area regularly experiences poor air quality."
        }
    }

    /// Questions homebuyers should ask about air quality
    var questionsToAsk: [String] {
        switch level {
        case .high, .veryHigh:
            return [
                "Is this air quality reading typical for this area or due to a temporary event?",
                "How often does air quality reach unhealthy levels here?",
                "Does the home have air filtration or a sealed HVAC system?",
                "What is the home's air sealing quality?",
                "Are there industrial facilities or major highways nearby?"
            ]
        case .moderate:
            return [
                "How is air quality during wildfire season (July-September)?",
                "Does the area experience winter inversions?",
                "Does the home have good air filtration?",
                "Are there any local pollution sources?"
            ]
        case .low, .unknown:
            return [
                "How is air quality during wildfire season?",
                "Has wildfire smoke been an issue in recent years?"
            ]
        }
    }

    /// External links to official air quality data sources
    var externalLinks: [ExternalLink] {
        return [
            ExternalLink(title: "EPA AirNow", url: URL(string: "https://www.airnow.gov")!),
            ExternalLink(title: "Puget Sound Clean Air Agency", url: URL(string: "https://www.pscleanair.gov")!)
        ]
    }
}
