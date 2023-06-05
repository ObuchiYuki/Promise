//
//  CPromiseHelpers.cpp.cpp
//  
//
//  Created by yuki on 2023/06/04.
//

#include "CPromiseHelpers.hpp"

#if __has_include(<signal.h>)
#  include <signal.h>
#  define PROMISE_HAS_SIGNAL_HANDLING 1
#else
#  define PROMISE_HAS_SIGNAL_HANDLING 0
#endif

#ifdef _WIN32
#  include <windows.h>
#endif

#include <iostream>

void __promise_stop_in_debugger() {
#if _WIN32
    DebugBreak();
#elif PROMISE_HAS_SIGNAL_HANDLING
    raise(SIGTRAP);
#endif
}
