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


/// A Map object representing a JSON payload to be sent to the gateway or received from the gateway
public struct GatewayMap {
    
    /// Errors thrown when decoding
    ///
    /// - invalidData: Indicates that invalid data was encountered at the key path contained in the error
    public enum DecodingError: Error {
        case invalidData([CodingKey])
    }
    
    var storage: [String: GatewayValue] = [:]
    
    fileprivate init(boxed: [String: GatewayValue]) {
        self.storage = boxed
    }
    
    // MARK: - INTERNAL
    
    var value: [String: Any] {
        return storage.mapValues{ $0.value }
    }
    
    // MARK: - PUBLIC
    
    /// Create a new empty GatewayMap
    public init() {
        storage = [:]
    }
    
    
    /// Create a GatewayMap from an existing Dictionary
    ///
    ///
    /// - Parameter dictionary: A dictionary to create the GatewayMap from.  Supported value types include, String, Int, Double, Bool, GatewayMap and arrays of any of those types.  Any un-supported value will simply be dropped from the map.
    public init(_ dictionary: [String: Any]) {
        let boxedOpt = dictionary.mapValues{ GatewayValue($0) }
        let boxed = boxedOpt.filter{ return $1 != nil }.mapValues{ $0! }
        self.init(boxed: boxed)
    }
    
    /// A dictionary representation of the map
    public var dictionary: [String: Any] {
        return value
    }
    
    /// A description of the map's contents
    public var description: String {
        return value.description
    }
    
    
    /// Subscripting support for getting and setting values on the top-level map
    public subscript(key: String) -> Any? {
        get {
            return storage[key]?.value
        }
        set(newValue) {
            storage[key] = GatewayValue(newValue)
        }
    }
    
    /// Subscripting support for getting and setting values nested under several layers of GatewayMaps using an array of keys
    ///
    /// - Parameter path: An array of keys describing the path to a value in the map.
    public subscript(path path: String) -> Any? {
        get {
            let components = path.components(separatedBy: ".")
            return self[components]
        }
        set(newValue) {
            let components = path.components(separatedBy: ".")
            self[components] = newValue
        }
    }
    
    /// Subscripting support for getting and setting values nested under several layers of GatewayMaps using a dot seperated key such as "sourceOfFunds.provided.card.number"
    ///
    /// - Parameter path: A dot seperated string of keys describing the path to a value in the map.
    subscript(path: [String]) -> Any? {
        get {
            guard !path.isEmpty else { return nil }
            var remainingPath = path
            let currentComponent = remainingPath.removeFirst()
            guard let current = storage[currentComponent] else { return nil }
            
            switch (remainingPath.isEmpty, current) {
            case (true, let element):
                // this is the last path element, so return the unboxed value of the current element
                return element.value
            case (false, .map(let map)):
                // there are more path components and element at the current path is a map, continue with the remaining elements
                return map[remainingPath]
            default:
                // there are remaining path components but the current element is not a map, return nil
                return nil
            }
        }
        set(newValue) {
            guard !path.isEmpty else { return }
            var remainingPath = path
            let currentComponent = remainingPath.removeFirst()
            let current = storage[currentComponent]
            
            switch (remainingPath.isEmpty, current) {
            case (true, _):
                // this is the last path element, set the boxed value
                storage[currentComponent] = GatewayValue(newValue)
            case (false, .some(.map(let map))):
                // there are more path components and element at the current path is already a map, continue with the remaining elements
                var newMap = map
                newMap[remainingPath] = newValue
                storage[currentComponent] = GatewayValue(newMap)
            case (false, _):
                // there are more path components and element at the current path is already a map, continue with the remaining elements
                var newMap = GatewayMap()
                newMap[remainingPath] = newValue
                storage[currentComponent] = GatewayValue(newMap)
            }
        }
    }
}

// MARK: Dictionary Litteral Support
extension GatewayMap: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        var dictionary = [String: Any](minimumCapacity: elements.count)
        for (k, v) in elements {
            dictionary[k] = v
        }
        self.init(dictionary)
    }
}

// MARK: Codable
extension GatewayMap: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storage)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        storage = try container.decode([String: GatewayValue].self)
    }
}

// MARK: - PRIVATE

enum GatewayValue {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([GatewayValue])
    case map(GatewayMap)
    
    init?(_ value: Any?) {
        guard let unboxed = value else { return nil }
        switch unboxed {
        case let b as GatewayValue:
            self = b
        case let m as GatewayMap:
            self = .map(m)
        case let d as [String: GatewayValue]:
            self = .map(GatewayMap(boxed: d))
        case let d as [String: Any]:
            self = .map(GatewayMap(d))
        case let boxes as [GatewayValue]:
            self = .array(boxes)
        case let array as [Any]:
            let boxes = array.flatMap{ GatewayValue($0) }
            self = .array(boxes)
        case let b as Bool:
            self = .bool(b)
        case let i as Int:
            self = .int(i)
        case let d as Double:
            self = .double(d)
        case let s as String:
            self = .string(s)
        default:
            return nil
        }
    }
    
    var value: Any {
        switch self {
        case .string(let s):
            return s
        case .int(let i):
            return i
        case .double(let d):
            return d
        case .bool(let b):
            return b
        case .array(let boxes):
            return boxes.map{ $0.value }
        case .map(let m):
            return m.value
        }
    }
}

extension GatewayValue: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .int(let integer):
            try container.encode(integer)
        case .double(let double):
            try container.encode(double)
        case .bool(let boolean):
            try container.encode(boolean)
        case .array(let array):
            try container.encode(array)
        case .map(let map):
            try container.encode(map)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let obj = try? container.decode(GatewayMap.self) {
            self = .map(obj)
        } else if let obj = try? container.decode([GatewayValue].self) {
            self = .array(obj)
        } else if let obj = try? container.decode(Bool.self) {
            self = .bool(obj)
        } else if let obj = try? container.decode(Int.self) {
            self = .int(obj)
        } else if let obj = try? container.decode(Double.self) {
            self = .double(obj)
        } else if let obj = try? container.decode(String.self) {
            self = .string(obj)
        } else {
            throw GatewayMap.DecodingError.invalidData(container.codingPath)
        }
    }
}

extension GatewayValue: Equatable {
    static func ==(lhs: GatewayValue, rhs: GatewayValue) -> Bool {
        switch (lhs, rhs) {
        case (.string(let l), .string(let r)):
            return l == r
        case (.int(let l), .int(let r)):
            return l == r
        case (.double(let l), .double(let r)):
            return l == r
        case (.bool(let l), .bool(let r)):
            return l == r
        case (.array(let l), .array(let r)):
            return l == r
        case (.map(let l), .map(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension GatewayMap: Equatable {
    public static func ==(lhs: GatewayMap, rhs: GatewayMap) -> Bool {
        return lhs.storage == rhs.storage
    }
}

