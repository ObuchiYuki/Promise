//
//  Promise+Async.swift
//
//
//  Created by yuki on 2021/08/07.
//

#if canImport(Foundation)
import Foundation

extension Promise {
    @inlinable @_transparent
    public static func dispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        queue.async { handler(promise.resolve, promise.reject) }
        return promise
    }
    
    @inlinable @_transparent
    public static func dispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ output: @escaping () -> Output) -> Promise<Output, Failure> where Failure == Never {
        let promise = Promise<Output, Failure>()
        queue.async { promise.resolve(output()) }
        return promise
    }
        
    @inlinable @_transparent
    public static func tryDispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        queue.async { do { try handler(promise.resolve, promise.reject) } catch { promise.reject(error) } }
        return promise
    }
    
    @inlinable @_transparent
    public static func tryDispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ output: @escaping () throws -> Output) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        queue.async { do { promise.resolve(try output()) } catch { promise.reject(error) } }
        return promise
    }
    
    @inlinable @_transparent
    public func receive(on queue: DispatchQueue) -> Promise<Output, Failure> {
        self.receive(on: { queue.async(execute: $0) })
    }
}
#endif
