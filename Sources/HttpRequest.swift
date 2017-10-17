/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
