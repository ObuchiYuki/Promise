//
//  Promise+GCD.swift
//  Promise
//
//  Created by yuki on 2021/08/07.
//

#if canImport(Foundation)
import Foundation

extension Promise where Output: Sendable {
    @inlinable
    public static func dispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ handler: @Sendable @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        queue.async { handler(promise.resolve, promise.reject) }
        return promise
    }
    
    @inlinable
    public static func dispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ output: @Sendable @escaping () -> Output) -> Promise<Output, Failure> where Failure == Never {
        let promise = Promise<Output, Failure>()
        queue.async { promise.resolve(output()) }
        return promise
    }
        
    @inlinable
    public static func tryDispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ handler: @Sendable @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        queue.async { do { try handler(promise.resolve, promise.reject) } catch { promise.reject(error) } }
        return promise
    }
    
    @inlinable
    public static func tryDispatch(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ output: @Sendable @escaping () throws -> Output) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        queue.async { do { promise.resolve(try output()) } catch { promise.reject(error) } }
        return promise
    }
    
    @inlinable
    public func receive(on queue: DispatchQueue) -> Promise<Output, Failure> {
        self.receive(on: { queue.async(execute: $0) })
    }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
extension Promise {
    @inlinable
    public static func dispatchUnsafe(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ handler: @Sendable @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        queue.asyncUnsafe { handler(promise.resolve, promise.reject) }
        return promise
    }
    
    @inlinable
    public static func dispatchUnsafe(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ output: @Sendable @escaping () -> Output) -> Promise<Output, Failure> where Failure == Never {
        let promise = Promise<Output, Failure>()
        queue.asyncUnsafe { promise.resolve(output()) }
        return promise
    }
        
    @inlinable
    public static func tryDispatchUnsafe(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ handler: @Sendable @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        queue.asyncUnsafe { do { try handler(promise.resolve, promise.reject) } catch { promise.reject(error) } }
        return promise
    }
    
    @inlinable
    public static func tryDispatchUnsafe(on queue: DispatchQueue = .global(), @_implicitSelfCapture _ output: @Sendable @escaping () throws -> Output) -> Promise<Output, Failure> where Failure == Error {
        let promise = Promise<Output, Failure>()
        queue.asyncUnsafe { do { promise.resolve(try output()) } catch { promise.reject(error) } }
        return promise
    }
    
    @inlinable
    public func receiveUnsafe(on queue: DispatchQueue) -> Promise<Output, Failure> {
        self.receiveUnsafe(on: { queue.asyncUnsafe(execute: $0) })
    }
}


#endif
