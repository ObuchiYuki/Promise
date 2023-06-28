//
//  CPromiseHelper.h
//
//
//  Created by Sergej Jaskiewicz on 23/09/2019.
//

#ifndef CPROMISEHELPER_HPP
#define CPROMISEHELPER_HPP

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark - PromiseUnfairLock

void* _Nonnull promise_lock_alloc(void);

void promise_lock_lock(void* _Nonnull self);

void promise_lock_unlock(void* _Nonnull self);

void promise_lock_dealloc(void* _Nonnull self);


#pragma mark - Breakpoint

__attribute__((swift_name("__stopInDebugger()")))
void promise_stop_in_debugger(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* CPROMISEHELPER_HPP */
