import Foundation

public struct Billing: Codable {
    public let address: Address?
    
    public init(address: Address? = nil) {
        self.address = address
    }
}
