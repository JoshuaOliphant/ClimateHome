// ABOUTME: Wraps Census Bureau Geocoding API for address lookup
// ABOUTME: Uses onelineaddress endpoint for simpler input handling

import Foundation

struct GeocodingService {
    private let baseURL = "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress"

    func geocode(address: String) async throws -> (coordinate: Coordinate, formattedAddress: String) {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "address", value: address),
            URLQueryItem(name: "benchmark", value: "Public_AR_Current"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        let response: CensusGeocodeResponse = try await APIClient.shared.fetch(url)

        guard let match = response.result.addressMatches.first else {
            throw NetworkError.geocodingFailed(reason: "No matching address found. Please check the address and try again.")
        }

        let coordinate = Coordinate(
            latitude: match.coordinates.y,
            longitude: match.coordinates.x
        )

        return (coordinate, match.matchedAddress)
    }
}
