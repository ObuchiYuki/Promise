//
//  Promise+Cancel.swift
//  
//
//  Created by yuki on 2022/01/27.
//

import Foundation

final public class PromiseCancelError: LocalizedError {
    static let shared = PromiseCancelError()
    
    public var errorDescription: String? { "Promise has been cancelled." }
}

extension Promise {
    public func cancel() where Failure == Error {
        self.reject(PromiseCancelError.shared)
    }
    
    public func cancel() where Failure == PromiseCancelError {
        self.reject(PromiseCancelError.shared)
    }
    
    public func cancel(by canceller: Promise<Void, Never>) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            canceller.subscribe({_ in reject(PromiseCancelError.shared) }, {_ in})
            self.subscribe(resolve, reject)
        }
    }

    public func cancel(by canceller: Promise<Void, Never>) -> Promise<Output, PromiseCancelError> where Failure == Never {
        Promise<Output, PromiseCancelError> { resolve, reject in
            canceller.subscribe({_ in reject(PromiseCancelError.shared)}, {_ in})
            self.subscribe(resolve, {_ in})
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping () -> ()) -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                if error is PromiseCancelError {
                    handler()
                    resolve(())
                } else {
                    reject(error)
                }
            })
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping () -> ()) -> Promise<Void, Never> where Failure == PromiseCancelError {
        Promise<Void, Never> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                handler()
                resolve(())
            })
        }
    }
}

