// ABOUTME: Decodes WA DNR Ground Response MapServer query response
// ABOUTME: Contains liquefaction susceptibility classification data

import Foundation

struct LiquefactionQueryResponse: Codable {
    let features: [LiquefactionFeature]
}

struct LiquefactionFeature: Codable {
    let attributes: LiquefactionAttributes
}

struct LiquefactionAttributes: Codable {
    let liquefactionSusceptId: Int?
    let liquefactionSuscept: String?

    enum CodingKeys: String, CodingKey {
        case liquefactionSusceptId = "LIQUEFACTION_SUSCEPT_ID"
        case liquefactionSuscept = "LIQUEFACTION_SUSCEPT"
    }
}

struct EarthquakeRiskResult: Sendable {
    let level: RiskLevel
    let liquefactionSusceptibility: String?
    let summary: String
    let dataSource: String

    /// Detailed explanation of what this risk level means for homebuyers
    var whatThisMeans: String {
        switch level {
        case .veryHigh, .high:
            return "During a major earthquake, the ground here could behave like liquid, causing buildings to sink, tilt, or collapse. This area experienced significant damage in past earthquakes. Consider earthquake insurance and foundation reinforcement."
        case .moderate:
            return "This area has moderate potential for ground failure during strong earthquakes. Soil conditions may amplify shaking. Earthquake preparedness and insurance are recommended."
        case .low:
            return "This area has lower liquefaction potential, but earthquake risk still exists in Washington State due to the Cascadia Subduction Zone. Standard earthquake preparedness is still advisable."
        case .unknown:
            return "Liquefaction susceptibility data is not available for this location."
        }
    }

    /// Questions homebuyers should ask about earthquake risk
    var questionsToAsk: [String] {
        switch level {
        case .veryHigh, .high:
            return [
                "Has the foundation been retrofitted for earthquake resistance?",
                "Is the home bolted to its foundation?",
                "What is the soil composition under the property?",
                "Does the seller have earthquake insurance? What does it cost?",
                "Has this property experienced damage from past earthquakes?"
            ]
        case .moderate:
            return [
                "Is the home bolted to its foundation?",
                "What would earthquake insurance cost for this property?",
                "Are there any known soil stability concerns?"
            ]
        case .low, .unknown:
            return [
                "Is the home bolted to its foundation?",
                "What would earthquake insurance cost for this property?"
            ]
        }
    }

    /// External links to official earthquake data sources
    var externalLinks: [ExternalLink] {
        return [
            ExternalLink(title: "WA Emergency Management", url: URL(string: "https://mil.wa.gov/earthquake")!),
            ExternalLink(title: "USGS Earthquake Hazards", url: URL(string: "https://www.usgs.gov/programs/earthquake-hazards")!)
        ]
    }
}
