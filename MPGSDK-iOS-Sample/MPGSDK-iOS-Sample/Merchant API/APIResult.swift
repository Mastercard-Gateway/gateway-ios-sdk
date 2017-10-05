import Foundation

enum APIResult: String, Codable {
    case success = "SUCCESS"
    case pending = "PENDING"
    case failure = "FAILURE"
    case unknown = "UNKNOWN"
}
