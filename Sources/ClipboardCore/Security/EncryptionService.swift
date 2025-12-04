import Foundation
import CryptoKit

/// Service for encrypting and decrypting clipboard data using AES-256-GCM
public final class EncryptionService {

    public init() {}

    // MARK: - Key Generation

    /// Generates a 256-bit encryption key
    public func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }

    // MARK: - Encryption/Decryption

    /// Encrypts data using AES-256-GCM
    /// - Parameters:
    ///   - data: The plaintext data to encrypt
    ///   - key: The 256-bit encryption key
    /// - Returns: Encrypted data (includes nonce and authentication tag)
    /// - Throws: EncryptionError.encryptionFailed if encryption fails
    public func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combined
    }

    /// Decrypts data using AES-256-GCM
    /// - Parameters:
    ///   - encryptedData: The encrypted data (includes nonce and authentication tag)
    ///   - key: The 256-bit encryption key
    /// - Returns: Decrypted plaintext data
    /// - Throws: CryptoKitError if decryption or authentication fails
    public func decrypt(_ encryptedData: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - HMAC (for tampering detection)

    /// Generates HMAC-SHA256 signature for data
    /// - Parameters:
    ///   - data: The data to sign
    ///   - key: The signing key
    /// - Returns: 32-byte HMAC signature
    public func generateHMAC(for data: Data, with key: SymmetricKey) -> Data {
        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(hmac)
    }

    /// Verifies HMAC signature
    /// - Parameters:
    ///   - hmac: The HMAC signature to verify
    ///   - data: The data that was signed
    ///   - key: The signing key
    /// - Returns: true if signature is valid, false otherwise
    public func verifyHMAC(_ hmac: Data, for data: Data, with key: SymmetricKey) -> Bool {
        let expectedHMAC = generateHMAC(for: data, with: key)
        return hmac == expectedHMAC
    }

    // MARK: - Errors

    public enum EncryptionError: Error, Equatable {
        case encryptionFailed
        case decryptionFailed
    }
}
