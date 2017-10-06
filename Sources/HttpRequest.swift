import Foundation

/// A generic HTTP recest that could be easily transformed into a url request
public struct HTTPRequest {
    public enum Method: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
        case head = "HEAD"
        case trace = "TRACE"
    }
    
    public let path: String
    public let method: Method
    public let payload: Data?
    public let contentType: String
    public let headers: [String: String]
    
    public init(path: String = "", method: Method = .get, payload: Data? = nil, contentType: String = "", headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.payload = payload
        self.contentType = contentType
        self.headers = headers
    }
}
