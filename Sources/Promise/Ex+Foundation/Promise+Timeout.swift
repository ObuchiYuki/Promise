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
    
    public var errorDescription: String { "PromiseTimeoutError: Timeout interval \(timeoutInterval) s exceeded." }
}

extension Promise {
    public func timeout(with timeoutInterval: TimeInterval) -> Promise<Output, Error> {
        Promise<Output, Error>{ resolve, reject in
            self.subscribe(resolve, reject)
            
            Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { timer in
                reject(PromiseTimeoutError(timeoutInterval: timeoutInterval))
            }
        }
    }
    
    public func timeout(with timeoutInterval: TimeInterval) -> Promise<Output, PromiseTimeoutError> where Failure == Never {
        Promise<Output, PromiseTimeoutError>{ resolve, reject in
            self.subscribe(resolve, {_ in})
            
            Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { timer in
                reject(PromiseTimeoutError(timeoutInterval: timeoutInterval))
            }
        }
    }
}
#endif
