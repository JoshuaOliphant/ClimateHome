// ABOUTME: Represents geographic coordinates for API queries
// ABOUTME: Used throughout the app for location-based risk lookups

import Foundation

struct Coordinate: Codable, Sendable, Equatable {
    let latitude: Double
    let longitude: Double

    var asArcGISPoint: String {
        // ArcGIS uses {x: longitude, y: latitude} format
        return "{\"x\":\(longitude),\"y\":\(latitude)}"
    }

    var asCommaSeparated: String {
        // Some APIs use "longitude,latitude" format
        return "\(longitude),\(latitude)"
    }
}
