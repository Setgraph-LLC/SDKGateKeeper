import Foundation

public struct GatekeeperConfiguration: Codable {
    public let trafficPercentage: Double?
    public let expirationDays: Int?

    public init(
        trafficPercentage: Double? = nil,
        expirationDays: Int? = nil
    ) {
        if let percentage = trafficPercentage, !(0...100).contains(percentage) {
            print("[SDKGatekeeper] Warning: trafficPercentage should be between 0 and 100, got \(percentage)")
        }
        if let days = expirationDays, days <= 0 {
            print("[SDKGatekeeper] Warning: expirationDays should be positive, got \(days)")
        }
        self.trafficPercentage = trafficPercentage
        self.expirationDays = expirationDays
    }

    public static func percentage(_ percentage: Double) -> GatekeeperConfiguration {
        return GatekeeperConfiguration(trafficPercentage: percentage)
    }

    public static func expiration(days: Int) -> GatekeeperConfiguration {
        return GatekeeperConfiguration(expirationDays: days)
    }
}