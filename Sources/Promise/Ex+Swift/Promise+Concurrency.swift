//
//  Promise+Concurrency.swift
//  Promise
//
//  Created by yuki on 2023/03/17.
//

extension Promise: @unchecked Sendable where Output: Sendable, Failure: Sendable {}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise where Output: Sendable, Failure == Never {
    @inlinable public var value: Output {
        @inlinable get async {
            #if DEBUG
            await withCheckedContinuation { continuation in
                self.subscribe({ continuation.resume(returning: $0) }, { _ in })
            }
            #else
            await withUnsafeContinuation { continuation in
                self.subscribe({ continuation.resume(returning: $0) }, { _ in })
            }
            #endif
        }
    }

    @inlinable
    public convenience init(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ task: @Sendable @escaping () async -> Output
    ) {
        self.init()
        let task = Task(priority: priority) { self.resolve(await task()) }
        self.subscribe({_ in task.cancel() }, {_ in })
    }
    
    @inlinable
    public static func detached(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ task: @Sendable @escaping () async -> Output
    ) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        let task = Task.detached(priority: priority) { promise.resolve(await task()) }
        promise.subscribe({_ in task.cancel() }, {_ in })
        return promise
    }
    
    @inlinable
    public func asink(
        @_inheritActorContext @_implicitSelfCapture _ receiveOutput: @Sendable @escaping (Output) async -> Void
    ) {
        self.subscribe({ output in
            Task { await receiveOutput(output) }
        }, { _ in })
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise where Output: Sendable {
    @inlinable public var value: Output {
        @inlinable get async throws {
            #if DEBUG
            try await withCheckedThrowingContinuation { continuation in
                self.subscribe({ continuation.resume(returning: $0) }, continuation.resume(throwing:))
            }
            #else
            try await withUnsafeThrowingContinuation { continuation in
                self.sink(continuation.resume(returning:), continuation.resume(throwing:))
            }
            #endif
        }
    }
    
    @inlinable
    public convenience init(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ task: @Sendable @escaping () async throws -> Output
    ) where Failure == Error {
        self.init()
        let task = Task(priority: priority) { do { self.resolve(try await task()) } catch { self.reject(error) } }
        self.subscribe({_ in task.cancel() }, {_ in task.cancel() })
    }
    
    @inlinable
    public static func detached(
        priority: TaskPriority? = nil,
        @_inheritActorContext @_implicitSelfCapture _ task: @Sendable @escaping () async throws -> Output
    ) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        let task = Task.detached(priority: priority) { do { promise.resolve(try await task()) } catch { promise.reject(error) } }
        promise.subscribe({_ in task.cancel() }, {_ in task.cancel() })
        return promise
    }
    
    @inlinable
    public func asink(
        @_inheritActorContext @_implicitSelfCapture _ receiveOutput: @Sendable @escaping (Output) async -> Void,
        @_inheritActorContext @_implicitSelfCapture _ receiveFailure: @Sendable @escaping (Failure) async -> Void
    ) {
        self.subscribe({ output in
            Task { await receiveOutput(output) }
        }, { error in
            Task { await receiveFailure(error) }
        })
    }
    
    @inlinable
    public func apeek(
        @_inheritActorContext @_implicitSelfCapture _ receiveOutput: @Sendable @escaping (Output) async -> Void
    ) {
        self.subscribe({ output in
            Task { await receiveOutput(output) }
        }, { _ in })
    }
    
    @inlinable
    public func apeekError(
        @_inheritActorContext @_implicitSelfCapture _ receiveFailure: @Sendable @escaping (Failure) async -> Void
    ) {
        self.subscribe({ _ in }, { error in
            Task { await receiveFailure(error) }
        })
    }
}

func m() {
    Promise<Int, Never>.resolve(1)
        .apeek { @MainActor value in
            print(value.advanced(by: 1))
        }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Task {
    @inlinable
    public var promise: Promise<Success, Failure> {
        let promise = Promise<Success, Failure>()
        let task = Task<Void, Never> {
            switch await self.result {
            case .success(let value): promise.resolve(value)
            case .failure(let error): promise.reject(error)
            }
        }
        promise.subscribe({_ in task.cancel() }, {_ in task.cancel() })
        return promise
    }
}
