//
//  File.swift
//  
//
//  Created by yuki on 2023/06/28.
//

import Darwin

@usableFromInline struct Lock {
    @usableFromInline var mutex: UnsafeMutablePointer<pthread_mutex_t>
    
    @inlinable @inline(__always)
    init() {
        self.mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1);
        guard pthread_mutex_init(mutex, nil) == 0 else {
            handleError("pthread_mutex_init")
        }
    }
    
    @inlinable @inline(__always)
    func lock() {
        guard pthread_mutex_lock(mutex) == 0 else { handleError("pthread_mutex_lock") }
    }
    
    @inlinable @inline(__always)
    func unlock() {
        guard pthread_mutex_unlock(mutex) == 0 else { handleError("pthread_mutex_unlock") }
    }
    
    @inlinable @inline(__always)
    func deallocate() {
        guard pthread_mutex_destroy(mutex) == 0 else { handleError("pthread_mutex_destroy") }
        mutex.deallocate()
    }
}

@usableFromInline struct RecursiveLock {
    @usableFromInline var mutex: UnsafeMutablePointer<pthread_mutex_t>
    
    @inlinable @inline(__always)
    init() {
        var attrs = pthread_mutexattr_t(); pthread_mutexattr_init(&attrs)
        guard pthread_mutexattr_settype(&attrs, PTHREAD_MUTEX_RECURSIVE) == 0 else {
            handleError("pthread_mutexattr_settype")
        }

        self.mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1);
        guard pthread_mutex_init(mutex, &attrs) == 0 else {
            handleError("pthread_mutex_init")
        }
        pthread_mutexattr_destroy(&attrs);
    }
    
    @inlinable @inline(__always)
    func lock() {
        guard pthread_mutex_lock(mutex) == 0 else { handleError("pthread_mutex_lock") }
    }
    
    @inlinable @inline(__always)
    func unlock() {
        guard pthread_mutex_unlock(mutex) == 0 else { handleError("pthread_mutex_unlock") }
    }
    
    @inlinable @inline(__always)
    func deallocate() {
        guard pthread_mutex_destroy(mutex) == 0 else { handleError("pthread_mutex_destroy") }
        mutex.deallocate()
    }
}

@inlinable
func handleError(_ funcname: @autoclosure () -> StaticString) -> Never {
    switch errno {
    case EAGAIN: fatalError("\(funcname()) failed: EAGAIN")
    case ENOMEM: fatalError("\(funcname()) failed: ENOMEM")
    case EPERM: fatalError("\(funcname()) failed: EPERM")
    case EBUSY: fatalError("\(funcname()) failed: EBUSY")
    case EINVAL: fatalError("\(funcname()) failed: EINVAL")
    case EDEADLK: fatalError("\(funcname()) failed: EDEADLK")
    default: fatalError("\(funcname()) failed")
    }
}
