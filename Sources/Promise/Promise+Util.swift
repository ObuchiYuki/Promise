//
//  Promise+Settle.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    public var result: Result<Output, Failure>? {
        if case .fulfilled(let output) = self.state {
            return .success(output)
        }
        if case .rejected(let failure) = self.state {
            return .failure(failure)
        }
        return nil
    }
    
    public var isSettled: Bool {
        if case .pending = self.state { return true }
        return false
    }
}
