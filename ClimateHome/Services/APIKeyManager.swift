// ABOUTME: Manages EPA AirNow API key storage and retrieval
// ABOUTME: Automatically stores default key on first launch using Keychain

import Foundation

final class APIKeyManager: Sendable {

    /// Keychain identifier for the AirNow API key
    private static let airNowKeyIdentifier = "com.climatehome.airnow-api-key"

    /// Default API key to use on first launch
    private static let defaultAPIKey = "3EF833EE-DEEE-49AC-89A4-6512A20E0838"

    private init() {}

    /// Retrieves the AirNow API key from Keychain, or saves and returns the default key on first launch
    /// - Returns: The API key string
    static func getAirNowAPIKey() -> String {
        let keychain = KeychainService.shared

        // Try to retrieve existing key
        if let existingKey = keychain.get(key: airNowKeyIdentifier) {
            return existingKey
        }

        // First launch: save default key to Keychain
        do {
            try keychain.save(key: airNowKeyIdentifier, value: defaultAPIKey)
        } catch {
            // If save fails, still return the default key so the app works
            print("Warning: Failed to save API key to Keychain: \(error)")
        }

        return defaultAPIKey
    }

    /// Updates the AirNow API key in Keychain
    /// - Parameter newKey: The new API key to store
    /// - Throws: KeychainError if the save operation fails
    static func updateAirNowAPIKey(_ newKey: String) throws {
        try KeychainService.shared.save(key: airNowKeyIdentifier, value: newKey)
    }

    /// Deletes the AirNow API key from Keychain
    /// - Throws: KeychainError if the delete operation fails
    static func deleteAirNowAPIKey() throws {
        try KeychainService.shared.delete(key: airNowKeyIdentifier)
    }
}
