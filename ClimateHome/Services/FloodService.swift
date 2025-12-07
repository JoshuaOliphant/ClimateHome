// ABOUTME: Queries FEMA NFHL MapServer for flood zone classification
// ABOUTME: Layer 28 (S_Fld_Haz_Ar) contains regulatory flood zones

import Foundation

struct FloodService {
    private let baseURL = "https://hazards.fema.gov/arcgis/rest/services/public/NFHL/MapServer/28/query"

    func checkFloodZone(at coordinate: Coordinate) async throws -> FloodRiskResult {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "geometry", value: coordinate.asCommaSeparated),
            URLQueryItem(name: "geometryType", value: "esriGeometryPoint"),
            URLQueryItem(name: "inSR", value: "4326"),
            URLQueryItem(name: "spatialRel", value: "esriSpatialRelWithin"),
            URLQueryItem(name: "outFields", value: "FLD_ZONE,ZONE_SUBTY,SFHA_TF"),
            URLQueryItem(name: "returnGeometry", value: "false"),
            URLQueryItem(name: "f", value: "json")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: NFHLQueryResponse = try await APIClient.shared.fetch(url)

        return parseFloodResponse(response)
    }

    private func parseFloodResponse(_ response: NFHLQueryResponse) -> FloodRiskResult {
        guard let feature = response.features.first,
              let zone = feature.attributes.FLD_ZONE else {
            return FloodRiskResult(
                level: .unknown,
                floodZone: nil,
                isSpecialFloodHazardArea: false,
                summary: "No flood zone data available for this location",
                dataSource: "FEMA NFHL"
            )
        }

        let isSFHA = feature.attributes.SFHA_TF == "T"
        let level: RiskLevel
        let summary: String

        switch zone.uppercased() {
        case "X", "AREA NOT INCLUDED":
            level = .low
            summary = "Zone X - Minimal flood hazard area"
        case "A", "AE", "AH", "AO", "AR":
            level = .high
            summary = "Zone \(zone) - Special Flood Hazard Area (1% annual chance flood)"
        case "V", "VE":
            level = .high
            summary = "Zone \(zone) - Coastal high velocity flood zone"
        case "D":
            level = .moderate
            summary = "Zone D - Undetermined flood hazard"
        default:
            level = .moderate
            summary = "Zone \(zone)"
        }

        return FloodRiskResult(
            level: level,
            floodZone: zone,
            isSpecialFloodHazardArea: isSFHA,
            summary: summary,
            dataSource: "FEMA NFHL"
        )
    }
}
