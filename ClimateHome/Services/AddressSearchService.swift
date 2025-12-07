// ABOUTME: Wraps MKLocalSearchCompleter for address autocomplete functionality
// ABOUTME: Provides @Observable interface for SwiftUI integration with async coordinate lookup

import Foundation
import MapKit

/// Result from address autocomplete with optional coordinate
struct AddressSearchResult: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let completion: MKLocalSearchCompletion

    var fullAddress: String {
        subtitle.isEmpty ? title : "\(title), \(subtitle)"
    }

    static func == (lhs: AddressSearchResult, rhs: AddressSearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

/// Observable service for MapKit address autocomplete
@Observable
final class AddressSearchService: NSObject {
    var searchResults: [AddressSearchResult] = []
    var isSearching: Bool = false

    private let completer: MKLocalSearchCompleter
    private var currentQuery: String = ""

    override init() {
        completer = MKLocalSearchCompleter()
        completer.resultTypes = .address
        // Bias results toward Washington State
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.5, longitude: -120.5),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 7.0)
        )
        super.init()
        completer.delegate = self
    }

    /// Update search query - triggers autocomplete
    func search(query: String) {
        currentQuery = query

        guard query.count >= 3 else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        completer.queryFragment = query
    }

    /// Clear all search results
    func clearResults() {
        searchResults = []
        isSearching = false
        currentQuery = ""
    }

    /// Get coordinates for a selected completion result
    func getCoordinate(for result: AddressSearchResult) async throws -> (Coordinate, String) {
        let searchRequest = MKLocalSearch.Request(completion: result.completion)
        searchRequest.resultTypes = .address

        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()

        guard let mapItem = response.mapItems.first else {
            throw NetworkError.geocodingFailed(reason: "No results found for selected address")
        }

        // Get coordinates from location
        let location = mapItem.location
        let coordinate = Coordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        // Use the map item name or fall back to search result
        let formattedAddress = mapItem.name ?? result.fullAddress

        return (coordinate, formattedAddress)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressSearchService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Filter to Washington State addresses when possible
        searchResults = completer.results
            .filter { result in
                // Include if subtitle contains WA or Washington
                let subtitle = result.subtitle.lowercased()
                return subtitle.contains("wa") ||
                       subtitle.contains("washington") ||
                       subtitle.isEmpty // Include if no state specified yet
            }
            .prefix(5) // Limit to 5 suggestions
            .map { completion in
                AddressSearchResult(
                    title: completion.title,
                    subtitle: completion.subtitle,
                    completion: completion
                )
            }
        isSearching = false
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        searchResults = []
        isSearching = false
    }
}
