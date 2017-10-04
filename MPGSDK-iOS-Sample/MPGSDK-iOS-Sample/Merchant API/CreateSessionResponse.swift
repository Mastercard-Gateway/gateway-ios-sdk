import Foundation

enum UpdateStatus: String, Codable {
    case noUpdate = "NO_UPDATE"
    case failure = "FAILURE"
    case success = "SUCCESS"
}

struct Session: Codable {
    let id: String
    let updateStatus: UpdateStatus
    let version: String
}

struct CreateSessionResponse: Codable {
    let merchant: String
    let result: APIResult
    let session: Session
}
