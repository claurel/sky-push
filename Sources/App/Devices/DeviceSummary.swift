import Vapor

struct DeviceSummary: Content {
    let total: Int
    /// tier rawValue → count
    let byTier: [Int: Int]
    /// number of devices with any notifications enabled
    let withNotifications: Int
}
