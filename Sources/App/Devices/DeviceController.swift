import Vapor
import Fluent

struct DeviceController {

    /// POST /devices/register
    ///
    /// Upserts a device by deviceToken:
    /// - If device exists: updates notification types, timezone offset, service level.
    /// - If not: creates a new device record.
    func register(_ req: Request) async throws -> RegisterDeviceResponse {
        let payload = try req.content.decode(RegisterDeviceRequest.self)

        // Basic sanity check on timezoneOffset
        // Range of actual time zones is -12:00 to +14:00, but we'll allow slack
        // to accommodate future additions.
        guard (-24 * 60)...(24 * 60) ~= payload.timezoneOffset else {
            throw Abort(.badRequest, reason: "Invalid timezoneOffset (minutes from GMT): \(payload.timezoneOffset)")
        }

        let notificationOptions = try NotificationTypeOptions.from(names: payload.notificationTypes)

        // Look up existing device by token
        let existing = try await Device.query(on: req.db)
            .filter(\.$deviceToken == payload.deviceToken)
            .first()

        let device: Device

        if let existing = existing {
            // Update in-place
            existing.notificationTypes = notificationOptions
            existing.timezoneOffset = payload.timezoneOffset
            existing.tier = payload.tier
            device = existing
        } else {
            // Create new
            device = Device(
                deviceToken: payload.deviceToken,
                notificationTypes: notificationOptions,
                timezoneOffset: payload.timezoneOffset,
                tier: payload.tier
            )
        }

        try await device.save(on: req.db)

        guard let id = device.id else {
            throw Abort(.internalServerError, reason: "Failed to obtain device ID after save.")
        }

        return RegisterDeviceResponse(
            id: id,
            deviceToken: device.deviceToken,
            notificationTypes: device.notificationTypes.names,
            timezoneOffset: device.timezoneOffset,
            tier: device.tier,
            createdAt: device.createdAt,
            updatedAt: device.updatedAt
        )
    }
    
    // MARK: - Summary

    /// GET /devices/summary
    ///
    /// Returns:
    /// - total device count
    /// - counts by Tier
    /// - count of devices with any notifications enabled
    func summary(_ req: Request) async throws -> DeviceSummary {
        // Total devices
        let total = try await Device.query(on: req.db).count()

        // Count by tier
        var byTier: [Int: Int] = [:]
        for tier in FeatureTier.allCases {
            let count = try await Device.query(on: req.db)
                .filter(\.$tier == tier)
                .count()
            byTier[tier.rawValue] = count
        }

        // Devices with any notifications enabled
        let withNotifications = try await Device.query(on: req.db)
            .filter(\.$notificationMask != 0)
            .count()

        return DeviceSummary(
            total: total,
            byTier: byTier,
            withNotifications: withNotifications
        )
    }

}
