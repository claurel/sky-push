import Vapor

public func routes(_ app: Application) throws {
    app.get("health") { req -> [String: String] in
        ["status": "ok"]
    }

    app.get { req -> String in
        "SkyGuidePush backend is running"
    }
}
