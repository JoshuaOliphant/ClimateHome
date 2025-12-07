// ABOUTME: Unified error types for all API calls in ClimateHome
// ABOUTME: Provides user-friendly messages for UI display

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(underlying: Error)
    case noData
    case geocodingFailed(reason: String)
    case serviceUnavailable(service: String)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "Server error (HTTP \(code))"
        case .decodingError(let error):
            return "Unable to parse response: \(error.localizedDescription)"
        case .noData:
            return "No data returned"
        case .geocodingFailed(let reason):
            return "Address lookup failed: \(reason)"
        case .serviceUnavailable(let service):
            return "\(service) is currently unavailable"
        case .timeout:
            return "Request timed out"
        }
    }
}
