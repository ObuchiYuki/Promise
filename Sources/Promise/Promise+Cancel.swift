//
//  Promise+Cancel.swift
//  
//
//  Created by yuki on 2022/01/27.
//

public struct PromiseCancel: Error {
    public var userInfo = [String: Any?]()
    
    public init() {}
    
    public var errorDescription: String? { "Promise has been cancelled." }
}

#if canImport(Foundation)
import Foundation

extension PromiseCancel: LocalizedError {}
#endif

extension Promise {
    @inlinable public func cancel(_ cancel: PromiseCancel = PromiseCancel()) where Failure == Error {
        self.reject(cancel)
    }
    
    @inlinable public func cancel(_ cancel: PromiseCancel = PromiseCancel()) where Failure == PromiseCancel {
        self.reject(cancel)
    }
    
    @inlinable public func cancel(by canceller: Promise<Void, Never>) -> Promise<Output, Error> {
        let promise = Promise<Output, Error>()
        canceller.subscribe({_ in promise.reject(PromiseCancel()) }, {_ in})
        self.subscribe(promise.resolve, promise.reject)
        return promise
    }

    @inlinable public func cancel(by canceller: Promise<Void, Never>, make: @escaping () -> PromiseCancel = { PromiseCancel() }) -> Promise<Output, PromiseCancel> where Failure == Never {
        let promise = Promise<Output, PromiseCancel>()
        canceller.subscribe({_ in promise.reject(make()) }, {_ in})
        self.subscribe(promise.resolve, {_ in})
        return promise
    }
    
    @discardableResult
    @inlinable public func catchCancel(by handler: @escaping (PromiseCancel) -> ()) -> Promise<Void, Failure> {
        let promise = Promise<Void, Failure>()
        self.subscribe({_ in promise.resolve(()) }, { error in
            if let error = error as? PromiseCancel {
                handler(error)
                promise.resolve(())
            } else {
                promise.reject(error)
            }
        })
        return promise
    }
    
    @discardableResult
    public func catchCancel(by handler: @escaping (PromiseCancel) -> ()) -> Promise<Void, Never> where Failure == PromiseCancel {
        let promise = Promise<Void, Never>()
        self.subscribe({_ in promise.resolve(()) }, { error in
            handler(error)
            promise.resolve(())
        })
        return promise
    }
}

