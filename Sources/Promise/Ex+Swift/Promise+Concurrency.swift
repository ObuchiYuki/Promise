//
//  Promise+Concurrency.swift
//  Promise
//
//  Created by yuki on 2023/03/17.
//

extension Promise: @unchecked Sendable {}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise where Failure == Never {
    @inlinable public var value: Output {
        @inlinable get async {
            #if DEBUG
            await withCheckedContinuation { continuation in
                let resumeReturning = unsafeBitCast(continuation.resume(returning:), to: ((Output) -> Void).self)
                self.subscribe(resumeReturning, {_ in })
            }
            #else
            await withUnsafeContinuation { continuation in
                let resumeReturning = unsafeBitCast(continuation.resume(returning:), to: ((Output) -> Void).self)
                self.subscribe(resumeReturning, {_ in })
            }
            #endif
        }
    }

    @inlinable
    public convenience init(priority: TaskPriority? = nil, @_implicitSelfCapture _ task: @escaping () async -> Output) {
        self.init()
        let task = Task(priority: priority) { self.resolve(await task()) }
        self.subscribe({_ in task.cancel() }, {_ in })
    }
    
    @inlinable
    public static func detached(priority: TaskPriority? = nil, @_implicitSelfCapture _ task: @escaping () async -> Output) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        let task = Task.detached(priority: priority) { promise.resolve(await task()) }
        promise.subscribe({_ in task.cancel() }, {_ in })
        return promise
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise {
    @inlinable public var value: Output {
        @inlinable get async throws {
            #if DEBUG
            try await withCheckedThrowingContinuation{ continuation in
                self.sink(continuation.resume(returning:), continuation.resume(throwing:))
            }
            #else
            try await withUnsafeThrowingContinuation{ continuation in
                self.sink(continuation.resume(returning:), continuation.resume(throwing:))
            }
            #endif
        }
    }
    
    @inlinable
    public convenience init(priority: TaskPriority? = nil, @_implicitSelfCapture _ task: @escaping () async throws -> Output) where Failure == Error {
        self.init()
        let task = Task(priority: priority) { do { self.resolve(try await task()) } catch { self.reject(error) } }
        self.subscribe({_ in task.cancel() }, {_ in task.cancel() })
    }
    
    @inlinable
    public static func detached(priority: TaskPriority? = nil, @_implicitSelfCapture _ task: @escaping () async throws -> Output) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        let task = Task.detached(priority: priority) { do { promise.resolve(try await task()) } catch { promise.reject(error) } }
        promise.subscribe({_ in task.cancel() }, {_ in task.cancel() })
        return promise
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

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise {
    @inlinable
    public func receiveOnMainActor() -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
         
        self.subscribe({ output in
            let task = Task.detached{ @MainActor in
                promise.resolve(output)
            }
            promise.subscribe({_ in task.cancel() }, {_ in task.cancel() })
        }, { error in
            let task = Task.detached{ @MainActor in
                promise.reject(error)
            }
            promise.subscribe({_ in task.cancel() }, {_ in task.cancel() })
        })
        
        return promise
    }
}
