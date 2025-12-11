import Vapor

public func routes(_ app: Application) throws {
    app.get("health") { req -> [String: String] in
        ["status": "ok"]
    }

    app.get { req -> String in
        "SkyGuidePush backend is running"
    }
    
    let deviceController = DeviceController()
    app.post("devices", "register", use: deviceController.register)
    app.get("devices", "summary", use: deviceController.summary)
}
