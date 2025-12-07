// ABOUTME: Queries WA DNR Volcanic Hazards MapServer for lahar zone data
// ABOUTME: Checks if a location is within mapped lahar hazard zones for WA volcanoes

import Foundation

struct VolcanoService {
    private let baseURL = "https://gis.dnr.wa.gov/site1/rest/services/Public_Geology/Volcanic_Hazards/MapServer/0/query"

    func checkLaharZone(at coordinate: Coordinate) async throws -> VolcanoRiskResult {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "geometry", value: "\(coordinate.longitude),\(coordinate.latitude)"),
            URLQueryItem(name: "geometryType", value: "esriGeometryPoint"),
            URLQueryItem(name: "inSR", value: "4326"),
            URLQueryItem(name: "spatialRel", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "where", value: "HAZARD_TYPE='Lahars'"),
            URLQueryItem(name: "outFields", value: "VOLCANO,HAZARD_TYPE,DESCRIPTION,WHATTODO1,WHATTODO2"),
            URLQueryItem(name: "returnGeometry", value: "false"),
            URLQueryItem(name: "f", value: "json")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: VolcanicHazardQueryResponse = try await APIClient.shared.fetch(url)

        return parseLaharResponse(response)
    }

    private func parseLaharResponse(_ response: VolcanicHazardQueryResponse) -> VolcanoRiskResult {
        // If no features returned, location is not in a lahar zone
        guard let feature = response.features.first else {
            return VolcanoRiskResult(
                level: .low,
                inLaharZone: false,
                volcano: nil,
                hazardDescription: nil,
                summary: "Not in a mapped lahar hazard zone",
                dataSource: "WA DNR/USGS Volcanic Hazards 2016"
            )
        }

        let volcano = feature.attributes.volcano ?? "Unknown volcano"
        let description = feature.attributes.description

        // All lahar zones are considered high risk
        let level: RiskLevel = .high
        let summary: String

        if let desc = description, !desc.isEmpty {
            summary = "\(volcano) lahar zone - \(desc)"
        } else {
            summary = "In \(volcano) lahar hazard zone"
        }

        return VolcanoRiskResult(
            level: level,
            inLaharZone: true,
            volcano: volcano,
            hazardDescription: description,
            summary: summary,
            dataSource: "WA DNR/USGS Volcanic Hazards 2016"
        )
    }
}
