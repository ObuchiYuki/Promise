//
//  Promise+Wait.swift
//
//
//  Created by yuki on 2021/08/23.
//

#if canImport(Foundation)
import Foundation

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Duration {
    @inlinable var timeInterval: TimeInterval {
        let (seconds, attoseconds) = self.components
        return Double(seconds) + Double(attoseconds) * 1e-18
    }
}
 
extension Promise {
    @inlinable @_transparent
    public func wait(on queue: DispatchQueue = .main, for interval: TimeInterval) -> Promise<Output, Failure> {
        self.receive(on: { queue.asyncAfter(deadline: .now() + interval, execute: $0) })
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable @_transparent
    public func wait(on queue: DispatchQueue = .main, for duration: Duration) -> Promise<Output, Failure> {
        return self.wait(on: queue, for: duration.timeInterval)
    }
    
    @inlinable @_transparent
    public static func wait(on queue: DispatchQueue = .main, for interval: TimeInterval) -> Promise<Output, Failure> where Output == Void, Failure == Never {
        Promise.resolve().wait(on: queue, for: interval)
    }
    
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable @_transparent
    public static func wait(on queue: DispatchQueue = .main, for duration: Duration) -> Promise<Output, Failure> where Output == Void, Failure == Never {
        Promise.resolve().wait(on: queue, for: duration)
    }
}
#endif
