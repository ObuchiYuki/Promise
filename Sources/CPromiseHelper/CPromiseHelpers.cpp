//
//  CPromiseHelpers.cpp
//  
//
//  Created by yuki on 2023/06/04.
//

#include "CPromiseHelpers.hpp"

#include <mutex>

#if __has_include(<pthread.h>)
#  include <pthread.h>
#  define USE_PTHREAD_AS_LOCK
#endif

#if __has_include(<signal.h>)
#  include <signal.h>
#  define PROMISE_HAS_SIGNAL_HANDLING
#endif

#ifdef _WIN32
#  include <windows.h>
#endif


#define PROMISE_HANDLE_EXCEPTION_BEGIN try {
#define PROMISE_HANDLE_EXCEPTION_END } catch (...) { std::terminate(); }

#define PROMISE_STRINGIFY(value) #value
#define PROMISE_STRINGIFY_(value) PROMISE_STRINGIFY(value)
#define PROMISE_STRING_LINE_NUMBER PROMISE_STRINGIFY_(__LINE__)

#define PROMISE_HANDLE_PTHREAD_CALL(errc) \
    if ((errc) != 0) { \
        const char* what = __FILE__ ":" PROMISE_STRING_LINE_NUMBER ": " #errc; \
        throw std::system_error((errc), std::system_category(), what); \
    }

#ifdef USE_PTHREAD_AS_LOCK // pthread as lock

void* _Nonnull promise_recursive_lock_alloc(void) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    pthread_mutexattr_t attrs;
    pthread_mutexattr_init(&attrs);
    
    
    
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutexattr_settype(&attrs, PTHREAD_MUTEX_RECURSIVE));

    auto mutex = new pthread_mutex_t();
    
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_init(mutex, &attrs));
    
    pthread_mutexattr_destroy(&attrs);
    
    return mutex;
    
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_recursive_lock_lock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = static_cast<pthread_mutex_t*>(self);
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_lock(mutex));
    
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_recursive_lock_unlock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = static_cast<pthread_mutex_t*>(self);
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_unlock(mutex));
    
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_recursive_lock_dealloc(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = static_cast<pthread_mutex_t*>(self);
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_destroy(mutex));
    delete mutex;
    
    PROMISE_HANDLE_EXCEPTION_END
}

void* _Nonnull promise_lock_alloc(void) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = new pthread_mutex_t();
    
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_init(mutex, nullptr));
    
    return mutex;
    
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_lock_lock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = static_cast<pthread_mutex_t*>(self);
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_lock(mutex));
    
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_lock_unlock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = static_cast<pthread_mutex_t*>(self);
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_unlock(mutex));
    
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_lock_dealloc(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    
    auto mutex = static_cast<pthread_mutex_t*>(self);
    PROMISE_HANDLE_PTHREAD_CALL(pthread_mutex_destroy(mutex));
    delete mutex;
    
    PROMISE_HANDLE_EXCEPTION_END
}


#else // std::mutex as lock

void* _Nonnull promise_recursive_lock_alloc(void) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    return new std::recursive_mutex();
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_recursive_lock_lock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    static_cast<std::recursive_mutex*>(self)->lock();
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_recursive_lock_unlock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    static_cast<std::recursive_mutex*>(self)->unlock();
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_recursive_lock_dealloc(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    delete static_cast<std::recursive_mutex*>(self);
    PROMISE_HANDLE_EXCEPTION_END
}

#endif

void promise_stop_in_debugger(void) {
#if _WIN32
    DebugBreak();
#elifdef PROMISE_HAS_SIGNAL_HANDLING
    raise(SIGTRAP);
#endif
}
