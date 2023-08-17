//
//  File.swift
//  
//
//  Created by yuki on 2023/06/28.
//

#if canImport(Foundation)
import Foundation

@usableFromInline struct Lock {
    @usableFromInline static let attr: UnsafePointer<pthread_mutexattr_t> = {
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        _do(pthread_mutexattr_init(attr), "pthread_mutexattr_init")
        _do(pthread_mutexattr_settype(attr, PTHREAD_MUTEX_ERRORCHECK), "pthread_mutexattr_settype")
        return UnsafePointer(attr)
    }()

    @usableFromInline var mutex = pthread_mutex_t()
    
    @inlinable @inline(__always)
    init() {
        #if DEBUG
        _do(pthread_mutex_init(&mutex, Lock.attr), "pthread_mutex_init")
        #else
        _do(pthread_mutex_init(&mutex, nil), "pthread_mutex_init")
        #endif
    }
    
    @inlinable @inline(__always)
    mutating func lock() {
        _do(pthread_mutex_lock(&mutex), "pthread_mutex_lock")
    }
    
    @inlinable @inline(__always)
    mutating func unlock() {
        _do(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock")
    }
}

@usableFromInline struct RecursiveLock {
    @usableFromInline static let attr = {
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        _do(pthread_mutexattr_init(attr), "pthread_mutexattr_init")
        _do(pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE), "pthread_mutexattr_settype")
        #if DEBUG
        _do(pthread_mutexattr_settype(attr, PTHREAD_MUTEX_ERRORCHECK), "pthread_mutexattr_settype")
        #endif
        return UnsafePointer(attr)
    }()
    
    @usableFromInline var mutex = pthread_mutex_t()
    
    @inlinable @inline(__always)
    init() {
        _do(pthread_mutex_init(&mutex, RecursiveLock.attr), "pthread_mutex_init")
    }
    
    @inlinable @inline(__always)
    mutating func lock() {
        _do(pthread_mutex_lock(&mutex), "pthread_mutex_lock")
    }
    
    @inlinable @inline(__always)
    mutating func unlock() {
        _do(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock")
    }
}

@inlinable @_transparent
func _do(_ res: Int32, _ funcname: @autoclosure () -> StaticString) {
    if res == 0 { return }
    let message = String(utf8String: strerror(res)) ?? ""
    fatalError("\(funcname()) failed: \(message)")
}

#else

#error("Unsuppowrted platform")

#endif
