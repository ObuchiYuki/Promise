//
//  Promise+Cancel.swift
//  
//
//  Created by yuki on 2022/01/27.
//

import Foundation

final public class PromiseCancel: LocalizedError {
    public static let shared = PromiseCancel()
    public var userInfo = [String: Any?]()
    
    public var errorDescription: String? { "Promise has been cancelled." }
}

extension Promise {
    public func cancel(_ cancel: PromiseCancel = PromiseCancel.shared) where Failure == Error {
        self.reject(cancel)
    }
    
    public func cancel(_ cancel: PromiseCancel = PromiseCancel.shared) where Failure == PromiseCancel {
        self.reject(cancel)
    }
    
    public func cancel(by canceller: Promise<Void, Never>) -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            canceller.subscribe({_ in reject(PromiseCancel.shared) }, {_ in})
            self.subscribe(resolve, reject)
        }
    }

    public func cancel(by canceller: Promise<Void, Never>) -> Promise<Output, PromiseCancel> where Failure == Never {
        Promise<Output, PromiseCancel> { resolve, reject in
            canceller.subscribe({_ in reject(PromiseCancel.shared)}, {_ in})
            self.subscribe(resolve, {_ in})
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping () -> ()) -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                if error is PromiseCancel {
                    handler()
                    resolve(())
                } else {
                    reject(error)
                }
            })
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping () -> ()) -> Promise<Void, Never> where Failure == PromiseCancel {
        Promise<Void, Never> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                handler()
                resolve(())
            })
        }
    }
}

