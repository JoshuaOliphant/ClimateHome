// ABOUTME: Unit and integration tests for ClimateHome API services
// ABOUTME: Tests risk level parsing, API responses, and data accuracy

import Testing
import Foundation
@testable import ClimateHome

// MARK: - Risk Level Tests

struct RiskLevelTests {

    @Test func riskLevelColors() {
        #expect(RiskLevel.low.color != RiskLevel.high.color)
        #expect(RiskLevel.moderate.color != RiskLevel.high.color)
        #expect(RiskLevel.veryHigh.color != RiskLevel.high.color) // veryHigh is red, high is orange
    }

    @Test func riskLevelSystemImages() {
        #expect(RiskLevel.low.systemImage == "checkmark.circle.fill")
        #expect(RiskLevel.high.systemImage == "exclamationmark.triangle.fill")
        #expect(RiskLevel.unknown.systemImage == "questionmark.circle.fill")
    }

    @Test func riskLevelRawValues() {
        #expect(RiskLevel.low.rawValue == "Low")
        #expect(RiskLevel.moderate.rawValue == "Moderate")
        #expect(RiskLevel.high.rawValue == "High")
        #expect(RiskLevel.veryHigh.rawValue == "Very High")
        #expect(RiskLevel.unknown.rawValue == "Unknown")
    }
}

// MARK: - Flood Risk Tests

struct FloodRiskTests {

    @Test func floodRiskResultSFHAQuestions() {
        let sfhaResult = FloodRiskResult(
            level: .high,
            floodZone: "AE",
            isSpecialFloodHazardArea: true,
            summary: "Zone AE",
            dataSource: "FEMA NFHL"
        )

        #expect(sfhaResult.questionsToAsk.count >= 5)
        #expect(sfhaResult.questionsToAsk.contains { $0.contains("Elevation Certificate") })
    }

    @Test func floodRiskResultNonSFHAQuestions() {
        let nonSfhaResult = FloodRiskResult(
            level: .low,
            floodZone: "X",
            isSpecialFloodHazardArea: false,
            summary: "Zone X",
            dataSource: "FEMA NFHL"
        )

        #expect(nonSfhaResult.questionsToAsk.count >= 2)
        #expect(nonSfhaResult.questionsToAsk.count < 5)
    }

    @Test func floodRiskExternalLinks() {
        let result = FloodRiskResult(
            level: .low,
            floodZone: "X",
            isSpecialFloodHazardArea: false,
            summary: "Zone X",
            dataSource: "FEMA NFHL"
        )

        #expect(result.externalLinks.count == 2)
        #expect(result.externalLinks.allSatisfy { $0.url.absoluteString.contains("fema.gov") })
    }
}

// MARK: - Earthquake Risk Tests

struct EarthquakeRiskTests {

    @Test func earthquakeHighRiskQuestions() {
        let result = EarthquakeRiskResult(
            level: .high,
            liquefactionSusceptibility: "high",
            summary: "High liquefaction",
            dataSource: "WA DNR"
        )

        #expect(result.questionsToAsk.count >= 4)
        #expect(result.questionsToAsk.contains { $0.contains("foundation") })
    }

    @Test func earthquakeLowRiskQuestions() {
        let result = EarthquakeRiskResult(
            level: .low,
            liquefactionSusceptibility: "low",
            summary: "Low liquefaction",
            dataSource: "WA DNR"
        )

        #expect(result.questionsToAsk.count >= 2)
    }

    @Test func earthquakeWhatThisMeansVariesByLevel() {
        let highResult = EarthquakeRiskResult(
            level: .high,
            liquefactionSusceptibility: "high",
            summary: "High",
            dataSource: "WA DNR"
        )

        let lowResult = EarthquakeRiskResult(
            level: .low,
            liquefactionSusceptibility: "low",
            summary: "Low",
            dataSource: "WA DNR"
        )

        #expect(highResult.whatThisMeans != lowResult.whatThisMeans)
        #expect(highResult.whatThisMeans.contains("liquid") || highResult.whatThisMeans.contains("sink"))
    }
}

// MARK: - Volcano Risk Tests

struct VolcanoRiskTests {

    @Test func volcanoInLaharZoneQuestions() {
        let result = VolcanoRiskResult(
            level: .high,
            inLaharZone: true,
            volcano: "Mount Rainier",
            hazardDescription: "Lahar zone",
            summary: "In lahar zone",
            dataSource: "WA DNR"
        )

        #expect(result.questionsToAsk.count >= 4)
        #expect(result.questionsToAsk.contains { $0.contains("evacuation") })
        #expect(result.questionsToAsk.contains { $0.contains("warning") })
    }

