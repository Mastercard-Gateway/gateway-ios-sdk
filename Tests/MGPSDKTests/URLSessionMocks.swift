import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
    public var resumeWasCalled = false
    
    public override init() {
        
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
