//
//  Promise+Wait.swift
//
//
//  Created by yuki on 2021/08/23.
//

#if canImport(Foundation)
import Foundation

extension Promise {
    public func wait(on queue: DispatchQueue = .main, for interval: TimeInterval) -> Promise<Output, Failure> {
        self.receive(on: { queue.asyncAfter(deadline: .now() + interval, execute: $0) })
    }
    
    public static func wait(on queue: DispatchQueue = .main, for interval: TimeInterval) -> Promise<Output, Failure> where Output == Void {
        Promise.resolve(()).wait(on: queue, for: interval)
    }
}
#endif
