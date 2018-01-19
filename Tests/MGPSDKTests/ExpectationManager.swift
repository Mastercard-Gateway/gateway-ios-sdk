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
import XCTest

public struct Expectation<Param, Return> {
    public typealias Matcher = (Param) -> Bool
    public typealias Action = (Param) throws -> Return
    public typealias VoidAction = (() -> Return)
    
    let matcher: Matcher
    let action: Action
    
    public init(matches: @escaping Matcher, action: @escaping Action) {
        self.matcher = matches
        self.action = action
    }
    
    public init(_ action: @escaping Action) {
        self.init(matches: { _ in return true }, action: action)
    }
    
    public func matches(_ param: Param) -> Bool {
        return matcher(param)
    }
    
    public func fulfill(_ param: Param) throws -> Return {
        return try action(param)
    }
}

extension Expectation where Param == Void {
    public init(action: @escaping VoidAction) {
        self.init { (_) -> Return in
            return action()
        }
    }
    
    public init(returns: Return) {
        self.init(matches: { _ in return true }, action: { _ in return returns})
    }
    
    public init(throws error: Swift.Error) {
        self.init(matches: { _ in return true }, action: { _ in throw error})
    }
}

extension Expectation where Param : Equatable {
    public init(parameter: Param, action: @escaping Action) {
        self.init(matches: { $0 == parameter }, action: action)
    }
    
    public init(_ p: Param, returns: Return) {
        self.init(matches: { $0 == p }, action: { _ in return returns})
    }
    
    public init(_ p: Param, throws error: Swift.Error) {
        self.init(matches: { $0 == p }, action: { _ in throw error})
    }
}

public class ExpectationManager {
    enum Error: Swift.Error {
        case unexpected(Any)
    }
    
    var expectations: [Any] = []
    var enforceOrder: Bool = false
    
    public func fulfill<Param, Return>(_ value: Param) throws -> Return {
        if enforceOrder {
            if let expectation = expectations.first as? Expectation<Param, Return>, expectation.matches(value) {
                // remove the expectation from the list
                expectations.removeFirst()
                return try expectation.fulfill(value)
            }
        } else {
            for (index, expectation) in expectations.enumerated() {
                if let expectation = expectation as? Expectation<Param, Return>, expectation.matches(value) {
                    // remove the expectation from the list
                    expectations.remove(at: index)
                    return try expectation.fulfill(value)
                }
            }
        }
        
        throw Error.unexpected(value)
    }
    
    public func expect<Param, Return>(_ expectation: Expectation<Param, Return>) {
        self.expectations.append(expectation)
    }
    
    public func validate() {
        XCTFail("Not all expectations met")
    }
}

extension ExpectationManager{
    public func expect<Param, Returns>(_ p: Param, return r: Returns) where Param : Equatable {
        self.expect(Expectation(p, returns: r))
    }
    
    public func expect<Param>(_ p: Param, throws error: Swift.Error) where Param : Equatable {
        self.expect(Expectation<Param, Void>(p, throws: error))
    }
}

