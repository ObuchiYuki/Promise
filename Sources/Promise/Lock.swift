//
//  Lock.swift
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

@usableFromInline final class Lock {
    #if DEBUG
    @usableFromInline static let attr: UnsafePointer<pthread_mutexattr_t> = {
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_init(attr), "pthread_mutexattr_init")
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_settype(attr, PTHREAD_MUTEX_ERRORCHECK), "pthread_mutexattr_settype")
        return UnsafePointer(attr)
    }()
    #endif

    @usableFromInline var mutex = pthread_mutex_t()
    
    @inlinable @inline(__always)
    init() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_init(&mutex, Lock.attr), "pthread_mutex_init")
    }
    
    @inlinable @inline(__always)
    deinit {
        _HANDLE_PTHREAD_CALL(pthread_mutex_destroy(&mutex), "pthread_mutex_destroy")
    }
    
    @inlinable @inline(__always)
    func lock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_lock(&mutex), "pthread_mutex_lock")
    }
    
    @inlinable @inline(__always)
    func unlock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock")
    }
}

@usableFromInline final class RecursiveLock {
    @usableFromInline static let attr = {
        let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_init(attr), "pthread_mutexattr_init")
        _HANDLE_PTHREAD_CALL(pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE), "pthread_mutexattr_settype")
        return UnsafePointer(attr)
    }()
    
    @usableFromInline var mutex: UnsafeMutablePointer<pthread_mutex_t>
    
    @inlinable @inline(__always)
    init() {
        self.mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        _HANDLE_PTHREAD_CALL(pthread_mutex_init(mutex, RecursiveLock.attr), "pthread_mutex_init")
    }
    
    @inlinable @inline(__always)
    deinit {
        _HANDLE_PTHREAD_CALL(pthread_mutex_destroy(mutex), "pthread_mutex_destroy")
    }
    
    @inlinable @inline(__always)
    func lock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_lock(mutex), "pthread_mutex_lock")
    }
    
    @inlinable @inline(__always)
    func unlock() {
        _HANDLE_PTHREAD_CALL(pthread_mutex_unlock(mutex), "pthread_mutex_unlock")
    }
}

/// The call is converted to a macro (`@_transparent`).
@inlinable @inline(__always) @_transparent
func _HANDLE_PTHREAD_CALL(_ res: Int32, _ funcname: @autoclosure () -> StaticString) {
    if res != 0 {
        fatalError("\(funcname()) failed: \(String(validatingUTF8: strerror(res)) ?? "Unkown Error")")
    }
}
