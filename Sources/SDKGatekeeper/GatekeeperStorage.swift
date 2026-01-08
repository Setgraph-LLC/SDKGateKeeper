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
    
    func isDeviceInPercentage(deviceId: String, sdkName: String, percentage: Double) -> Bool {
        let key = "\(keyPrefix).percentage.\(sdkName).\(deviceId)"

        // Return persisted value if exists
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.bool(forKey: key)
        }

        // First time - randomly assign and persist
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

        // Also clear percentage assignments (key format: prefix.percentage.<sdkName>.<deviceId>)
        let dict = userDefaults.dictionaryRepresentation()
        let percentagePrefix = "\(keyPrefix).percentage."
        for key in dict.keys where key.hasPrefix(percentagePrefix) && key.hasSuffix(".\(deviceId)") {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func clearAllData() {
        let dict = userDefaults.dictionaryRepresentation()
        for key in dict.keys where key.hasPrefix(keyPrefix) {
            userDefaults.removeObject(forKey: key)
        }
    }

    // MARK: - Configuration Persistence

    func saveConfiguration(_ config: GatekeeperConfiguration, for sdkName: String) {
        let key = "\(keyPrefix).config.\(sdkName)"
        if let data = try? JSONEncoder().encode(config) {
            userDefaults.set(data, forKey: key)
        }
    }

    func loadConfiguration(for sdkName: String) -> GatekeeperConfiguration? {
        let key = "\(keyPrefix).config.\(sdkName)"
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(GatekeeperConfiguration.self, from: data)
    }

    func loadAllConfigurations() -> [String: GatekeeperConfiguration] {
        var configs: [String: GatekeeperConfiguration] = [:]
        let configPrefix = "\(keyPrefix).config."

        for key in userDefaults.dictionaryRepresentation().keys where key.hasPrefix(configPrefix) {
            let sdkName = String(key.dropFirst(configPrefix.count))
            if let config = loadConfiguration(for: sdkName) {
                configs[sdkName] = config
            }
        }
        return configs
    }

    func removeConfiguration(for sdkName: String) {
        let key = "\(keyPrefix).config.\(sdkName)"
        userDefaults.removeObject(forKey: key)
    }
}