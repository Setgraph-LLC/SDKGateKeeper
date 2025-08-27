import Foundation

public struct GatekeeperConfiguration {
    public let trafficPercentage: Double?
    public let expirationDays: Int?
    public let customFilter: ((String) -> Bool)?
    
    public init(
        trafficPercentage: Double? = nil,
        expirationDays: Int? = nil,
        customFilter: ((String) -> Bool)? = nil
    ) {
        self.trafficPercentage = trafficPercentage
        self.expirationDays = expirationDays
        self.customFilter = customFilter
    }
    
    public static func percentage(_ percentage: Double) -> GatekeeperConfiguration {
        return GatekeeperConfiguration(trafficPercentage: percentage)
    }
    
    public static func expiration(days: Int) -> GatekeeperConfiguration {
        return GatekeeperConfiguration(expirationDays: days)
    }
}