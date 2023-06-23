//
//  Promise+Async.swift
//
//
//  Created by yuki on 2021/08/07.
//

#if canImport(Foundation)
import Foundation

extension Promise {
    public static func async(on queue: DispatchQueue = .global(), _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            queue.async { handler(resolve, reject) }
        }
    }
    
    public static func async(on queue: DispatchQueue = .global(), _ output: @escaping () -> (Output)) -> Promise<Output, Failure> where Failure == Never {
        Promise<Output, Never> { resolve, _ in
            queue.async { resolve(output()) }
        }
    }
    
    public static func tryAsync(on queue: DispatchQueue = .global(), _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) -> Promise<Output, Failure> where Failure == Error {
        Promise<Output, Failure> { resolve, reject in
            queue.async { do { try handler(resolve, reject) } catch { reject(error) } }
        }
    }
    
    public static func tryAsync(on queue: DispatchQueue = .global(), _ output: @escaping () throws -> (Output)) -> Promise<Output, Failure> where Failure == Error {
        Promise<Output, Failure> { resolve, reject in
            queue.async { do { resolve(try output()) } catch { reject(error) } }
        }
    }
    
    public func receive(on queue: DispatchQueue) -> Promise<Output, Failure> {
        self.receive(on: { queue.async(execute: $0) })
    }
}

@discardableResult
@inlinable public func asyncHandler<Output>(on queue: DispatchQueue = .global(), _ block: @escaping (Await) -> Output) -> Promise<Output, Never> {
    Promise<Output, Never>{ resolve, _ in
        queue.async { resolve(block(Await())) }
    }
}

@discardableResult
@inlinable public func asyncHandler<Output>(on queue: DispatchQueue = .global(), _ block: @escaping (Await) throws -> Output) -> Promise<Output, Error> {
    Promise<Output, Error>{ resolve, reject in
        queue.async { do { resolve(try block(Await())) } catch { reject(error) } }
    }
}

final public class Await {
    @usableFromInline init() {}
    
    static public func | <T, Failure>(await: Await, promise: Promise<T, Failure>) throws -> T {
        try `await`.execute(promise: promise)
    }

    static public func | <T>(await: Await, promise: Promise<T, Never>) -> T {
        `await`.execute(promise: promise)
    }
        
    public func execute<Output>(promise: Promise<Output, Never>) -> Output {
        let semaphore = DispatchSemaphore(value: 0)
        var output: Output?
        promise.sink{ output = $0; semaphore.signal() }
        semaphore.wait()
        return output!
    }
    
    public func execute<Output, Failure>(promise: Promise<Output, Failure>) throws -> Output {
        let semaphore = DispatchSemaphore(value: 0)
        var output: Output?
        var error: Error?
        promise.sink({ output = $0; semaphore.signal() }, { error = $0; semaphore.signal() })
        semaphore.wait()
        if let error = error { throw error }
        return output!
    }
}
#endif
