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
    
    /// Subscripting support for getting and setting values nested under several layers of GatewayMaps and/or arrays using a dot seperated path string
    /// If you map contains a value at key "key1" which is itself a map containing a value at key "key2", the value is accessed using a path of "key1.key2"
    /// When getting a value, if any of the keys in the path do not exist, the returned value will be nil.
    /// When setting a value, if any of the keys in the path do not exist, GatewayMaps will be created and inserted automatically.  If a non-map value exists in the middle of the path, that value will be overridden with a map.
    ///
    /// Values inside an array can be accessed using subscripting within the path.  For instance, "people[3].firstName" would access the element at index 3 of the 'people' array and then get the 'firstName' value from that object.  When setting values on an array, empty brackets '[]' may be used to append an object to the array.
    ///
    /// - Parameter path: A dot seperated string of keys describing the path to a value in the map.
    public subscript(at path: String) -> Any? {
        get {
            return get(at: path)
        }
        set(newValue) {
            set(newValue, at: path)
        }
    }
    
    /// Subscripting support for getting and setting values nested under several layers of GatewayMaps using a dot seperated key such as "sourceOfFunds.provided.card.number"
    ///
    /// - Parameter path: A dot seperated string of keys describing the path to a value in the map.
    subscript(path: [String]) -> Any? {
        get {
            return get(at: path)
        }
        set(newValue) {
            set(newValue, at: path)
        }
    }
    
    func get(at path: String) -> Any? {
        let components = path.components(separatedBy: ".")
        return get(at: components)
    }
    
    mutating func set(_ value: Any?, at path: String) {
        let components = path.components(separatedBy: ".")
        set(value, at: components)
    }
    
    func get(at path: [String]) -> Any? {
        guard !path.isEmpty else { return nil }
        var remainingPath = path
        
        var key = remainingPath.removeFirst()
        var index: Int? = nil
        let isIndexPath = keyIsIndexPath(key)
        
        if isIndexPath {
            (key, index) = splitIndexPath(key)
        }
        
        guard let current = storage[key] else { return nil }
        
        switch (remainingPath.isEmpty, current, isIndexPath, index) {
        case (_, let element, false, _):
            return element.get(at: remainingPath)
        case (true, .array(let array), true, .some(let index)):
            return array[if: index]?.value
        case (true, .array(let array), true, .none):
            return array.last?.value
        case (false, .array(let array), true, .some(let index)):
            return array[if: index]?.get(at: remainingPath)
        case (false, .array(let array), true, .none):
            return array.last?.get(at: remainingPath)
        default:
            return nil
        }
    }
    
    @discardableResult mutating func set(_ newValue: Any?, at path: [String]) -> GatewayMap? {
        
        guard !path.isEmpty else { return nil }
        var remainingPath = path
        
        var key = remainingPath.removeFirst()
        var index: Int? = nil
        let isIndexPath = keyIsIndexPath(key)
        
        if isIndexPath {
            (key, index) = splitIndexPath(key)
        }
        
        let current = storage[key]
        
        switch (remainingPath.isEmpty, current, isIndexPath, index) {
        case (true , .none, false, _):
            // this is the last path element, set the boxed value
            storage[key] = GatewayValue(newValue)
        case (_, .some(let leaf), false, _):
            storage[key] = leaf.set(newValue, at: remainingPath)
        case (false, _, false, _):
            storage[key] = GatewayValue(GatewayMap())
            set(newValue, at: path)
        case (let end, let element, true, let index):
            var array: [GatewayValue] = []
            // if the element is already an array, use that array
            if case .some(.array(let existing)) = element {
                array = existing
            }
            
            // if this is the end of the path, create the value if not create a map
            var value: GatewayValue? = end ? GatewayValue(newValue) : GatewayValue.map([:])
            
            // if this is not the end of the path, and an index was provided, look for a value at that index on which we can append
            if !end, let index = index {
                // look for a value at that index
                value = array[if: index] ?? value
            }
            
            if !end {
                value = value?.set(newValue, at: remainingPath)
            }
            
            var newArray = array
            
            switch (value, index) {
            case(let value, .some(let index)):
                newArray[if: index] = value
            case (.some(let value), .none):
                newArray.append(value)
            case (.none, .none):
                if !newArray.isEmpty { newArray.removeLast() }
            }
            
            storage[key] = GatewayValue(newArray)
        }
        return self
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
            let boxes = array.compactMap{ GatewayValue($0) }
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

protocol PathGettable {
    func get(at path: [String]) -> Any?
}

protocol PathSettable {
    @discardableResult mutating func set(_ newValue: Any?, at path: [String]) -> Self?
}

extension GatewayValue {
    @discardableResult func set(_ newValue: Any?, at path: [String]) -> GatewayValue? {
        switch (path.isEmpty, self) {
        case (true, _):
            return GatewayValue(newValue)
        case (false, .map(let map)):
            var newMap = map
            newMap.set(newValue, at: path)
            return .map(newMap)
        case (false, _):
            var newMap = GatewayMap()
            newMap.set(newValue, at: path)
            return .map(newMap)
        }
    }
}

extension GatewayValue {
    func get(at path: [String]) -> Any? {
        switch (path.isEmpty, self) {
        case (true, _):
            return value
        case (false, .map(let map)):
            return map.get(at: path)
        default:
            return nil
        }
    }
}

extension GatewayMap: CustomDebugStringConvertible {
    public var debugDescription: String {
        return value.debugDescription
    }
}

fileprivate let regex = try! NSRegularExpression(pattern: "^(.+)\\[(.*)\\]$")

fileprivate func keyIsIndexPath(_ key: String) -> Bool {
    guard key.contains("["), key.contains("]") else { return false }
    return regex.numberOfMatches(in: key, range: NSRange(key.startIndex..., in: key)) > 0
}

fileprivate func splitIndexPath(_ keyIndexPath: String) -> (String, Int?) {
    guard let ranges = regex.matches(in: keyIndexPath, range: NSRange(keyIndexPath.startIndex..., in: keyIndexPath)).first else { return (keyIndexPath, nil) }
    
    let keyRange = Range(ranges.range(at: 1), in: keyIndexPath)!
    let key = String(keyIndexPath[keyRange])
    
    let indexRange = Range(ranges.range(at: 2), in: keyIndexPath)!
    let index = Int(keyIndexPath[indexRange])
    
    return (key, index)
}

fileprivate extension Array {
    /// extension to subscripting for arrays that allows the return of nil if the index is invalid, appending if the index is beyond the existing array or removing at an index if you set nil
    subscript (if index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            if indices.contains(index) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    self.remove(at: index)
                }
            } else if let newValue = newValue {
                self.append(newValue)
            }
        }
    }
}
