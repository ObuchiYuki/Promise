//
//  Promise+Settle.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise {
    @inlinable
    public var result: Result<Output, Failure>? {
        if case .fulfilled(let output) = self._state {
            return .success(output)
        }
        if case .rejected(let failure) = self._state {
            return .failure(failure)
        }
        return nil
    }
    
    @inlinable
    public var isSettled: Bool {
        if case .pending = self._state { return false }
        return true
    }
}
