// ABOUTME: Main view model for risk lookup screen
// ABOUTME: Uses iOS 17+ @Observable macro, orchestrates parallel API calls

import SwiftUI

@Observable
class RiskLookupViewModel {
    var addressInput: String = ""
    var isLoading: Bool = false
    var currentReport: PropertyRiskReport?
    var errorMessage: String?
    var lastLookupDuration: TimeInterval?

    // Selected MapKit result (when user picks from autocomplete)
    var selectedSearchResult: AddressSearchResult?

    let addressSearchService = AddressSearchService()

    private let geocodingService = GeocodingService()
    private let wildfireService = WildfireService()
    private let floodService = FloodService()
    private let earthquakeService = EarthquakeService()
    private var airQualityService: AirQualityService?

    init(airNowAPIKey: String? = nil) {
        if let key = airNowAPIKey, !key.isEmpty {
            self.airQualityService = AirQualityService(apiKey: key)
        }
    }

    /// Called when user selects an autocomplete suggestion
    func selectSearchResult(_ result: AddressSearchResult) {
        selectedSearchResult = result
        addressSearchService.clearResults()
    }

    @MainActor
    func performLookup() async {
        let trimmedAddress = addressInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedAddress.isEmpty else {
            errorMessage = "Please enter an address"
            return
        }

        isLoading = true
        errorMessage = nil
        currentReport = nil

        let startTime = Date()
        var report = PropertyRiskReport(
            address: addressInput,
            formattedAddress: nil,
            coordinate: nil
        )

        do {
            let coordinate: Coordinate
            let formattedAddress: String
            let geocodeTime: Int

            // Use MapKit coordinates if user selected from autocomplete
            if let selectedResult = selectedSearchResult {
                let geocodeStart = Date()
                (coordinate, formattedAddress) = try await addressSearchService.getCoordinate(for: selectedResult)
                geocodeTime = Int(Date().timeIntervalSince(geocodeStart) * 1000)
                selectedSearchResult = nil // Clear after use
            } else {
                // Fall back to Census Bureau geocoding for manual entry
                let geocodeStart = Date()
                (coordinate, formattedAddress) = try await geocodingService.geocode(address: trimmedAddress)
                geocodeTime = Int(Date().timeIntervalSince(geocodeStart) * 1000)
            }

            report = PropertyRiskReport(
                address: addressInput,
                formattedAddress: formattedAddress,
                coordinate: coordinate,
                geocodingTimeMs: geocodeTime
            )

            await queryRiskAPIs(coordinate: coordinate, report: &report)

            report.totalTimeMs = Int(Date().timeIntervalSince(startTime) * 1000)
            lastLookupDuration = Date().timeIntervalSince(startTime)
            currentReport = report

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    private func queryRiskAPIs(coordinate: Coordinate, report: inout PropertyRiskReport) async {
        await withTaskGroup(of: RiskQueryResult.self) { group in
            group.addTask {
                do {
                    let result = try await self.wildfireService.checkWUI(at: coordinate)
                    return .wildfire(result)
                } catch {
                    return .error("Wildfire: \(error.localizedDescription)")
                }
            }

            group.addTask {
                do {
                    let result = try await self.floodService.checkFloodZone(at: coordinate)
                    return .flood(result)
                } catch {
                    return .error("Flood: \(error.localizedDescription)")
                }
            }

            group.addTask {
                do {
                    let result = try await self.earthquakeService.checkLiquefaction(at: coordinate)
                    return .earthquake(result)
                } catch {
                    return .error("Earthquake: \(error.localizedDescription)")
                }
            }

            if let airService = self.airQualityService {
                group.addTask {
                    do {
                        let result = try await airService.checkAirQuality(at: coordinate)
                        return .airQuality(result)
                    } catch {
                        return .error("Air Quality: \(error.localizedDescription)")
                    }
                }
            }

            for await result in group {
                switch result {
                case .wildfire(let data):
                    report.wildfireRisk = data
                case .flood(let data):
                    report.floodRisk = data
                case .earthquake(let data):
                    report.earthquakeRisk = data
                case .airQuality(let data):
                    report.airQualityRisk = data
                case .error(let message):
                    report.errors.append(message)
                }
            }
        }
    }
}

private enum RiskQueryResult: Sendable {
    case wildfire(WildfireRiskResult)
    case flood(FloodRiskResult)
    case earthquake(EarthquakeRiskResult)
    case airQuality(AirQualityRiskResult)
    case error(String)
}
