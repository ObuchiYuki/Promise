//
//  Promise+Cancel.swift
//  
//
//  Created by yuki on 2022/01/27.
//

import Foundation

public struct PromiseCancelError: LocalizedError {
    public let object: Any
    
    public var errorDescription: String? { "Promise has been cancelled with '\(object)'." }
}

extension Promise {
    public func cancelled<T>(by canceller: Promise<T, Never>) -> Promise<Output, Error> {
        Promise<Output, Error>{ resolve, reject in
            canceller.subscribe({ reject(PromiseCancelError(object: $0)) }, {_ in})
            self.subscribe(resolve, reject)
        }
    }

    public func cancelled<T>(by canceller: Promise<T, Never>) -> Promise<Output, PromiseCancelError> where Failure == Never {
        Promise<Output, PromiseCancelError>{ resolve, reject in
            canceller.subscribe({ reject(PromiseCancelError(object: $0))}, {_ in})
            self.subscribe(resolve, {_ in})
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping (Any) -> () = {_ in}) -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                if let error = error as? PromiseCancelError {
                    handler(error.object)
                    resolve(())
                } else {
                    reject(error)
                }
            })
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping (Any) -> () = {_ in}) -> Promise<Void, Never> where Failure == PromiseCancelError {
        Promise<Void, Never> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                handler(error.object)
                resolve(())
            })
        }
    }
}

