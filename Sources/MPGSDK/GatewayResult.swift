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

/// The result of an gateway api request
///
/// - success:
/// - error:
public enum GatewayResult<T> {
    case success(T)
    case error(Error)
    
    public init(_ result: T) {
        self = .success(result)
    }
    
    public init(_ result: Error) {
        self = .error(result)
    }
}
