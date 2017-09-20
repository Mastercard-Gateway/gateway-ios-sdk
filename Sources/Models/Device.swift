import Foundation

public struct Device: Codable {
    public let browser: String?
    public let fingerprint: String?
    public let hostname: String?
    public let ipAddress: String?
    public let mobilePhoneModel: String?
    
    public init(browser: String? = nil, fingerprint: String? = nil, hostname: String? = nil, ipAddress: String? = nil, mobilePhoneModel: String? = nil) {
        self.browser = browser
        self.fingerprint = fingerprint
        self.hostname = hostname
        self.ipAddress = ipAddress
        self.mobilePhoneModel = mobilePhoneModel
    }
}
