//
//  File.swift
//  
//
//  Created by yuki on 2023/03/17.
//

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise where Failure == Never {
    @inlinable public var value: Output {
        get async {
            await withCheckedContinuation{ continuation in
                self.sink(continuation.resume(returning:), continuation.resume(throwing:))
            }
        }
    }

    @inlinable public convenience init(_ task: @escaping () async -> Output) {
        self.init()
        let task = Task{ self.resolve(await task()) }
        self.subscribe({_ in task.cancel() }, {_ in })
    }
    
    @inlinable public static func detached(_ task: @escaping () async -> Output) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        let task = Task.detached{ self.resolve(await task()) }
        promise.subscribe({_ in task.cancel() }, {_ in })
        return promise
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise {
    @inlinable public var value: Output {
        @inlinable get async throws {
            try await withCheckedThrowingContinuation{ continuation in
                self.sink(continuation.resume(returning:), continuation.resume(throwing:))
            }
        }
    }
    
    @inlinable public convenience init(_ task: @escaping () async throws -> Output) where Failure == Error {
        self.init()
        let task = Task{ do { self.resolve(try await task()) } catch { self.reject(error) } }
        self.subscribe({_ in task.cancel() }, {_ in task.cancel() })
    }
    
    @inlinable public static func detached(_ task: @escaping () async throws -> Output) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        let task = Task.detached{ do { promise.resolve(try await task()) } catch { promise.reject(error) } }
        promise.subscribe({_ in task.cancel() }, {_ in task.cancel() })
        return promise
    }
}
