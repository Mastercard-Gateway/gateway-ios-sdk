import Foundation

public struct Expiry: Codable {
    public let month: String?
    public let year: String?
    
    public init(month: String? = nil, year: String? = nil) {
        self.month = month
        self.year = year
    }
}
