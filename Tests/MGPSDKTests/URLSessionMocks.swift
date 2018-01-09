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

class MockURLSessionDataTask: URLSessionDataTask {
    var resumeWasCalled = false
    
    override init() {
        
    }
    
    public override func resume() {
        resumeWasCalled = true
    }
}

class MockURLSession: URLSession {
    var nextDataTask = MockURLSessionDataTask()
    var lastRequest: URLRequest?
    var lastCompletion: ((Data?, URLResponse?, Error?) -> Void)?
    
    override init() {
        
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            lastRequest = request
            lastCompletion = completionHandler
            return nextDataTask
    }
}
