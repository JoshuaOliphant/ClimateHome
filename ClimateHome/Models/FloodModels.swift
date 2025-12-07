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
}
