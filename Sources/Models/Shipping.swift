import Foundation

public struct Shipping: Codable {
    public let method: String?
    public let address: Address?
    public let contact: Contact?
    
    public init (method: String? = nil, address: Address? = nil, contact: Contact?) {
        self.method = method
        self.address = address
        self.contact = contact
    }
}
