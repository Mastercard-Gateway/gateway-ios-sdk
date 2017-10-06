import Foundation

public struct SourceOfFunds: Codable {
    public let provided: Provided?
    
    public init(provided: Provided? = nil) {
        self.provided = provided
    }
}
