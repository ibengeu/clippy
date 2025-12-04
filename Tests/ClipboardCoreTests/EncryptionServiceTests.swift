import XCTest
import CryptoKit
@testable import ClipboardCore

final class EncryptionServiceTests: XCTestCase {

    var service: EncryptionService!

    override func setUp() {
        super.setUp()
        service = EncryptionService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Encryption/Decryption Tests

    func testEncryptDecryptData() throws {
        // Given: Encryption service with a key
        let key = service.generateKey()
        let plaintext = "Sensitive clipboard data".data(using: .utf8)!

        // When: Encrypt then decrypt
        let encrypted = try service.encrypt(plaintext, with: key)
        let decrypted = try service.decrypt(encrypted, with: key)

        // Then: Should recover original data
        XCTAssertEqual(decrypted, plaintext, "Decrypted data should match original plaintext")
        XCTAssertNotEqual(encrypted, plaintext, "Encrypted data should differ from plaintext")
    }

    func testEncryptionUsesRandomIV() throws {
        // Given: Service with key and plaintext
        let key = service.generateKey()
        let plaintext = "Same data".data(using: .utf8)!

        // When: Encrypt same data twice
        let encrypted1 = try service.encrypt(plaintext, with: key)
        let encrypted2 = try service.encrypt(plaintext, with: key)

        // Then: Should produce different ciphertexts (different IVs/nonces)
        XCTAssertNotEqual(encrypted1, encrypted2, "Each encryption should use a unique IV/nonce")
    }

    func testDecryptionWithWrongKeyFails() throws {
        // Given: Two different keys
        let key1 = service.generateKey()
        let key2 = service.generateKey()
        let plaintext = "Data".data(using: .utf8)!

        // When: Encrypt with key1, decrypt with key2
        let encrypted = try service.encrypt(plaintext, with: key1)

        // Then: Should throw error
        XCTAssertThrowsError(try service.decrypt(encrypted, with: key2)) { error in
            // Verify it's a CryptoKit error (authentication failure)
            XCTAssertTrue(error is CryptoKitError || error is EncryptionService.EncryptionError,
                         "Should throw CryptoKit or EncryptionService error")
        }
    }

    func testKeyGenerationCreatesStrongKeys() throws {
        // When: Generate key
        let key = service.generateKey()

        // Then: Key should be 256 bits (32 bytes)
        let keyData = key.withUnsafeBytes { Data($0) }
        XCTAssertEqual(keyData.count, 32, "Key should be 256 bits (32 bytes)")
    }

    // MARK: - HMAC Tests (for Phase 3, but grouped with EncryptionService)

    func testGenerateHMAC() throws {
        // Given: Service with data and key
        let data = "Test data".data(using: .utf8)!
        let key = service.generateKey()

        // When: Generate HMAC
        let hmac = service.generateHMAC(for: data, with: key)

        // Then: Should produce 32-byte signature (SHA256)
        XCTAssertEqual(hmac.count, 32, "HMAC-SHA256 should be 32 bytes")
    }

    func testVerifyValidHMAC() throws {
        // Given: Service with data, key, and valid HMAC
        let data = "Test data".data(using: .utf8)!
        let key = service.generateKey()
        let hmac = service.generateHMAC(for: data, with: key)

        // When/Then: Should verify successfully
        XCTAssertTrue(service.verifyHMAC(hmac, for: data, with: key),
                     "Valid HMAC should verify successfully")
    }

    func testDetectTamperedData() throws {
        // Given: Original data with HMAC, but tampered data
        let originalData = "Original".data(using: .utf8)!
        let tamperedData = "Tampered".data(using: .utf8)!
        let key = service.generateKey()
        let hmac = service.generateHMAC(for: originalData, with: key)

        // When/Then: Should fail verification
        XCTAssertFalse(service.verifyHMAC(hmac, for: tamperedData, with: key),
                      "HMAC should not verify for tampered data")
    }

    // MARK: - Edge Cases

    func testEncryptEmptyData() throws {
        // Given: Empty data
        let key = service.generateKey()
        let emptyData = Data()

        // When: Encrypt and decrypt
        let encrypted = try service.encrypt(emptyData, with: key)
        let decrypted = try service.decrypt(encrypted, with: key)

        // Then: Should handle empty data correctly
        XCTAssertEqual(decrypted, emptyData)
    }

    func testEncryptLargeData() throws {
        // Given: Large data (1MB)
        let key = service.generateKey()
        let largeData = Data(repeating: 0xAB, count: 1_000_000)

        // When: Encrypt and decrypt
        let encrypted = try service.encrypt(largeData, with: key)
        let decrypted = try service.decrypt(encrypted, with: key)

        // Then: Should handle large data correctly
        XCTAssertEqual(decrypted, largeData)
        XCTAssertEqual(decrypted.count, 1_000_000)
    }
}
