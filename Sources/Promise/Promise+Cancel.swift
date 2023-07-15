//
//  Promise+Cancel.swift
//  
//
//  Created by yuki on 2022/01/27.
//

final public class PromiseCancel: Error {
    public static let shared = PromiseCancel()
    public var userInfo = [String: Any?]()
    
    public var errorDescription: String? { "Promise has been cancelled." }
}

#if canImport(Foundation)
import Foundation

extension PromiseCancel: LocalizedError {}
#endif

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

    public func cancel(by canceller: Promise<Void, Never>, make: @escaping () -> PromiseCancel = { PromiseCancel.shared }) -> Promise<Output, PromiseCancel> where Failure == Never {
        Promise<Output, PromiseCancel> { resolve, reject in
            canceller.subscribe({_ in reject(make()) }, {_ in})
            self.subscribe(resolve, {_ in})
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping (PromiseCancel) -> ()) -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                if let error = error as? PromiseCancel {
                    handler(error)
                    resolve(())
                } else {
                    reject(error)
                }
            })
        }
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping (PromiseCancel) -> ()) -> Promise<Void, Never> where Failure == PromiseCancel {
        Promise<Void, Never> { resolve, reject in
            self.subscribe({_ in resolve(()) }, { error in
                handler(error)
                resolve(())
            })
        }
    }
}

