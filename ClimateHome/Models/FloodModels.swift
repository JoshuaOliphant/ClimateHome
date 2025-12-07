// ABOUTME: Decodes FEMA National Flood Hazard Layer query response
// ABOUTME: FLD_ZONE field contains flood zone designation (X, AE, VE, etc.)

import Foundation

struct NFHLQueryResponse: Codable {
    let features: [NFHLFeature]
}

struct NFHLFeature: Codable {
    let attributes: NFHLAttributes
}

struct NFHLAttributes: Codable {
    let FLD_ZONE: String?
    let ZONE_SUBTY: String?
    let SFHA_TF: String?  // Special Flood Hazard Area - "T" or "F"
}

struct FloodRiskResult: Sendable {
    let level: RiskLevel
    let floodZone: String?
    let isSpecialFloodHazardArea: Bool
    let summary: String
    let dataSource: String

    /// Detailed explanation of what this risk level means for homebuyers
    var whatThisMeans: String {
        if isSpecialFloodHazardArea {
            return "This property is in a Special Flood Hazard Area (SFHA), meaning it has a 1% or greater chance of flooding each year. Flood insurance is typically required by mortgage lenders for properties in SFHAs. Premiums can be significant - often $1,000-$3,000+ annually depending on the specific zone and property elevation."
        } else if let zone = floodZone {
            switch zone.uppercased() {
            case "X":
                return "Zone X indicates minimal flood risk - outside the 500-year floodplain. Flood insurance is not required but may still be advisable. About 25% of flood claims come from properties outside high-risk zones."
            case "B", "C":
                return "This is a moderate flood risk area, between the 100-year and 500-year floodplains. Flood insurance is not required but recommended."
            default:
                return "This property is in flood zone \(zone). Check with an insurance agent to understand requirements and costs for flood coverage."
            }
        }
        return "Flood zone information helps determine insurance requirements and potential flood risk for this property."
    }

    /// Questions homebuyers should ask about flood risk
    var questionsToAsk: [String] {
        if isSpecialFloodHazardArea {
            return [
                "What is the Base Flood Elevation (BFE) and how does this property compare?",
                "Has this property ever flooded? When and how severely?",
                "What is the annual flood insurance premium?",
                "Is there an Elevation Certificate for this property?",
                "What flood mitigation measures are in place (sump pump, backflow valves)?",
                "Is the property eligible for a Letter of Map Amendment (LOMA)?"
            ]
        } else {
            return [
                "Has this property or area ever experienced flooding?",
                "What would flood insurance cost even though it's not required?",
                "Are there any drainage issues on the property?"
            ]
        }
    }
}
