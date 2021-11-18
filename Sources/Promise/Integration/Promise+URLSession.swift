//
//  Promise+URLSession.swift
//
//
//  Created by yuki on 2021/08/07.
//

import Foundation

extension URLSession {
    public func data(for url: URL) -> Promise<Data, Error> {
        self.fetch(for: url).map{ $0.1 }
    }
    
    public func data(for request: URLRequest) -> Promise<Data, Error> {
        self.fetch(for: request).map{ $0.1 }
    }
    
    public func fetch(for url: URL) -> Promise<(URLResponse, Data), Error> {
        self.fetch(for: URLRequest(url: url))
    }
    
    public func fetch(for request: URLRequest) -> Promise<(URLResponse, Data), Error> {
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
