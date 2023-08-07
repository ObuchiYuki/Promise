//
//  Promise+Async.swift
//
//
//  Created by yuki on 2021/08/07.
//

#if canImport(Foundation)
import Foundation

extension Promise {
    public static func dispatch(on queue: DispatchQueue = .global(), _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) -> Promise<Output, Failure> {
        Promise<Output, Failure> { resolve, reject in
            queue.async { handler(resolve, reject) }
        }
    }
    
    public static func dispatch(on queue: DispatchQueue = .global(), _ output: @escaping () -> Output) -> Promise<Output, Failure> where Failure == Never {
        Promise<Output, Never> { resolve, _ in
            queue.async { resolve(output()) }
        }
    }
        
    public static func tryDispatch(on queue: DispatchQueue = .global(), _ handler: @escaping (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) -> Promise<Output, Failure> where Failure == Error {
        Promise<Output, Failure> { resolve, reject in
            queue.async { do { try handler(resolve, reject) } catch { reject(error) } }
        }
    }
    
    public static func tryDispatch(on queue: DispatchQueue = .global(), _ output: @escaping () throws -> Output) -> Promise<Output, Failure> where Failure == Error {
        Promise<Output, Failure> { resolve, reject in
            queue.async { do { resolve(try output()) } catch { reject(error) } }
        }
    }
    
    public func receive(on queue: DispatchQueue) -> Promise<Output, Failure> {
        self.receive(on: { queue.async(execute: $0) })
    }
}
#endif
