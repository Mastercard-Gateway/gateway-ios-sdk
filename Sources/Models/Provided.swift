import Foundation

public struct Provided: Codable {
    public let card: Card?
    
    public init(card: card? = nil) {
        self.card = card
    }
}