    @Test func volcanoNotInLaharZoneQuestions() {
        let result = VolcanoRiskResult(
            level: .low,
            inLaharZone: false,
            volcano: nil,
            hazardDescription: nil,
            summary: "Not in lahar zone",
            dataSource: "WA DNR"
        )

        #expect(result.questionsToAsk.count <= 3)
    }

    @Test func volcanoWhatThisMeansForLaharZone() {
        let result = VolcanoRiskResult(
            level: .high,
            inLaharZone: true,
            volcano: "Mount Rainier",
            hazardDescription: nil,
            summary: "In lahar zone",
            dataSource: "WA DNR"
        )

        #expect(result.whatThisMeans.contains("lahar") || result.whatThisMeans.contains("mudflow"))
        #expect(result.whatThisMeans.contains("30") || result.whatThisMeans.contains("mph"))
    }
}

// MARK: - Air Quality Risk Tests

struct AirQualityRiskTests {

    @Test func airQualityGoodAQI() {
        let result = AirQualityRiskResult(
            level: .low,
            currentAQI: 42,
            category: "Good",
            reportingArea: "Seattle",
            summary: "AQI 42 - Good",
            dataSource: "EPA AirNow"
        )

        #expect(result.whatThisMeans.contains("Good"))
        #expect(result.questionsToAsk.count >= 1)
    }

    @Test func airQualityUnhealthyAQI() {
        let result = AirQualityRiskResult(
            level: .high,
            currentAQI: 155,
            category: "Unhealthy",
            reportingArea: "Seattle",
            summary: "AQI 155 - Unhealthy",
            dataSource: "EPA AirNow"
        )

        #expect(result.whatThisMeans.contains("Unhealthy") || result.whatThisMeans.contains("health"))
        #expect(result.questionsToAsk.count >= 3)
    }

    @Test func airQualityExternalLinks() {
        let result = AirQualityRiskResult(
            level: .low,
            currentAQI: 42,
            category: "Good",
            reportingArea: "Seattle",
            summary: "AQI 42",
            dataSource: "EPA AirNow"
        )

        #expect(result.externalLinks.count >= 2)
        #expect(result.externalLinks.contains { $0.url.absoluteString.contains("airnow") })
    }
}

// MARK: - Wildfire Risk Tests

struct WildfireRiskTests {

    @Test func wildfireHighRiskQuestions() {
        let result = WildfireRiskResult(
            level: .high,
            wuiClassification: "Interface High Density",
            summary: "WUI Interface",
            dataSource: "WA DNR WUI 2019"
        )

        #expect(result.questionsToAsk.count >= 5)
        #expect(result.questionsToAsk.contains { $0.contains("defensible space") || $0.contains("Firewise") })
        #expect(result.questionsToAsk.contains { $0.contains("insurance") })
    }

    @Test func wildfireLowRiskQuestions() {
        let result = WildfireRiskResult(
            level: .low,
            wuiClassification: nil,
            summary: "Not in WUI",
            dataSource: "WA DNR WUI 2019"
        )

        #expect(result.questionsToAsk.count <= 3)
    }

    @Test func wildfireWhatThisMeansForWUI() {
        let result = WildfireRiskResult(
            level: .high,
            wuiClassification: "Interface",
            summary: "WUI Interface",
            dataSource: "WA DNR WUI 2019"
        )

        #expect(result.whatThisMeans.contains("Wildland-Urban Interface") || result.whatThisMeans.contains("WUI"))
        #expect(result.whatThisMeans.contains("insurance"))
    }
}

// MARK: - Integration Tests (Real API Calls)

struct GeocodingServiceTests {

    @Test func geocodeSeattleAddress() async throws {
        let service = GeocodingService()

        let result = try await service.geocode(address: "700 5th Ave, Seattle, WA 98104")

        #expect(result.coordinate.latitude > 47.0 && result.coordinate.latitude < 48.0)
        #expect(result.coordinate.longitude < -122.0 && result.coordinate.longitude > -123.0)
        #expect(result.formattedAddress.uppercased().contains("SEATTLE"))
    }

    @Test func geocodeInvalidAddressThrows() async {
        let service = GeocodingService()

        await #expect(throws: NetworkError.self) {
            _ = try await service.geocode(address: "zzzzz invalid address 99999")
        }
    }
}

struct FloodServiceTests {

    @Test func checkFloodZoneDowntownSeattle() async throws {
        let service = FloodService()
        // Downtown Seattle - should be Zone X (minimal flood hazard)
        let coordinate = Coordinate(latitude: 47.6062, longitude: -122.3321)

        let result = try await service.checkFloodZone(at: coordinate)

        #expect(result.floodZone == "X" || result.floodZone == nil)
        #expect(result.level == .low || result.level == .unknown)
    }

