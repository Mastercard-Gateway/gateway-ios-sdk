import Foundation

public struct Session: Codable {
    public let version: String?
    
    public init(version: String? = nil) {
        self.version = version
    }
}
