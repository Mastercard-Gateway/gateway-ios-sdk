import Foundation

public struct Card: Codable {
    public let nameOnCard: String?
    public let number: String?
    public let securityCode: String?
    public let expiry: Expiry?
    
    public init(nameOnCard: String? = nil, number: String? = nil, securityCode: String? = nil, expiry: Expiry? = nil) {
        self.nameOnCard = nameOnCard
        self.number = number
        self.securityCode = securityCode
        self.expiry = expiry
    }
}
