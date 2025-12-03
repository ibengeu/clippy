import Foundation

class PermissionCache {
    static let shared = PermissionCache()

    private let permissionKey = "com.clipboard.accessibility.permission.requested"
    private let userDefaults = UserDefaults.standard

    func wasPermissionRequested() -> Bool {
        return userDefaults.bool(forKey: permissionKey)
    }

    func markPermissionRequested() {
        userDefaults.set(true, forKey: permissionKey)
    }

    func resetPermissionCache() {
        userDefaults.removeObject(forKey: permissionKey)
    }
}
