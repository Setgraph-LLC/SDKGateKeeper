# SDKGatekeeper

A Swift package for intelligent SDK traffic management to help iOS developers stay within pricing limits.

## Features

- **Traffic Percentage Limiting**: Route only a percentage of devices to expensive SDKs
- **Device Expiration**: Automatically expire devices after N days (perfect for monthly tracked user limits)
- **Persistent Bucketing**: Devices always get the same experience (stored in UserDefaults)
- **Persistent Configuration**: Configurations are automatically saved and restored across app launches
- **Multiple SDK Support**: Configure different rules for each SDK

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SDKGatekeeper.git", from: "1.0.0")
]
```

## Usage

### Basic Setup

```swift
import SDKGatekeeper

let gatekeeper = SDKGatekeeper.shared

// Analytics SDK - Expire devices after 30 days to stay under monthly limits
let analyticsConfig = GatekeeperConfiguration.expiration(days: 30)
gatekeeper.configure(for: "AnalyticsSDK", configuration: analyticsConfig)

if gatekeeper.shouldAllowTraffic(for: "AnalyticsSDK") {
    // Actually track with your analytics SDK
    // YourAnalyticsSDK.track("event_name")
}

// Monetization SDK - Only show to 20% of devices
let monetizationConfig = GatekeeperConfiguration.percentage(20.0)
gatekeeper.configure(for: "MonetizationSDK", configuration: monetizationConfig)

if gatekeeper.shouldAllowTraffic(for: "MonetizationSDK") {
    // Actually trigger your monetization flow
    // YourMonetizationSDK.showPaywall()
}
```

### Advanced Configuration

```swift
let gatekeeper = SDKGatekeeper.shared

// Configure primary analytics with 30-day expiration
let primaryConfig = GatekeeperConfiguration(expirationDays: 30)
gatekeeper.configure(for: "PrimaryAnalytics", configuration: primaryConfig)

// Configure paywall provider with 20% traffic
let paywallConfig = GatekeeperConfiguration(trafficPercentage: 20.0)
gatekeeper.configure(for: "PaywallProvider", configuration: paywallConfig)

// Combine both strategies
let secondaryConfig = GatekeeperConfiguration(
    trafficPercentage: 50.0,
    expirationDays: 60
)
gatekeeper.configure(for: "SecondaryAnalytics", configuration: secondaryConfig)
```

## How It Works

### Traffic Percentage
- First check randomly assigns device to percentage group
- Assignment is persisted in UserDefaults
- Device always gets the same result on future checks
- No flipping between included/excluded

### Device Expiration
- Tracks first seen date for each device
- Automatically expires devices after configured days
- Perfect for Monthly Tracked Users (MTU) limits
- Focus analytics on new users who need optimization most

### Storage
- Uses UserDefaults for persistence
- Minimal overhead
- Automatically generates device ID (UUID) on first use
- Device ID persists across app launches
- Configurations are automatically persisted and restored

## Use Cases

1. **Monthly User Limits**: Set expiration to focus on new users within monthly quotas
2. **Traffic Sampling**: Test expensive features on subset of users
3. **A/B Testing**: Control feature rollout percentages
4. **Cost Management**: Reduce SDK costs by intelligent sampling

## Real-World Integration

### Initialize Before SDK Creation

```swift
let gatekeeper = SDKGatekeeper.shared

// Configure once on first launch - automatically persisted for future launches
let analyticsConfig = GatekeeperConfiguration.expiration(days: 30)
gatekeeper.configure(for: "Analytics", configuration: analyticsConfig)

// Check before SDK initialization
if gatekeeper.shouldAllowTraffic(for: "Analytics") {
    let analytics = YourAnalyticsSDK(apiKey: "YOUR_KEY")
}

// Access device ID if needed
let deviceId = gatekeeper.getDeviceId()
```

### Wrapper Pattern

```swift
class AnalyticsWrapper {
    private var sdk: YourAnalyticsSDK?
    
    init() {
        // Configure gatekeeper
        let config = GatekeeperConfiguration.expiration(days: 30)
        SDKGatekeeper.shared.configure(for: "Analytics", configuration: config)
        
        // Only initialize if eligible
        if SDKGatekeeper.shared.shouldAllowTraffic(for: "Analytics") {
            sdk = YourAnalyticsSDK(apiKey: "YOUR_KEY")
        }
    }
    
    func track(event: String) {
        sdk?.track(event) // No-op if device is filtered
    }
}
```

## Contributing

Pull requests are welcome! Please feel free to submit a PR.

## License

MIT