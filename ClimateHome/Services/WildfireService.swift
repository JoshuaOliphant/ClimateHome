// ABOUTME: Queries WA DNR WUI MapServer for wildfire interface classification
// ABOUTME: Uses identify endpoint since WUI layer is a raster, not feature layer

import Foundation

struct WildfireService {
    private let baseURL = "https://gis.dnr.wa.gov/site3/rest/services/Public_Wildfire/WADNR_PUBLIC_WD_WUI/MapServer/identify"

    func checkWUI(at coordinate: Coordinate) async throws -> WildfireRiskResult {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        let geometry = "\(coordinate.longitude),\(coordinate.latitude)"
        let mapExtent = "\(coordinate.longitude - 0.01),\(coordinate.latitude - 0.01),\(coordinate.longitude + 0.01),\(coordinate.latitude + 0.01)"

        components.queryItems = [
            URLQueryItem(name: "geometry", value: geometry),
            URLQueryItem(name: "geometryType", value: "esriGeometryPoint"),
            URLQueryItem(name: "sr", value: "4326"),
            URLQueryItem(name: "layers", value: "all"),
            URLQueryItem(name: "tolerance", value: "1"),
            URLQueryItem(name: "mapExtent", value: mapExtent),
            URLQueryItem(name: "imageDisplay", value: "100,100,96"),
            URLQueryItem(name: "returnGeometry", value: "false"),
            URLQueryItem(name: "f", value: "json")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: WUIIdentifyResponse = try await APIClient.shared.fetch(url)

        return parseWUIResponse(response)
    }

    private func parseWUIResponse(_ response: WUIIdentifyResponse) -> WildfireRiskResult {
        guard let result = response.results.first,
              let classification = result.attributes.wuiDescNm else {
            return WildfireRiskResult(
                level: .low,
                wuiClassification: nil,
                summary: "Not in Wildland-Urban Interface zone",
                dataSource: "WA DNR WUI 2019"
            )
        }

        let level: RiskLevel
        let summary: String

        let classLower = classification.lowercased()

        if classLower.contains("interface") && classLower.contains("high") {
            level = .high
            summary = "WUI Interface (High Density) - Highest wildfire risk"
        } else if classLower.contains("interface") {
            level = .high
            summary = "WUI Interface - High wildfire risk where homes meet wildland"
        } else if classLower.contains("intermix") && classLower.contains("high") {
            level = .moderate
            summary = "WUI Intermix (High Density) - Elevated wildfire risk"
        } else if classLower.contains("intermix") {
            level = .moderate
            summary = "WUI Intermix - Homes scattered among wildland vegetation"
        } else {
            level = .low
            summary = "WUI Classification: \(classification)"
        }

        return WildfireRiskResult(
            level: level,
            wuiClassification: classification,
            summary: summary,
            dataSource: "WA DNR WUI 2019"
        )
    }
}
