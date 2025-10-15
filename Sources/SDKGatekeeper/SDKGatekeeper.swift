import Foundation

/// SDKGatekeeper manages traffic control for various SDKs.
/// Configure during app startup before initializing SDKs.
public final class SDKGatekeeper: @unchecked Sendable {
    public static let shared = SDKGatekeeper()
    
    private let storage: GatekeeperStorage
    private var configurations: [String: GatekeeperConfiguration] = [:]
    
    private init() {
        self.storage = GatekeeperStorage()
    }
    
    /// Configure SDK gatekeeper settings. Call this during app startup before SDK initialization.
    public func configure(for sdkName: String, configuration: GatekeeperConfiguration) {
        configurations[sdkName] = configuration
    }
    
    public func shouldAllowTraffic(for sdkName: String) -> Bool {
        guard let config = configurations[sdkName] else { return false }
        
        let deviceId = storage.getOrCreateDeviceId()
        
        if let expirationDays = config.expirationDays {
            if isDeviceExpired(deviceId: deviceId, expirationDays: expirationDays) {
                return false
            }
        }
        
        if let percentage = config.trafficPercentage {
            // This is explicitly persisted - once determined, always the same
            if let isIncluded = storage.isDeviceInPercentage(deviceId: deviceId, sdkName: sdkName, percentage: percentage) {
                return isIncluded
            }
        }
        
        if let customFilter = config.customFilter {
            return customFilter(deviceId)
        }
        
        return true
    }
    
    public func resetDevice() {
        let deviceId = storage.getOrCreateDeviceId()
        storage.resetDevice(deviceId: deviceId)
    }
    
    private func isDeviceExpired(deviceId: String, expirationDays: Int) -> Bool {
        guard let firstSeenDate = storage.getFirstSeenDate(deviceId: deviceId) else {
            storage.setFirstSeenDate(deviceId: deviceId, date: Date())
            return false
        }
        
        let expirationDate = firstSeenDate.addingTimeInterval(TimeInterval(expirationDays * 24 * 60 * 60))
        return Date() > expirationDate
    }
}