    @Test func checkFloodZoneSnoqualmie() async throws {
        let service = FloodService()
        // Snoqualmie - known flood zone area
        let coordinate = Coordinate(latitude: 47.528429, longitude: -121.826355)

        let result = try await service.checkFloodZone(at: coordinate)

        #expect(result.floodZone == "AE" || result.floodZone == "A")
        #expect(result.isSpecialFloodHazardArea == true)
        #expect(result.level == .high)
    }
}

struct EarthquakeServiceTests {

    @Test func checkLiquefactionDowntownSeattle() async throws {
        let service = EarthquakeService()
        // Downtown Seattle on bedrock - should be low/very low
        let coordinate = Coordinate(latitude: 47.6062, longitude: -122.3321)

        let result = try await service.checkLiquefaction(at: coordinate)

        #expect(result.level == .low || result.liquefactionSusceptibility?.lowercased().contains("low") == true)
    }

    @Test func checkLiquefactionSODO() async throws {
        let service = EarthquakeService()
        // SODO area - fill/tide flats, should be moderate to high
        let coordinate = Coordinate(latitude: 47.550404, longitude: -122.334135)

        let result = try await service.checkLiquefaction(at: coordinate)

        #expect(result.level == .high || result.level == .moderate)
        #expect(result.liquefactionSusceptibility != nil)
    }
}

struct VolcanoServiceTests {

    @Test func checkLaharZoneOrting() async throws {
        let service = VolcanoService()
        // Orting - known Mt. Rainier lahar zone
        let coordinate = Coordinate(latitude: 47.099196, longitude: -122.202697)

        let result = try await service.checkLaharZone(at: coordinate)

        #expect(result.inLaharZone == true)
        #expect(result.level == .high)
        #expect(result.volcano?.contains("Rainier") == true)
    }

    @Test func checkLaharZoneSeattle() async throws {
        let service = VolcanoService()
        // Seattle - not in lahar zone
        let coordinate = Coordinate(latitude: 47.6062, longitude: -122.3321)

        let result = try await service.checkLaharZone(at: coordinate)

        #expect(result.inLaharZone == false)
        #expect(result.level == .low)
    }
}

struct WildfireServiceTests {

    @Test func checkWUIWinthrop() async throws {
        let service = WildfireService()
        // Winthrop - known WUI area in Methow Valley
        let coordinate = Coordinate(latitude: 48.478065, longitude: -120.185945)

        let result = try await service.checkWUI(at: coordinate)

        #expect(result.wuiClassification != nil)
        #expect(result.wuiClassification?.lowercased().contains("interface") == true ||
                result.wuiClassification?.lowercased().contains("intermix") == true)
        #expect(result.level == .high || result.level == .moderate)
    }

    @Test func checkWUIDowntownSeattle() async throws {
        let service = WildfireService()
        // Downtown Seattle - should not be in WUI
        let coordinate = Coordinate(latitude: 47.6062, longitude: -122.3321)

        let result = try await service.checkWUI(at: coordinate)

        #expect(result.level == .low)
    }
}

// MARK: - Coordinate Tests

struct CoordinateTests {

    @Test func coordinateAsCommaSeparated() {
        let coordinate = Coordinate(latitude: 47.6062, longitude: -122.3321)

        #expect(coordinate.asCommaSeparated == "-122.3321,47.6062")
    }
}

// MARK: - External Link Tests

struct ExternalLinkTests {

    @Test func externalLinkIdentifiable() {
        let link1 = ExternalLink(title: "Test", url: URL(string: "https://example.com")!)
        let link2 = ExternalLink(title: "Test", url: URL(string: "https://example.com")!)

        // Each link should have unique ID
        #expect(link1.id != link2.id)
    }
}

// MARK: - Keychain Tests

struct KeychainServiceTests {

    @Test func saveAndRetrieveValue() throws {
        let service = KeychainService.shared
        let testKey = "com.climatehome.test.key.\(UUID().uuidString)"
        let testValue = "test-value-\(UUID().uuidString)"

        // Clean up first
        try? service.delete(key: testKey)

        // Save
        try service.save(key: testKey, value: testValue)

        // Retrieve
        let retrieved = service.get(key: testKey)
        #expect(retrieved == testValue)

        // Clean up
        try service.delete(key: testKey)
    }

    @Test func retrieveNonExistentKeyReturnsNil() {
        let service = KeychainService.shared
        let testKey = "com.climatehome.nonexistent.\(UUID().uuidString)"

        let result = service.get(key: testKey)
        #expect(result == nil)
    }

    @Test func updateExistingValue() throws {
        let service = KeychainService.shared
        let testKey = "com.climatehome.test.update.\(UUID().uuidString)"

        // Clean up first
        try? service.delete(key: testKey)

        // Save initial
        try service.save(key: testKey, value: "initial")

        // Update
        try service.save(key: testKey, value: "updated")

        // Verify update
        let retrieved = service.get(key: testKey)
        #expect(retrieved == "updated")

        // Clean up
        try service.delete(key: testKey)
    }
}
