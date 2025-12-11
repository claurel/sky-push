import Vapor
import Fluent

/// Represents one installation of the app that can receive push notifications.
final class Device: Model, Content {
    static let schema = "devices"

    @ID(key: .id)
    var id: UUID?

    /// APNs device token (hex string). Unique per device installation.
    @Field(key: .deviceToken)
    var deviceToken: String

    /// Bitmask backing store for notification types.
    @Field(key: .notificationMask)
    var notificationMask: Int

    /// Timezone - offset miniutes offset from GMT
    @Field(key: .timezoneOffset)
    var timezoneOffset: Int

    /// Level of service (free / paid tiers).
    @Field(key: .tier)
    var tier: FeatureTier

    /// Audit fields.
    @Timestamp(key: .createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: .updatedAt, on: .update)
    var updatedAt: Date?

    // MARK: - Convenience API

    /// High-level view of notification subscriptions.
    var notificationTypes: NotificationTypeOptions {
        get { NotificationTypeOptions(rawValue: notificationMask) }
        set { notificationMask = newValue.rawValue }
    }

    init() {}

    init(
        id: UUID? = nil,
        deviceToken: String,
        notificationTypes: NotificationTypeOptions,
        timezoneOffset: Int,
        tier: FeatureTier
    ) {
        self.id = id
        self.deviceToken = deviceToken
        self.notificationMask = notificationTypes.rawValue
        self.timezoneOffset = timezoneOffset
        self.tier = tier
    }
}

// MARK: - Notification types as bitmask

/// Extend / rename cases to match your actual categories.
struct NotificationTypeOptions: OptionSet, Codable {
    let rawValue: Int

    // Example categories — adjust as you define your UX:
    static let featuredArticles  = NotificationTypeOptions(rawValue: 1 << 0)

    // Helper to subscribe to “everything”
    static let all: NotificationTypeOptions = [
        .featuredArticles,
    ]
}

// MARK: - Service level

enum FeatureTier: Int, Codable, CaseIterable {
    case basic = 0     // no subscription
    case legacy = 1    // users who bought Sky Guide before it went free-with-subscription
    case plus = 2      // higher tier
    case pro = 3       // highest tier
}

// MARK: - Field keys

extension FieldKey {
    static let deviceToken       = Self("device_token")
    static let notificationMask  = Self("notification_mask")
    static let timezoneOffset    = Self("timezone_offset")
    static let tier              = Self("tier")
    static let createdAt         = Self("created_at")
    static let updatedAt         = Self("updated_at")
}

extension NotificationTypeOptions {
    /// Map incoming string names to options.
    static func from(names: [String]) throws -> NotificationTypeOptions {
        var options: NotificationTypeOptions = []

        for name in names {
            switch name {
            case "featuredArticles":
                options.insert(.featuredArticles)
            default:
                throw Abort(.badRequest, reason: "Unknown notification type: \(name)")
            }
        }

        return options
    }

    /// Map bitmask back to string names for responses.
    var names: [String] {
        var result: [String] = []
        if contains(.featuredArticles) { result.append("featuredArticles") }
        return result
    }
}
