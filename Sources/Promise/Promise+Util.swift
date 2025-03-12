//
//  Promise+Settle.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    @inlinable
    public var result: Result<Output, Failure>? {
        let state = self.state
        if case .fulfilled(let output) = state {
            return .success(output)
        }
        if case .rejected(let failure) = state {
            return .failure(failure)
        }
        return nil
    }
    
    @inlinable
    public var isSettled: Bool {
        if case .pending = self.state { return false }
        return true
    }
}
