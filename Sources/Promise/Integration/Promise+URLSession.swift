//
//  Promise+URLSession.swift
//
//
//  Created by yuki on 2021/08/07.
//

#if canImport(Foundation)
import Foundation

extension URLSession {
    public func data(for url: URL) -> Promise<Data, Error> {
        self.fetch(url).map{ $0.1 }
    }
    
    public func data(for request: URLRequest) -> Promise<Data, Error> {
        self.fetch(request).map{ $0.1 }
    }
    
    public func fetch(_ url: URL) -> Promise<(URLResponse, Data), Error> {
        self.fetch(URLRequest(url: url))
    }
    
    public func fetch(_ request: URLRequest) -> Promise<(URLResponse, Data), Error> {
        Promise{ resolve, reject in
            self.dataTask(with: request) { data, responce, error in
                if let error = error {
                    reject(error)
                } else if let data = data, let responce = responce {
                    resolve((responce, data))
                } else {
                    reject(NSError(domain: "No data or responce", code: 0, userInfo: nil))
                }
            }
            .resume()
        }
    }
}
#endif
