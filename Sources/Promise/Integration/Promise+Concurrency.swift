//
//  File.swift
//  
//
//  Created by yuki on 2023/03/17.
//

extension Promise {
    @available(macOS 10.15.0, *)
    public func value() async throws -> Output {
        try await withCheckedThrowingContinuation{ continuation in
            self.sink(continuation.resume(returning:), continuation.resume(throwing:))
        }
    }
    
    @available(macOS 10.15.0, *)
    public func value() async -> Output where Failure == Never {
        await withCheckedContinuation{ continuation in
            self.sink(continuation.resume(returning:), continuation.resume(throwing:))
        }
    }
}
