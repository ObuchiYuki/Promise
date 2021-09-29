//
//  Promise+Do.swift
//  asycEmurate
//
//  Created by yuki on 2021/08/07.
//

import Foundation

extension Promise {
    @inlinable public static func async(on queue: DispatchQueue, _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            queue.async { handler(resolve, reject) }
        }
    }
    @inlinable public static func asyncError(on queue: DispatchQueue, _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) -> Promise<Output, Failure> where Failure == Error {
        Promise<Output, Failure> { resolve, reject in
            queue.async { do { try handler(resolve, reject) } catch { reject(error) } }
        }
    }
    
    @inlinable public func receive(on queue: DispatchQueue) -> Promise<Output, Failure> {
        Promise<Output, Failure>{ resolve, reject in
            self.sink({ o in queue.async { resolve(o) } }, { f in queue.async { reject(f) } })
        }
    }
}

extension DispatchQueue {
    public static let promiseDefault = DispatchQueue(label: "async.queue")
}

@discardableResult
@inlinable public func asyncHandler<Output>(on queue: DispatchQueue = .promiseDefault, _ block: @escaping (Await) -> Output) -> Promise<Output, Never> {
    Promise<Output, Never>{ resolve, _ in
        queue.async { resolve(block(Await())) }
    }
}

@discardableResult
@inlinable public func asyncHandler<Output>(on queue: DispatchQueue = .promiseDefault, _ block: @escaping (Await) throws -> Output) -> Promise<Output, Error> {
    Promise<Output, Error>{ resolve, reject in
        queue.async { do { resolve(try block(Await())) } catch { reject(error) } }
    }
}

final public class Await {
    @inlinable static public func | <T, Failure>(await: Await, promise: Promise<T, Failure>) throws -> T {
        try await.execute(promise: promise)
    }
    
    @usableFromInline init() {}

    @inlinable static public func | <T>(await: Await, promise: Promise<T, Never>) -> T {
        await.execute(promise: promise)
    }
        
    @inlinable public func execute<Output>(promise: Promise<Output, Never>) -> Output {
        let semaphore = DispatchSemaphore(value: 0)
        var output: Output?
        promise.sink{ output = $0; semaphore.signal() }
        semaphore.wait()
        return output!
    }
    
    @inlinable public func execute<Output, Failure>(promise: Promise<Output, Failure>) throws -> Output {
        let semaphore = DispatchSemaphore(value: 0)
        var output: Output?
        var error: Error?
        promise.sink({ output = $0; semaphore.signal() }, { error = $0; semaphore.signal() })
        semaphore.wait()
        if let error = error { throw error }
        return output!
    }
}
