//
//  Promise+Timeout.swift
//  Promise
//
//  Created by yuki on 2022/01/27.
//

#if canImport(Foundation)
import Foundation

public struct PromiseTimeoutError: Error, LocalizedError, CustomStringConvertible {
    @inlinable public var description: String { "Promise has timed out." }
    
    @inlinable init() {}
}

extension Promise {
    @inlinable public func timeout(_ interval: TimeInterval, on queue: DispatchQueue = .main) -> Promise<Output, Error> {
        self.timeout(interval, error: PromiseTimeoutError(), on: queue)
    }
    
    @inlinable public func timeout<T: Error>(_ interval: TimeInterval, error: @autoclosure @escaping () -> T, on queue: DispatchQueue = .main) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, promise.reject)
            
        queue.asyncAfter(deadline: .now() + interval) {
            if !promise.isSettled {
                promise.reject(error())
            }
        }
        
        return promise
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable public func timeout(_ duration: Duration, on queue: DispatchQueue = .main) -> Promise<Output, Error> {
        self.timeout(duration.timeInterval, error: PromiseTimeoutError(), on: queue)
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable public func timeout<T: Error>(_ duration: Duration, error: @autoclosure @escaping () -> T, on queue: DispatchQueue = .main) -> Promise<Output, Error> {
        self.timeout(duration.timeInterval, error: error(), on: queue)
    }
}
#endif
