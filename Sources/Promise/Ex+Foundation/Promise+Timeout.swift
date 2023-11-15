//
//  Promise+Timeout.swift
//  
//
//  Created by yuki on 2022/01/27.
//

#if canImport(Foundation)
import Foundation

extension Promise {
    @inlinable public func timeout<T: Error>(_ interval: TimeInterval, error: @autoclosure @escaping () -> T, on queue: DispatchQueue = .global()) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        self.subscribe(promise.resolve, promise.reject)
            
        queue.asyncAfter(deadline: .now() + interval) {
            promise.reject(error())
        }
        
        return promise
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable public func timeout<T: Error>(_ duration: Duration, error: @autoclosure @escaping () -> T, on queue: DispatchQueue = .global()) -> Promise<Output, Error> {
        self.timeout(duration.timeInterval, error: error(), on: queue)
    }
}
#endif
