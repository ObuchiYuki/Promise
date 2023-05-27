//
//  File.swift
//  
//
//  Created by yuki on 2023/03/17.
//

@available(iOS 13.0.0, *) @available(macOS 10.15.0, *)
extension Promise {
    public func value() async throws -> Output {
        try await withCheckedThrowingContinuation{ continuation in
            self.sink(continuation.resume(returning:), continuation.resume(throwing:))
        }
    }

    public func value() async -> Output where Failure == Never {
        await withCheckedContinuation{ continuation in
            self.sink(continuation.resume(returning:), continuation.resume(throwing:))
        }
    }
    
    public convenience init(_ task: @escaping () async -> Output) where Failure == Never {
        self.init()
        
        Task{
            self.fulfill(await task())
        }
    }
    
    public convenience init(_ task: @escaping () async throws -> Output) where Failure == Error {
        self.init()
        
        Task{
            do {
                self.fulfill(try await task())
            } catch {
                self.reject(error)
            }
        }
    }
}
