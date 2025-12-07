// ABOUTME: Decodes WA DNR Volcanic Hazards MapServer query response
// ABOUTME: Contains lahar and other volcanic hazard zone data for WA volcanoes

import Foundation

struct VolcanicHazardQueryResponse: Codable {
    let features: [VolcanicHazardFeature]
}

struct VolcanicHazardFeature: Codable {
    let attributes: VolcanicHazardAttributes
}

struct VolcanicHazardAttributes: Codable {
    let volcano: String?
    let hazardType: String?
    let description: String?
    let whatToDo1: String?
    let whatToDo2: String?

    enum CodingKeys: String, CodingKey {
        case volcano = "VOLCANO"
        case hazardType = "HAZARD_TYPE"
        case description = "DESCRIPTION"
        case whatToDo1 = "WHATTODO1"
        case whatToDo2 = "WHATTODO2"
    }
}

struct VolcanoRiskResult: Sendable {
    let level: RiskLevel
    let inLaharZone: Bool
    let volcano: String?
    let hazardDescription: String?
    let summary: String
    let dataSource: String

    /// Detailed explanation of what this risk level means for homebuyers
    var whatThisMeans: String {
        if inLaharZone {
            return "This property is in a lahar (volcanic mudflow) hazard zone. Lahars are fast-moving rivers of mud, rock, and debris that can travel down valleys at 30-50 mph with little warning. They are one of the deadliest volcanic hazards. Mt. Rainier lahars could reach this area within 30-60 minutes of onset."
        } else {
            return "This property is not in a mapped lahar hazard zone. However, volcanic ash from a major eruption could still affect the area. Washington has 5 active volcanoes, with Mt. Rainier considered one of the most dangerous in the US due to its proximity to populated areas."
        }
    }

    /// Questions homebuyers should ask about volcano risk
    var questionsToAsk: [String] {
        if inLaharZone {
            return [
                "Is this property enrolled in the lahar warning system?",
                "What are the evacuation routes from this location?",
                "How far is the nearest high ground or safe zone?",
                "Does the seller have volcano insurance? What does it cost?",
                "Are there lahar warning sirens in this area?"
            ]
        } else {
            return [
                "What is the evacuation plan for volcanic events in this area?",
                "How might volcanic ash affect this property?"
            ]
        }
    }
}
