import Foundation

public struct HTTPRequest {
    public enum Method: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
        case head = "HEAD"
        case trace = "TRACE"
    }
    
    public var path: String
    public var method: Method
    public var payload: Data?
    public var contentType: String
    public var headers: [String: String]
    
    public init(path: String = "", method: Method = .get, payload: Data? = nil, contentType: String = "", headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.payload = payload
        self.contentType = contentType
        self.headers = headers
    }
}
