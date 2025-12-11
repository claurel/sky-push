// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SkyGuidePushBackend",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Run",
            targets: ["Run"]
        )
    ],
    dependencies: [
        // Vapor 4
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "4.92.0" // or latest 4.x
        ),
        // Fluent ORM core
        .package(
            url: "https://github.com/vapor/fluent.git",
            from: "4.9.0"
        ),
        // SQLite driver (local dev)
        .package(
            url: "https://github.com/vapor/fluent-sqlite-driver.git",
            from: "4.7.0"
        ),
        // Postgres driver (dev/prod)
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            from: "2.8.0"
        ),
        // Async HTTP client (for APNs HTTP/2 calls)
        .package(
            url: "https://github.com/swift-server/async-http-client.git",
            from: "1.21.0"
        ),
        // Vapor’s JWTKit: signing/verifying JWTs, including ES256 for APNs
        .package(
            url: "https://github.com/vapor/jwt-kit.git",
            from: "4.0.0"
        )
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            path: "Sources/App",
            resources: [
                // If you add migrations as JSON/SQL resources later, include them here
                // .process("Resources")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "App")
            ],
            path: "Sources/Run"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor")
            ],
            path: "Tests/AppTests"
        )
    ]
)
