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
}
