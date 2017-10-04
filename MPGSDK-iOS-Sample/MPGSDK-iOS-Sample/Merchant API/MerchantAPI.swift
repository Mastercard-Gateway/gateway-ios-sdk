import Foundation

enum Result<T> {
    case success(T)
    case error(Error)
}

enum MerchantAPIError: Error {
    case failedRequest
    case other(Error)
}

class MerchantAPI {
    static var shared: MerchantAPI?
    
    let merchantServerURL: URL
    let urlSession: URLSession
    lazy var decoder: JSONDecoder = JSONDecoder()
    
    init(url: URL, urlSession: URLSession = .shared) {
        self.merchantServerURL = url
        self.urlSession = urlSession
    }
    
    func createSession(completion: @escaping (Result<CreateSessionResponse>) -> Void) {
        let createPath = merchantServerURL.appendingPathComponent("session.php")
        var request = URLRequest(url: createPath)
        request.httpMethod = "POST"
        let task = urlSession.dataTask(with: request, completionHandler: responseHandler(completion))
        task.resume()
    }
    
    fileprivate func responseHandler<T: Decodable>(_ completion: @escaping (Result<T>) -> Void) -> (Data?, URLResponse?, Error?) -> Void {
        return { (data, response, error) in
            if let error = error {
                completion(Result.error(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let data = data else {
                completion(Result.error(MerchantAPIError.failedRequest))
                return
            }
            
            do {
                let response = try self.decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                completion(Result.error(error))
            }
        }
    }
}
