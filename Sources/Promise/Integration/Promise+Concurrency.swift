//
//  File.swift
//  
//
//  Created by yuki on 2023/03/17.
//

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Promise {
    public func value() async -> Output where Failure == Never {
        await withCheckedContinuation{ continuation in
            self.sink(continuation.resume(returning:), continuation.resume(throwing:))
        }
    }

    public func value() async throws -> Output {
        try await withCheckedThrowingContinuation{ continuation in
            self.sink(continuation.resume(returning:), continuation.resume(throwing:))
        }
    }
    
    public convenience init(_ task: @escaping () async -> Output) where Failure == Never {
        self.init()
        
        let task = Task{ self.fulfill(await task()) }
        self.subscribe({_ in task.cancel() }, {_ in })
    }
    
    public convenience init(_ task: @escaping () async throws -> Output) where Failure == Error {
        self.init()
        
        let task = Task{
            do { self.fulfill(try await task()) } catch { self.reject(error) }
        }
        
        self.subscribe({_ in task.cancel() }, {_ in task.cancel() })
    }
}
