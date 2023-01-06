//
//  Promise+Settle.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    public func get() -> Promise<Result<Output, Failure>, Never> {
        Promise<Result<Output, Failure>, Never>{ resolve, reject in
            self.subscribe({ resolve(.success($0)) }, { resolve(.failure($0)) })
        }
    }
}

extension Promise.State {
    public var isSettled: Bool {
        if case .pending = self { return true }
        return false
    }
}

