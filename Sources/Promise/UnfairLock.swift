//
//  File.swift
//  
//
//  Created by yuki on 2023/06/28.
//

#if canImport(Darwin)
import Darwin // for macOS, iOS, tvOS, watchOS
#elseif canImport(Glibc)
import Glibc // for Linux
#else
#error("Unsupported platform")
#endif

@usableFromInline struct Lock {
    #if DEBUG
    @usableFromInline static let attr: UnsafePointer<pthread_mutexattr_t> = {
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_init(attr), "pthread_mutexattr_init")
        return UnsafePointer(attr)
    }()
    #endif

    @usableFromInline var mutex = pthread_mutex_t()
    
    @inlinable @inline(__always) 
    init() {
        #if DEBUG
        _HANDLE_PTHREAD_CALL(pthread_mutex_init(&mutex, Lock.attr), "pthread_mutex_init")
        #else
        _HANDLE_PTHREAD_CALL(pthread_mutex_init(&mutex, nil), "pthread_mutex_init")
        #endif
    }
    
    @inlinable @inline(__always)
    mutating func lock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_lock(&mutex), "pthread_mutex_lock")
    }
    
    @inlinable @inline(__always)
    mutating func unlock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock")
    }
}

@usableFromInline struct RecursiveLock {
    @usableFromInline static let attr = {
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_init(attr), "pthread_mutexattr_init")
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE), "pthread_mutexattr_settype")
        return UnsafePointer(attr)
    }()
    
    @usableFromInline var mutex = pthread_mutex_t()
    
    @inlinable @inline(__always)
    init() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_init(&mutex, RecursiveLock.attr), "pthread_mutex_init")
    }
    
    @inlinable @inline(__always)
    mutating func lock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_lock(&mutex), "pthread_mutex_lock")
    }
    
    @inlinable @inline(__always)
    mutating func unlock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock")
    }
}

@inlinable @inline(__always) @_transparent
func _HANDLE_PTHREAD_CALL(_ res: Int32, _ funcname: @autoclosure () -> StaticString) {
    #if DEBUG
    if res != 0 {
        fatalError("\(funcname()) failed: \(String(validatingUTF8: strerror(res)) ?? "Unkown Error")")
    }
    #endif
}
