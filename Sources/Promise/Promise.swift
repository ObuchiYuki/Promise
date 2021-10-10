//
//  Promise.swift
//  asycEmurate
//
//  Created by yuki on 2021/08/07.
//

import Foundation

public final class Promise<Output, Failure> where Failure: Error {
    public struct Subscriber {
        public let resolve: (Output) -> ()
        public let reject: (Failure) -> ()
        
        @inlinable public init(resolve: @escaping (Output) -> (), reject: @escaping (Failure) -> ()) {
            self.resolve = resolve
            self.reject = reject
        }
    }
    
    @usableFromInline enum State {
        case pending
        case fulfilled(Output)
        case rejected(Failure)
    }
    
    @usableFromInline var state = State.pending
    @usableFromInline let stateQueue = DispatchQueue(label: "com.yuki.promise")
    @usableFromInline var subscribers = [Subscriber]()
    
    @inlinable init() {}

    @inlinable func subscribe(_ resolve: @escaping (Output) -> (), _ reject: @escaping (Failure) -> ()) {
        self.stateQueue.sync {
            switch self.state {
            case .pending: self.subscribers.append(Subscriber(resolve: resolve, reject: reject))
            case .fulfilled(let output): resolve(output)
            case .rejected(let error): reject(error)
            }
        }
    }
    
    @inlinable public func fullfill(_ output: Output) {
        assert(!self.isSettled, "Promsie already settled.")
        
        self.stateQueue.sync {
            self.state = .fulfilled(output)
            for subscriber in self.subscribers { subscriber.resolve(output) }
            self.subscribers = []
        }
    }
    
    @inlinable public func reject(_ error: Failure) {
        assert(!self.isSettled, "Promsie already settled.")
        
        self.stateQueue.sync {
            self.state = .rejected(error)
            for subscriber in self.subscribers { subscriber.reject(error) }
            self.subscribers = []
        }
    }
}

extension Promise {
    @inlinable public convenience init(_ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) {
        self.init()
        handler(self.fullfill, self.reject)
    }
    @inlinable public convenience init(_ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) where Failure == Error {
        self.init()
        do { try handler(self.fullfill, self.reject) } catch { self.reject(error) }
    }
    
    @inlinable public convenience init(output: Output) {
        self.init()
        self.fullfill(output)
    }
    
    @inlinable public convenience init(failure: Failure) {
        self.init()
        self.reject(failure)
    }
    
    @inlinable public convenience init(output: @autoclosure () throws -> Output) where Failure == Error {
        self.init()
        do { self.fullfill(try output()) } catch { self.reject(error) }
    }
    
    @inlinable public static func pending() -> Promise<Output, Failure> {
        Promise()
    }
}

extension Promise {
    @inlinable public func map<T>(_ tranceform: @escaping (Output)->T) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ resolve(tranceform($0)) }, reject)
        }
    }
    
    @inlinable public func flatMap<T>(_ tranceform: @escaping (Output)->Promise<T, Failure>) -> Promise<T, Failure> {
        Promise<T, Failure> { resolve, reject in
            self.subscribe({ tranceform($0).subscribe(resolve, reject) }, reject)
        }
    }
    
    @inlinable public func tryMap<T>(_ tranceform: @escaping (Output) throws -> T) -> Promise<T, Error> {
        Promise<T, Error> { resolve, reject in
            self.subscribe({ do { try resolve(tranceform($0)) } catch { reject(error) } }, reject)
        }
    }
    
    @inlinable public func tryFlatMap<T>(_ tranceform: @escaping (Output) throws -> Promise<T, Error>) -> Promise<T, Error> {
        Promise<T, Error> { resolve, reject in
            self.subscribe({ do { try tranceform($0).subscribe(resolve, reject) } catch { reject(error) } }, reject)
        }
    }
    
    @inlinable public func mapError<T>(_ tranceform: @escaping (Failure)->T) -> Promise<Output, T> {
        Promise<Output, T> { resolve, reject in
            self.subscribe(resolve, { reject(tranceform($0)) })
        }
    }
        
    @inlinable public func replaceError(with value: Output) -> Promise<Output, Never> {
        Promise<Output, Never> { resolve, _ in
            self.subscribe(resolve, {_ in resolve(value) })
        }
    }
    
    @inlinable public func eraseToError() -> Promise<Output, Error> {
        Promise<Output, Error> { resolve, reject in
            self.subscribe(resolve, reject)
        }
    }
    
    @inlinable public func eraseToVoid() -> Promise<Void, Failure> {
        Promise<Void, Failure> { resolve, reject in
            self.subscribe({_ in resolve(()) }, reject)
        }
    }
    
    @inlinable public func receive(on callback: @escaping (@escaping () -> ()) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ o in callback{ resolve(o) } }, { f in callback{ reject(f) } })
        }
    }
    
    @inlinable public func peek(_ onFulfilled: @escaping (Output) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ onFulfilled($0); resolve($0) }, reject)
        }
    }
    
    @inlinable public func peekError(_ onRejected: @escaping (Failure) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe(resolve, { onRejected($0); reject($0) })
        }
    }
    
    @discardableResult
    @inlinable public func `catch`(_ onRejected: @escaping (Failure) -> ()) -> Promise<Void, Never> {
        Promise<Void, Never> { resolve, _ in
            self.subscribe({_ in resolve(()) }, { onRejected($0); resolve(()) })
        }
    }
    
    @discardableResult
    @inlinable public func finally(_ onFinally: @escaping () -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            self.subscribe({ onFinally(); resolve($0) }, { onFinally(); reject($0) })
        }
    }
    
    @inlinable public func sink(_ onFulfilled: @escaping (Output) -> (), _ onRejected: @escaping (Failure) -> ()) {
        self.subscribe(onFulfilled, onRejected)
    }
    
    @inlinable public func sink(_ onFulfilled: @escaping (Output) -> ()) where Failure == Never {
        self.subscribe(onFulfilled, {_ in})
    }
}

extension Promise {
    @inlinable public var isSettled: Bool {
        self.stateQueue.sync {
            if case .pending = self.state { return false }
            return true
        }
    }
    @inlinable public var result: Result<Output, Failure>? {
        self.stateQueue.sync {
            switch self.state {
            case .pending: return nil
            case .fulfilled(let output): return .success(output)
            case .rejected(let failure): return .failure(failure)
            }
        }
    }
}

extension Promise: CustomStringConvertible {
    @inlinable public var description: String {
        self.stateQueue.sync { "Promise<\(Output.self), \(Failure.self)>(\(self.state))" }
    }
}
