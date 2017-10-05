import Foundation

public struct Provided: Codable {
    public let card: Card?
    
    public init(card: Card? = nil) {
        self.card = card
    }
}
