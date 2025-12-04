import Foundation
import Security

/// Manager for securely storing encryption keys in macOS Keychain
public final class KeychainManager {

    private let service = "com.carboclip.app.encryption"

    public init() {}

    // MARK: - Key Operations

    /// Stores encryption key in Keychain
    /// - Parameters:
    ///   - key: The encryption key data (should be 32 bytes for AES-256)
    ///   - identifier: Unique identifier for this key
    /// - Throws: KeychainError.storeFailed if storage fails
    public func storeKey(_ key: Data, identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing if present (to support updates)
        SecItemDelete(query as CFDictionary)

        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }

    /// Retrieves encryption key from Keychain
    /// - Parameter identifier: Unique identifier for the key
    /// - Returns: The encryption key data
    /// - Throws: KeychainError.retrieveFailed if retrieval fails
    public func retrieveKey(identifier: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let keyData = result as? Data else {
            throw KeychainError.retrieveFailed(status)
        }

        return keyData
    }

    /// Deletes key from Keychain
    /// - Parameter identifier: Unique identifier for the key
    /// - Throws: KeychainError.deleteFailed if deletion fails
    public func deleteKey(identifier: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Success or item not found are both acceptable outcomes
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - Errors

    public enum KeychainError: Error, Equatable {
        case storeFailed(OSStatus)
        case retrieveFailed(OSStatus)
        case deleteFailed(OSStatus)

        public static func == (lhs: KeychainError, rhs: KeychainError) -> Bool {
            switch (lhs, rhs) {
            case (.storeFailed(let lStatus), .storeFailed(let rStatus)):
                return lStatus == rStatus
            case (.retrieveFailed(let lStatus), .retrieveFailed(let rStatus)):
                return lStatus == rStatus
            case (.deleteFailed(let lStatus), .deleteFailed(let rStatus)):
                return lStatus == rStatus
            default:
                return false
            }
        }
    }
}
