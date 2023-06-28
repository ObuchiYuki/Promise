//
//  CPromiseHelpers.cpp
//  
//
//  Created by yuki on 2023/06/04.
//

#include "CPromiseHelpers.hpp"

#include <mutex>

#if __has_include(<signal.h>)
#  include <signal.h>
#  define PROMISE_HAS_SIGNAL_HANDLING 1
#else
#  define PROMISE_HAS_SIGNAL_HANDLING 0
#endif

#ifdef _WIN32
#  include <windows.h>
#endif

#define PROMISE_HANDLE_EXCEPTION_BEGIN try {

#define PROMISE_HANDLE_EXCEPTION_END } catch (...) { std::terminate(); }

void* _Nonnull promise_lock_alloc(void) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    return new std::recursive_mutex();
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_lock_lock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    static_cast<std::recursive_mutex*>(self)->lock();
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_lock_unlock(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    static_cast<std::recursive_mutex*>(self)->unlock();
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_lock_dealloc(void* _Nonnull self) {
    PROMISE_HANDLE_EXCEPTION_BEGIN
    delete static_cast<std::recursive_mutex*>(self);
    PROMISE_HANDLE_EXCEPTION_END
}

void promise_stop_in_debugger(void) {
#if _WIN32
    DebugBreak();
#elif PROMISE_HAS_SIGNAL_HANDLING
    raise(SIGTRAP);
#endif
}
