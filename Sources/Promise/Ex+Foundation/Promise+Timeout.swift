//
//  Promise+Timeout.swift
//  
//
//  Created by yuki on 2022/01/27.
//

#if canImport(Foundation)
import Foundation

public struct PromiseTimeoutError: Error, CustomStringConvertible {
    public let timeoutInterval: TimeInterval
    
    public var description: String { "PromiseTimeoutError: Timeout interval \(timeoutInterval) s exceeded." }
    
    @inlinable init(timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
}

extension Promise {
    @inlinable public func timeout(_ interval: TimeInterval, on queue: DispatchQueue = .global()) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, promise.reject)
            
        queue.asyncAfter(deadline: .now() + interval) {
            promise.reject(PromiseTimeoutError(timeoutInterval: interval))
        }
        
        return promise
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable public func timeout(_ duration: Duration, on queue: DispatchQueue = .global()) -> Promise<Output, Error> {
        self.timeout(duration.timeInterval, on: queue)
    }
}
#endif
