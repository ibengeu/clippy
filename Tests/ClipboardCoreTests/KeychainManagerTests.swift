import XCTest
@testable import ClipboardCore

final class KeychainManagerTests: XCTestCase {

    var keychain: KeychainManager!
    let testIdentifier = "test-key-\(UUID().uuidString)"

    override func setUp() {
        super.setUp()
        keychain = KeychainManager()
    }

    override func tearDown() {
        // Clean up any test keys
        try? keychain.deleteKey(identifier: testIdentifier)
        keychain = nil
        super.tearDown()
    }

    // MARK: - Store and Retrieve Tests

    func testStoreAndRetrieveKey() throws {
        // Given: A test key
        let key = Data(repeating: 0xAB, count: 32)

        // When: Store key
        try keychain.storeKey(key, identifier: testIdentifier)

        // Then: Should retrieve same key
        let retrieved = try keychain.retrieveKey(identifier: testIdentifier)
        XCTAssertEqual(retrieved, key, "Retrieved key should match stored key")
        XCTAssertEqual(retrieved.count, 32, "Key should be 32 bytes")
    }

    func testDeleteKey() throws {
        // Given: Stored key
        let key = Data(repeating: 0xCD, count: 32)
        try keychain.storeKey(key, identifier: testIdentifier)

        // When: Delete key
        try keychain.deleteKey(identifier: testIdentifier)

        // Then: Should not be retrievable
        XCTAssertThrowsError(try keychain.retrieveKey(identifier: testIdentifier)) { error in
            guard let keychainError = error as? KeychainManager.KeychainError else {
                XCTFail("Should throw KeychainError")
                return
            }
            // Verify it's a retrieve failure
            if case .retrieveFailed = keychainError {
                // Expected error
            } else {
                XCTFail("Should be a retrieveFailed error")
            }
        }
    }

    func testRetrieveNonExistentKeyFails() {
        // Given: Non-existent identifier
        let nonExistentID = "non-existent-\(UUID().uuidString)"

        // When/Then: Should throw error
        XCTAssertThrowsError(try keychain.retrieveKey(identifier: nonExistentID)) { error in
            guard let keychainError = error as? KeychainManager.KeychainError else {
                XCTFail("Should throw KeychainError")
                return
            }
            // Verify it's a retrieve failure
            if case .retrieveFailed = keychainError {
                // Expected error
            } else {
                XCTFail("Should be a retrieveFailed error")
            }
        }
    }

    // MARK: - Update Tests

    func testUpdateExistingKey() throws {
        // Given: Stored key
        let originalKey = Data(repeating: 0x11, count: 32)
        try keychain.storeKey(originalKey, identifier: testIdentifier)

        // When: Store new key with same identifier
        let newKey = Data(repeating: 0x22, count: 32)
        try keychain.storeKey(newKey, identifier: testIdentifier)

        // Then: Should retrieve new key
        let retrieved = try keychain.retrieveKey(identifier: testIdentifier)
        XCTAssertEqual(retrieved, newKey, "Should retrieve updated key")
        XCTAssertNotEqual(retrieved, originalKey, "Should not retrieve original key")
    }

    // MARK: - Multiple Keys Tests

    func testStoreMultipleKeys() throws {
        // Given: Multiple test identifiers
        let id1 = "test-key-1-\(UUID().uuidString)"
        let id2 = "test-key-2-\(UUID().uuidString)"
        defer {
            try? keychain.deleteKey(identifier: id1)
            try? keychain.deleteKey(identifier: id2)
        }

        let key1 = Data(repeating: 0xAA, count: 32)
        let key2 = Data(repeating: 0xBB, count: 32)

        // When: Store multiple keys
        try keychain.storeKey(key1, identifier: id1)
        try keychain.storeKey(key2, identifier: id2)

        // Then: Should retrieve correct keys
        let retrieved1 = try keychain.retrieveKey(identifier: id1)
        let retrieved2 = try keychain.retrieveKey(identifier: id2)

        XCTAssertEqual(retrieved1, key1)
        XCTAssertEqual(retrieved2, key2)
        XCTAssertNotEqual(retrieved1, retrieved2)
    }
}
