//
//  Promise+Timeout.swift
//  
//
//  Created by yuki on 2022/01/27.
//

#if canImport(Foundation)
import Foundation

public struct PromiseTimeoutError: LocalizedError {
    public let timeoutInterval: TimeInterval
    
    public var errorDescription: String { "PromiseTimeoutError: Timeout Interval \(timeoutInterval) s exceeded." }
}

extension Promise where Failure == Never {
    public func timeout(with timeoutInterval: TimeInterval) -> Promise<Output, PromiseTimeoutError> {
        Promise<Output, PromiseTimeoutError>{ resolve, reject in
            self.sink(resolve)
            Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false, block: { timer in
                reject(PromiseTimeoutError(timeoutInterval: timeoutInterval))
            })
        }
    }
}

extension Promise {
    public func timeout(with timeoutInterval: TimeInterval) -> Promise<Output, Error> {
        Promise<Output, Error>{ resolve, reject in
            self.sink(resolve, reject)
            Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false, block: { timer in
                reject(PromiseTimeoutError(timeoutInterval: timeoutInterval))
            })
        }
    }
}
#endif
