//
//  Promise+Init.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    @inlinable
    public convenience init(@_implicitSelfCapture _ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) {
        self.init()
        handler(self.resolve, self.reject)
    }
    
    @inlinable
    public convenience init(@_implicitSelfCapture _ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) where Failure == Error {
        self.init()
        do { try handler(self.resolve, self.reject) } catch { self.reject(error) }
    }
    
    @inlinable
    public convenience init(_ promise: Promise<Output, Failure>) {
        self.init()
        promise.subscribe(self.resolve(_:), self.reject(_:))
    }
    
    @inlinable
    public static func resolve(_ output: Output) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        promise.resolve(output)
        return promise
    }

    @inlinable
    public static func resolve() -> Promise<Void, Failure> where Output == Void {
        let promise = Promise<Output, Failure>()
        promise.resolve(())
        return promise
    }
    
    @inlinable
    public static func reject(_ failure: Failure) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        promise.reject(failure)
        return promise
    }
    
    @inlinable
    public static func resolve(_ output: () throws -> Output) -> Promise<Output, Error> where Failure == Error {
        let promise = Promise<Output, Failure>()
        do {
            promise.resolve(try output())
        } catch {
            promise.reject(error)
        }
        return promise
    }
}

