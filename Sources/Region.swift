import Foundation

public enum Region: String {
    case test = "test"
    case europe = "eu"
    case northAmerica = "na"
    case asiaPacific = "ap"
}

extension Region {
    var urlPrefix: String {
        return self.rawValue
    }
}
