//
//  Promise+Init.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    public convenience init(_ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) {
        self.init()
        handler(self.fulfill, self.reject)
    }
    public convenience init(_ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) where Failure == Error {
        self.init()
        do { try handler(self.fulfill, self.reject) } catch { self.reject(error) }
    }
    
    public static func resolve(_ output: Output) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        promise.fulfill(output)
        return promise
    }

    public static func resolve() -> Promise<Void, Failure> where Output == Void {
        let promise = Promise<Output, Failure>()
        promise.fulfill(())
        return promise
    }
    
    public static func reject(_ failure: Failure) -> Promise<Output, Failure> {
        let promise = Promise<Output, Failure>()
        promise.reject(failure)
        return promise
    }
    
    public static func resolve(_ output: () throws -> Output) -> Promise<Output, Error> where Failure == Error {
        let promise = Promise<Output, Failure>()
        do {
            promise.fulfill(try output())
        } catch {
            promise.reject(error)
        }
        return promise
    }
}

