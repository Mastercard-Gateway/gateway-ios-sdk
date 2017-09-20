import Foundation

public struct Address: Codable {
    public let city: String?
    public let company: String?
    public let country: String?
    public let posCodeZip: String?
    public let stateProvince: String?
    public let street: String?
    public let street2: String?
    
    public init(city: String? = nil, company: String? = nil, country: String? = nil, posCodeZip: String? = nil, stateProvince: String? = nil, street: String? = nil, street2: String? = nil) {
        self.city = city
        self.company = company
        self.country = country
        self.posCodeZip = posCodeZip
        self.stateProvince = stateProvince
        self.street = street
        self.street2 = street2
    }
}
