//
//  Promise+Deinit.swift
//
//
//  Created by yuki on 2024/05/27.
//

public struct PromiseUnresolveError: Error, CustomStringConvertible {
    @inlinable public var description: String { "Promise has not been resolved." }
    
    @inlinable init() {}
}

@usableFromInline
final class PromiseObserver<Output> {
    @usableFromInline let promise: Promise<Output, Error>
    
    @inlinable init(promise: Promise<Output, Error>) {
        self.promise = promise
    }
    
    @inlinable deinit {
        self.promise.reject(PromiseUnresolveError())
    }
}

public final class PromiseResolver<Output> {
    @usableFromInline let promise: Promise<Output, Error>
    @usableFromInline let observer: PromiseObserver<Output>
    
    @inlinable init(promise: Promise<Output, Error>, observer: PromiseObserver<Output>) {
        self.promise = promise
        self.observer = observer
    }
    
    @inlinable public final func callAsFunction(_ output: Output) {
        self.promise.resolve(output)
    }
}

public final class PromiseRejector<Output> {
    @usableFromInline let promise: Promise<Output, Error>
    @usableFromInline let observer: PromiseObserver<Output>
    
    @inlinable init(promise: Promise<Output, Error>, observer: PromiseObserver<Output>) {
        self.promise = promise
        self.observer = observer
    }
    
    @inlinable public final func callAsFunction(_ failure: Error) {
        self.promise.reject(failure)
    }
}

extension Promise {
    @inlinable @_transparent
    public func catchUnresolveError(_ replacingError: Failure) -> Promise<Output, Failure> {
        self.mapError {
            guard let error = $0 as? PromiseUnresolveError else { return $0 }
            return replacingError
        }
    }
}

extension Promise where Failure == Error {
    @inlinable @_transparent
    public static func optionallyResolving() -> (promise: Promise<Output, Failure>, resolver: PromiseResolver<Output>, rejector: PromiseRejector<Output>) {
        let promise = Promise<Output, Failure>()
        
        let observer = PromiseObserver(promise: promise)
        let resolver = PromiseResolver(promise: promise, observer: observer)
        let rejector = PromiseRejector(promise: promise, observer: observer)
        
        return (promise, resolver, rejector)
    }
    
    @inlinable @_transparent
    public static func optionallyResolving(@_implicitSelfCapture _ handler: (PromiseResolver<Output>, PromiseRejector<Output>) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        
        let observer = PromiseObserver(promise: promise)
        let resolver = PromiseResolver(promise: promise, observer: observer)
        let rejector = PromiseRejector(promise: promise, observer: observer)
        
        handler(resolver, rejector)
        
        return promise
    }
    
    @inlinable public static func optionallyResolving(@_implicitSelfCapture _ handler: (PromiseResolver<Output>, PromiseRejector<Output>) throws -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        
        let observer = PromiseObserver(promise: promise)
        let resolver = PromiseResolver(promise: promise, observer: observer)
        let rejector = PromiseRejector(promise: promise, observer: observer)
        
        do {
            try handler(resolver, rejector)
        } catch {
            promise.reject(error)
        }
        
        return promise
    }
}

