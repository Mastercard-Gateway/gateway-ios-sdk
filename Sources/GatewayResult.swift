import Foundation

public enum GatewayResult<T> {
    case success(T)
    case error(Error)
}
