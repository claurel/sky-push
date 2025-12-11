import Fluent

struct CreateDevice: Migration {
    func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.schema(Device.schema)
            .id()
            .field(.deviceToken, .string, .required)
            .field(.notificationMask, .int, .required)
            .field(.timezoneOffset, .int, .required)
            .field(.tier, .int, .required)
            .field(.createdAt, .datetime)
            .field(.updatedAt, .datetime)
            .unique(on: .deviceToken)
            .create()
    }

    func revert(on db: Database) -> EventLoopFuture<Void> {
        db.schema(Device.schema).delete()
    }
}
