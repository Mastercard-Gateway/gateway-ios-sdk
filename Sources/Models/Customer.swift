import Foundation

public struct Customer: Codable {
    public let email: String?
    public let firstName: String?
    public let lastName: String?
    public let mobilePhone: String?
    public let phone: String?
    
    public init(email: String? = nil, firstName: String? = nil, lastName: String? = nil, mobilePhone: String? = nil, phone: String? = nil) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.mobilePhone = mobilePhone
        self.phone = phone
    }
}
