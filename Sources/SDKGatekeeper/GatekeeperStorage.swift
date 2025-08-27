import Foundation

final class GatekeeperStorage {
    private let userDefaults: UserDefaults
    private let keyPrefix = "com.sdkgatekeeper"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getOrCreateDeviceId() -> String {
        let key = "\(keyPrefix).deviceId"
        
        if let existingDeviceId = userDefaults.string(forKey: key) {
            return existingDeviceId
        }
        
        let newDeviceId = UUID().uuidString
        userDefaults.set(newDeviceId, forKey: key)
        return newDeviceId
    }
    
    func getFirstSeenDate(deviceId: String) -> Date? {
        let key = "\(keyPrefix).firstSeen.\(deviceId)"
        return userDefaults.object(forKey: key) as? Date
    }
    
    func setFirstSeenDate(deviceId: String, date: Date) {
        let key = "\(keyPrefix).firstSeen.\(deviceId)"
        userDefaults.set(date, forKey: key)
    }
    
    func isDeviceInPercentage(deviceId: String, sdkName: String, percentage: Double) -> Bool? {
        let key = "\(keyPrefix).percentage.\(sdkName).\(deviceId)"
        
        // Check if we've already determined this user's status
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.bool(forKey: key)
        }
        
        // First time checking - determine and persist
        let isIncluded = determinePercentageInclusion(percentage: percentage)
        userDefaults.set(isIncluded, forKey: key)
        return isIncluded
    }
    
    private func determinePercentageInclusion(percentage: Double) -> Bool {
        // Random assignment on first check
        let randomValue = Double.random(in: 0..<100)
        return randomValue < percentage
    }
    
    func resetDevice(deviceId: String) {
        let firstSeenKey = "\(keyPrefix).firstSeen.\(deviceId)"
        userDefaults.removeObject(forKey: firstSeenKey)
        
        // Also clear percentage assignments
        let dict = userDefaults.dictionaryRepresentation()
        let percentagePrefix = "\(keyPrefix).percentage."
        for key in dict.keys where key.contains(percentagePrefix) && key.contains(deviceId) {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }
}