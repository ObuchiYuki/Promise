//
//  Promise.swift
//
//
//  Created by yuki on 2020/10/11.
//

public final class Promise<Output, Failure: Error> {
    public enum State {
        case pending
        case fulfilled(Output)
        case rejected(Failure)
    }
    
    @usableFromInline struct Subscriber {
        @usableFromInline let resolve: (Output) -> ()
        @usableFromInline let reject: (Failure) -> ()
        
        @inlinable init(resolve: @escaping (Output) -> Void, reject: @escaping (Failure) -> Void) {
            self.resolve = resolve
            self.reject = reject
        }
    }
    
    @inlinable public var state: State { _state }

    @usableFromInline var _state = State.pending
    @usableFromInline var _subscribers = [Subscriber]()
    @usableFromInline let _lock = RecursiveLock()
    
    @inlinable public init() {}
    
    @inlinable public func resolve(_ output: Output) {
        self._lock.lock()
        defer { self._lock.unlock() }
        
        guard case .pending = self._state else { return }
        
        self._state = .fulfilled(output)
        for subscriber in self._subscribers { subscriber.resolve(output) }
        self._subscribers.removeAll()
    }
    
    @inlinable public func reject(_ failure: Failure) {
        self._lock.lock()
        defer { self._lock.unlock() }
        
        guard case .pending = self._state else { return }
        
        self._state = .rejected(failure)
        for subscriber in self._subscribers { subscriber.reject(failure) }
        self._subscribers.removeAll()
    }

    @inlinable public func subscribe(_ resolve: @escaping (Output) -> (), _ reject: @escaping (Failure) -> ()) {
        self._lock.lock()
        defer { self._lock.unlock() }
        
        switch self._state {
        case .pending: self._subscribers.append(Subscriber(resolve: resolve, reject: reject))
        case .fulfilled(let output): resolve(output)
        case .rejected(let failure): reject(failure)
        }
    }
    
    #if DEBUG
    @inlinable deinit {
        if case .pending = self._state, !self._subscribers.isEmpty {
            assertionFailure("Unresolved release of Promise.")
        }
    }
    #endif
}

extension Promise: CustomStringConvertible {
    @inlinable public var description: String {
        "Promise<\(Output.self), \(Failure.self)>(\(self._state))"
    }
}
