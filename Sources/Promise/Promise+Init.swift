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
    
    public convenience init(output: Output) {
        self.init()
        self.fulfill(output)
    }
    
    public convenience init(failure: Failure) {
        self.init()
        self.reject(failure)
    }
    
    public convenience init(output: () throws -> Output) where Failure == Error {
        self.init()
        do { self.fulfill(try output()) } catch { self.reject(error) }
    }
    
    public static func fulfill(_ output: Output) -> Promise<Output, Failure> {
        .init(output: output)
    }
    
    public static func fulfill() -> Promise<Void, Failure> where Output == Void {
        .init(output: ())
    }
    
    public static func reject(_ failure: Failure) -> Promise<Void, Failure> where Output == Void {
        .init(failure: failure)
    }
}

