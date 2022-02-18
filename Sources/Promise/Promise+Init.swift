//
//  Promise+Init.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    public convenience init(_ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) -> ()) {
        self.init()
        handler(self.fullfill, self.reject)
    }
    public convenience init(_ handler: (@escaping (Output) -> (), @escaping (Failure) -> ()) throws -> ()) where Failure == Error {
        self.init()
        do { try handler(self.fullfill, self.reject) } catch { self.reject(error) }
    }
    
    public convenience init(output: Output) {
        self.init()
        self.fullfill(output)
    }
    
    public convenience init(failure: Failure) {
        self.init()
        self.reject(failure)
    }
    
    public convenience init(output: () throws -> Output) where Failure == Error {
        self.init()
        do { self.fullfill(try output()) } catch { self.reject(error) }
    }
}

