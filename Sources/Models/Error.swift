import Foundation

public struct GatewayResponseError: Codable {
    public enum Cause: String, Codable {
        case requestRejected = "REQUEST_REJECTED"
        case invalidRequest = "INVALID_REQUEST"
        case serverFailed = "SERVER_FAILED"
        case serverBusy = "SERVER_BUSY"
    }
    
    public enum ValidationType: String, Codable {
        case invalid = "INVALID"
        case missing = "MISSING"
        case unsupported = "UNSUPPORTED"
    }
    
    public let cause: Cause?
    public let explination: String?
    public let field: String?
    public let supportCode: String?
    public let validationType: ValidationType?
    
    public let init(cause: Cause? = nil, explination: String? = nil, field: String? = nil, supportCode: String? = nil, validationType: ValidationType? = nil) {
        self.cause = cause
        self.explination = explination
        self.field = field
        self.supportCode = supportCode
        self.validationType = validationType
    }
}
