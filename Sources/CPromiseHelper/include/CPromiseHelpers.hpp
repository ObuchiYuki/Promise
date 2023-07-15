//
//  CPromiseHelper.h
//
//
//  Created by Sergej Jaskiewicz on 23/09/2019.
//

#ifndef CPROMISEHELPER_HPP
#define CPROMISEHELPER_HPP

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark - Lock

void* _Nonnull promise_lock_alloc(void);

void promise_lock_lock(void* _Nonnull self);

void promise_lock_unlock(void* _Nonnull self);

void promise_lock_dealloc(void* _Nonnull self);

#pragma mark - RecursiveLock

void* _Nonnull promise_recursive_lock_alloc(void);

void promise_recursive_lock_lock(void* _Nonnull self);

void promise_recursive_lock_unlock(void* _Nonnull self);

void promise_recursive_lock_dealloc(void* _Nonnull self);


#pragma mark - Breakpoint

__attribute__((swift_name("__stopInDebugger()")))
void promise_stop_in_debugger(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* CPROMISEHELPER_HPP */
