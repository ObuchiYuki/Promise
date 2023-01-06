//
//  Promise+Settle.swift
//  
//
//  Created by yuki on 2021/10/28.
//

extension Promise.State {
    public var isSettled: Bool {
        if case .pending = self { return true }
        return false
    }
}

