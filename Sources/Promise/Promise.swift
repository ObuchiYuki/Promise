//
//  Promise.swift
//  asycEmurate
//
//  Created by yuki on 2021/08/07.
//

import Foundation

public final class Promise<Output, Failure> where Failure: Error {
    public enum State {
        case pending
        case fulfilled(Output)
        case rejected(Failure)
    }
    
    @usableFromInline struct Subscriber {
        public let resolve: (Output) -> ()
        public let reject: (Failure) -> ()
        
        @inlinable init(resolve: @escaping (Output) -> (), reject: @escaping (Failure) -> ()) {
            self.resolve = resolve
            self.reject = reject
        }
    }

    public var state = State.pending
    @usableFromInline var subscribers = [Subscriber]()
    
    @inlinable init() {}

    @inlinable func subscribe(_ resolve: @escaping (Output) -> (), _ reject: @escaping (Failure) -> ()) {
        switch self.state {
        case .pending: self.subscribers.append(Subscriber(resolve: resolve, reject: reject))
        case .fulfilled(let output): resolve(output)
        case .rejected(let error): reject(error)
        }
    }
    
    @inlinable public func fullfill(_ output: Output) {
        if self.isSettled { return }
        
        self.state = .fulfilled(output)
        for subscriber in self.subscribers { subscriber.resolve(output) }
        self.subscribers.removeAll()
    }
    
    @inlinable public func reject(_ error: Failure) {
        if self.isSettled { return }
        
        self.state = .rejected(error)
        for subscriber in self.subscribers { subscriber.reject(error) }
        self.subscribers.removeAll()
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
    @inlinable public var isSettled: Bool {
        if case .pending = self.state { return false }
        return true
    }
}

extension Promise: CustomStringConvertible {
    @inlinable public var description: String {
        "Promise<\(Output.self), \(Failure.self)>(\(self.state))"
    }
}
