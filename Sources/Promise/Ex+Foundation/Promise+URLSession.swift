//
//  Promise+URLSession.swift
//  Promise
//
//  Created by yuki on 2021/08/07.
//

#if canImport(Foundation)
import Foundation

extension URLSession {
    @inlinable public func data(for url: URL) -> Promise<Data, Error> {
        self.fetch(url).map{ $0.1 }
    }
    
    @inlinable public func data(for request: URLRequest) -> Promise<Data, Error> {
        self.fetch(request).map{ $0.1 }
    }
    
    @inlinable public func fetch(_ url: URL) -> Promise<(URLResponse, Data), Error> {
        self.fetch(URLRequest(url: url))
    }
    
    @inlinable public func fetch(_ request: URLRequest) -> Promise<(URLResponse, Data), Error> {
        let promise = Promise<(URLResponse, Data), Error>()
        
        self.dataTask(with: request) { data, responce, error in
            if let error = error {
                promise.reject(error)
            } else if let data = data, let responce = responce {
                promise.resolve((responce, data))
            } else {
                promise.reject(NSError(domain: "Promise", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: "Data task received no data and no error."
                ]))
            }
        }
        .resume()
        
        return promise
    }
}

extension Data {
    @inlinable public static func async(contentsOf url: URL) -> Promise<Data, Error> {
        URLSession.shared.data(for: url)
    }
}

extension String {
    @inlinable public static func async(contentsOf url: URL, encoding: Encoding) -> Promise<String, Error> {
        Promise.tryDispatch { try String(contentsOf: url, encoding: encoding) }
    }
}

#endif
