// ABOUTME: Queries WA DNR Ground Response MapServer for liquefaction susceptibility
// ABOUTME: Uses ArcGIS query endpoint with point-in-polygon spatial query

import Foundation

struct EarthquakeService {
    private let baseURL = "https://gis.dnr.wa.gov/site1/rest/services/Public_Geology/Ground_Response/MapServer/0/query"

    func checkLiquefaction(at coordinate: Coordinate) async throws -> EarthquakeRiskResult {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "geometry", value: "\(coordinate.longitude),\(coordinate.latitude)"),
            URLQueryItem(name: "geometryType", value: "esriGeometryPoint"),
            URLQueryItem(name: "inSR", value: "4326"),
            URLQueryItem(name: "spatialRel", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "LIQUEFACTION_SUSCEPT,LIQUEFACTION_SUSCEPT_ID"),
            URLQueryItem(name: "returnGeometry", value: "false"),
            URLQueryItem(name: "f", value: "json")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: LiquefactionQueryResponse = try await APIClient.shared.fetch(url)

        return parseLiquefactionResponse(response)
    }

    private func parseLiquefactionResponse(_ response: LiquefactionQueryResponse) -> EarthquakeRiskResult {
        guard let feature = response.features.first,
              let susceptibility = feature.attributes.liquefactionSuscept else {
            return EarthquakeRiskResult(
                level: .unknown,
                liquefactionSusceptibility: nil,
                summary: "No liquefaction data available for this location",
                dataSource: "WA DNR Ground Response"
            )
        }

        let level: RiskLevel
        let summary: String

        let susceptLower = susceptibility.lowercased()

        switch susceptLower {
        case "very high":
            level = .veryHigh
            summary = "Very High liquefaction susceptibility - severe ground failure risk"
        case "high":
            level = .high
            summary = "High liquefaction susceptibility - significant ground failure risk"
        case "moderate to high", "moderate-high":
            level = .high
            summary = "Moderate to High liquefaction susceptibility"
        case "moderate":
            level = .moderate
            summary = "Moderate liquefaction susceptibility"
        case "low to moderate", "low-moderate":
            level = .moderate
            summary = "Low to Moderate liquefaction susceptibility"
        case "low":
            level = .low
            summary = "Low liquefaction susceptibility"
        case "very low":
            level = .low
            summary = "Very Low liquefaction susceptibility"
        case "peat", "bedrock", "water", "ice and glaciers":
            level = .low
            summary = "Not susceptible to liquefaction (\(susceptibility))"
        default:
            level = .low
            summary = "Liquefaction classification: \(susceptibility)"
        }

        return EarthquakeRiskResult(
            level: level,
            liquefactionSusceptibility: susceptibility,
            summary: summary,
            dataSource: "WA DNR Ground Response 2007"
        )
    }
}
