import Vapor
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Environment: local | dev | prod
    let appEnv = Environment.get("APP_ENV") ?? "local"

    // Databases
    switch appEnv {
    case "local":
        // SQLite file in working directory
        app.databases.use(.sqlite(.file("apns-backend.sqlite")), as: .sqlite)
    default:
        // Postgres via DATABASE_URL
        guard
            let dbURL = Environment.get("DATABASE_URL"),
            let url = URL(string: dbURL)
        else {
            fatalError("DATABASE_URL not set or invalid for env \(appEnv)")
        }
        app.databases.use(.postgres(
            configuration: .init(url: url)!,
            maxConnectionsPerEventLoop: 10
        ), as: .psql)
    }

    // Migrations will go here later
    // e.g. app.migrations.add(CreateDevice())

    // Run migrations automatically on startup
    try app.autoMigrate().wait()

    // Register routes
    try routes(app)
}
