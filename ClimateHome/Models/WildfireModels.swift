// ABOUTME: Decodes WA DNR Wildland-Urban Interface identify response
// ABOUTME: Uses identify endpoint for raster layer; field names have "Raster." prefix

import Foundation

struct WUIIdentifyResponse: Codable {
    let results: [WUIIdentifyResult]
}

struct WUIIdentifyResult: Codable {
    let layerId: Int
    let layerName: String
    let displayFieldName: String?
    let attributes: WUIIdentifyAttributes
}

struct WUIIdentifyAttributes: Codable {
    let pixelValue: String?
    let objectId: String?
    let value: String?
    let count: String?
    let wuiDescNm: String?

    enum CodingKeys: String, CodingKey {
        case pixelValue = "UniqueValue.Pixel Value"
        case objectId = "Raster.OBJECTID"
        case value = "Raster.VALUE"
        case count = "Raster.COUNT"
        case wuiDescNm = "Raster.WUI_DESC_NM"
    }
}

struct WildfireRiskResult: Sendable {
    let level: RiskLevel
    let wuiClassification: String?
    let summary: String
    let dataSource: String

    /// Detailed explanation of what this risk level means for homebuyers
    var whatThisMeans: String {
        switch level {
        case .high, .veryHigh:
            return "This property is in the Wildland-Urban Interface (WUI), where homes meet or intermix with wildland vegetation. WUI properties face elevated wildfire risk and may have difficulty obtaining or affording homeowners insurance. Many insurers have stopped writing new policies in high-risk WUI areas. You may need to use the state FAIR Plan as a last resort."
        case .moderate:
            return "This property is in a WUI Intermix area, where homes are scattered among wildland vegetation. While risk is lower than Interface zones, wildfire preparedness is still important. Insurance may be available but could be more expensive than non-WUI properties."
        case .low:
            return "This property is not in a mapped Wildland-Urban Interface zone, indicating lower wildfire risk. However, smoke from regional wildfires can still affect air quality. Washington experienced significant wildfire seasons in recent years."
        case .unknown:
            return "Wildland-Urban Interface classification data is not available for this location."
        }
    }

    /// Questions homebuyers should ask about wildfire risk
    var questionsToAsk: [String] {
        switch level {
        case .high, .veryHigh:
            return [
                "Is this property Firewise certified or does it meet defensible space requirements?",
                "What fire-resistant materials are used (roof, siding, vents)?",
                "What is the current homeowners insurance premium? Has coverage been cancelled or non-renewed?",
                "What are the evacuation routes from this property?",
                "Is there a community wildfire protection plan?",
                "What is the fire department response time to this location?"
            ]
        case .moderate:
            return [
                "Does the property have defensible space around the home?",
                "What is the homeowners insurance situation for wildfire coverage?",
                "What fire-resistant features does the home have?",
                "What are the evacuation routes?"
            ]
        case .low, .unknown:
            return [
                "Has wildfire smoke been an issue in this area?",
                "What is the homeowners insurance cost?"
            ]
        }
    }

    /// External links to official wildfire data sources
    var externalLinks: [ExternalLink] {
        return [
            ExternalLink(title: "WA DNR Wildfire Ready", url: URL(string: "https://www.dnr.wa.gov/wildfire")!),
            ExternalLink(title: "Firewise USA", url: URL(string: "https://www.nfpa.org/firewise")!)
        ]
    }
}
