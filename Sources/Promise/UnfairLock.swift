//
//  File.swift
//  
//
//  Created by yuki on 2023/06/28.
//

import CPromiseHelper

final class UnfairLock {
    private let opaque = promise_lock_alloc()
    
    func lock() { promise_lock_lock(opaque) }
    func unlock() { promise_lock_unlock(opaque) }

    deinit { promise_lock_dealloc(opaque) }
}
