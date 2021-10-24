//
//  Promise+URL.swift
//  asycEmurate
//
//  Created by yuki on 2021/08/07.
//

import Foundation

extension URLSession {
    @inlinable public func data(for url: URL) -> Promise<Data, Error> {
        self.fetch(for: url).map{ $0.1 }
    }
    
    @inlinable public func data(for request: URLRequest) -> Promise<Data, Error> {
        self.fetch(for: request).map{ $0.1 }
    }
    
    @inlinable public func fetch(for url: URL) -> Promise<(URLResponse, Data), Error> {
        self.fetch(for: URLRequest(url: url))
    }
    
    @inlinable public func fetch(for request: URLRequest) -> Promise<(URLResponse, Data), Error> {
        Promise{ resolve, reject in
            self.dataTask(with: request) { data, responce, error in
                func buildErrorUserInfo() -> [String: Any] {
                    var userInfo = ["request": request.descriptionObject, "responce": responce as Any]
                    
                    if let data = data, let string = String(data: data, encoding: .utf8) {
                        userInfo["data"] = string
                    }
                    return userInfo
                }
                
                if let httpResponce = responce as? HTTPURLResponse, httpResponce.hasError {
                    reject(NSError(domain: "Error HTTP Responce", code: httpResponce.statusCode, userInfo: buildErrorUserInfo()))
                } else if let error = error {
                    reject(error)
                } else if let data = data, let responce = responce {
                    resolve((responce, data))
                } else {
                    reject(NSError(domain: "No Data", code: 0, userInfo: buildErrorUserInfo()))
                }
            }
            .resume()
        }
    }
}

extension HTTPURLResponse {
    @usableFromInline var hasError: Bool { !(200..<400).contains(self.statusCode) }
}

extension URLRequest {
    @usableFromInline var descriptionObject: NSDictionary {
        [
            "URL": self.url as Any,
            "Headers": allHTTPHeaderFields as Any,
            "Body": httpBody as Any,
            "Method": httpMethod ?? "GET"
        ]
    }
}
