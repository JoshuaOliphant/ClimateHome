// ABOUTME: Queries EPA AirNow API for current air quality observations
// ABOUTME: Requires free API key from airnowapi.org

import Foundation

struct AirQualityService {
    private let baseURL = "https://www.airnowapi.org/aq/observation/latLong/current/"
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func checkAirQuality(at coordinate: Coordinate) async throws -> AirQualityRiskResult {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "distance", value: "25"),  // 25 mile radius
            URLQueryItem(name: "format", value: "application/json"),
            URLQueryItem(name: "API_KEY", value: apiKey)
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let observations: [AirNowObservation] = try await APIClient.shared.fetch(url)

        return parseAirQualityResponse(observations)
    }

    private func parseAirQualityResponse(_ observations: [AirNowObservation]) -> AirQualityRiskResult {
        guard let worstObs = observations.max(by: { $0.AQI < $1.AQI }) else {
            return AirQualityRiskResult(
                level: .unknown,
                currentAQI: nil,
                category: nil,
                reportingArea: nil,
                summary: "No air quality data available",
                dataSource: "EPA AirNow"
            )
        }

        let level: RiskLevel
        switch worstObs.Category.Number {
        case 1:  // Good (0-50)
            level = .low
        case 2:  // Moderate (51-100)
            level = .low
        case 3:  // Unhealthy for Sensitive Groups (101-150)
            level = .moderate
        default: // Unhealthy (151+)
            level = .high
        }

        return AirQualityRiskResult(
            level: level,
            currentAQI: worstObs.AQI,
            category: worstObs.Category.Name,
            reportingArea: worstObs.ReportingArea,
            summary: "AQI \(worstObs.AQI) - \(worstObs.Category.Name)",
            dataSource: "EPA AirNow"
        )
    }
}
