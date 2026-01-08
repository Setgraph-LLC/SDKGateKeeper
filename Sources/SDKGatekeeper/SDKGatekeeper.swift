import Foundation

/// SDKGatekeeper manages traffic control for various SDKs.
/// Configurations are automatically persisted and restored across app launches.
public final class SDKGatekeeper: @unchecked Sendable {
    public static let shared = SDKGatekeeper()

    private let storage: GatekeeperStorage
    private var configurations: [String: GatekeeperConfiguration] = [:]

    private init() {
        self.storage = GatekeeperStorage()
        self.configurations = storage.loadAllConfigurations()
    }

    /// Configure SDK gatekeeper settings. Configuration is automatically persisted.
    public func configure(for sdkName: String, configuration: GatekeeperConfiguration) {
        configurations[sdkName] = configuration
        storage.saveConfiguration(configuration, for: sdkName)
    }

    /// Remove a persisted configuration for an SDK.
    public func removeConfiguration(for sdkName: String) {
        configurations.removeValue(forKey: sdkName)
        storage.removeConfiguration(for: sdkName)
    }
    
    public func shouldAllowTraffic(for sdkName: String) -> Bool {
        guard let config = configurations[sdkName] else { return false }

        let deviceId = storage.getOrCreateDeviceId()

        if let expirationDays = config.expirationDays {
            if isDeviceExpired(deviceId: deviceId, sdkName: sdkName, expirationDays: expirationDays) {
                return false
            }
        }

        if let percentage = config.trafficPercentage {
            return storage.isDeviceInPercentage(deviceId: deviceId, sdkName: sdkName, percentage: percentage)
        }

        return true
    }

    /// Returns the device's unique identifier used for traffic decisions.
    public func getDeviceId() -> String {
        return storage.getOrCreateDeviceId()
    }
    
    public func resetDevice() {
        let deviceId = storage.getOrCreateDeviceId()
        storage.resetDevice(deviceId: deviceId)
    }
    
    private func isDeviceExpired(deviceId: String, sdkName: String, expirationDays: Int) -> Bool {
        guard let firstSeenDate = storage.getFirstSeenDate(deviceId: deviceId, sdkName: sdkName) else {
            storage.setFirstSeenDate(deviceId: deviceId, sdkName: sdkName, date: Date())
            return false
        }

        let expirationDate = firstSeenDate.addingTimeInterval(TimeInterval(expirationDays * 24 * 60 * 60))
        return Date() > expirationDate
    }
}