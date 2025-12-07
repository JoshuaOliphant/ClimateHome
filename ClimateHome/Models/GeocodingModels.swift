// ABOUTME: Decodes Census Bureau Geocoding API JSON response
// ABOUTME: Extracts coordinates from matched address results

import Foundation

struct CensusGeocodeResponse: Codable {
    let result: CensusResult
}

struct CensusResult: Codable {
    let addressMatches: [AddressMatch]
}

struct AddressMatch: Codable {
    let matchedAddress: String
    let coordinates: CensusCoordinates

    struct CensusCoordinates: Codable {
        let x: Double  // longitude
        let y: Double  // latitude
    }
}
