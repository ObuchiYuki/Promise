//
//  File.swift
//  
//
//  Created by yuki on 2023/06/28.
//

import CPromiseHelper

@usableFromInline final class Lock {
    @usableFromInline let opaque: UnsafeMutableRawPointer
    
    @inlinable @inline(__always)
    init() { self.opaque = promise_lock_alloc() }
    
    @inlinable @inline(__always)
    func lock() { promise_lock_lock(opaque) }
    
    @inlinable @inline(__always)
    func unlock() { promise_lock_unlock(opaque) }
    
    @inlinable @inline(__always)
    deinit { promise_lock_dealloc(opaque) }
}


@usableFromInline final class RecursiveLock {
    @usableFromInline let opaque: UnsafeMutableRawPointer
    
    @inlinable @inline(__always)
    init() { self.opaque = promise_recursive_lock_alloc() }
    
    @inlinable @inline(__always)
    func lock() { promise_recursive_lock_lock(opaque) }
    
    @inlinable @inline(__always)
    func unlock() { promise_recursive_lock_unlock(opaque) }
    
    @inlinable @inline(__always)
    deinit { promise_recursive_lock_dealloc(opaque) }
}
