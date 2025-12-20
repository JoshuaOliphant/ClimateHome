// ABOUTME: Standardized risk levels across all data sources
// ABOUTME: Maps to visual indicators (green/yellow/red) in the UI

import SwiftUI

struct ExternalLink: Identifiable, Sendable {
    let id = UUID()
    let title: String
    let url: URL
}

enum RiskLevel: String, CaseIterable, Sendable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
    case unknown = "Unknown"

    var color: Color {
        switch self {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .orange
        case .veryHigh:
            return .red
        case .unknown:
            return .gray
        }
    }

    var systemImage: String {
        switch self {
        case .low:
            return "checkmark.circle.fill"
        case .moderate:
            return "exclamationmark.triangle.fill"
        case .high:
            return "exclamationmark.triangle.fill"
        case .veryHigh:
            return "xmark.octagon.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
}
