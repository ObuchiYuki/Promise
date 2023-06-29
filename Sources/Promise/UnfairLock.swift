//
//  File.swift
//  
//
//  Created by yuki on 2023/06/28.
//

import CPromiseHelper

final class UnfairLock {
    let opaque: UnsafeMutableRawPointer
    
    @inline(__always)
    init() { self.opaque = promise_lock_alloc() }
    
    @inline(__always)
    func lock() { promise_lock_lock(opaque) }
    
    @inline(__always)
    func unlock() { promise_lock_unlock(opaque) }
    
    @inline(__always)
    deinit { promise_lock_dealloc(opaque) }
}
