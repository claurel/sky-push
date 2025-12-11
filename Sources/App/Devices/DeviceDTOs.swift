import Vapor

/// Incoming JSON for /devices/register
struct RegisterDeviceRequest: Content {
    let deviceToken: String
    let notificationTypes: [String]     // e.g. ["featureArticles"]
    let timezoneOffset: Int             // minutes from GMT, e.g. -480
    let tier: FeatureTier               // 0=basic, 2=plus, 3=pro
}

/// Outgoing JSON after registering/updating a device
struct RegisterDeviceResponse: Content {
    let id: UUID
    let deviceToken: String
    let notificationTypes: [String]
    let timezoneOffset: Int
    let tier: FeatureTier
    let createdAt: Date?
    let updatedAt: Date?
}

