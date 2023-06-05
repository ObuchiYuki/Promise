//
//  Header.h
//  
//
//  Created by yuki on 2023/06/04.
//

#ifndef Header_h
#define Header_h

#include <stdint.h>

#if __has_attribute(swift_name)
# define ALIAS_TO_SWIFT(_name) __attribute__((swift_name(#_name)))
#else
# define ALIAS_TO_SWIFT(_name)
#endif

#ifdef __cplusplus
extern "C" {
#endif

void __promise_stop_in_debugger(void) ALIAS_TO_SWIFT(__stopInDebugger());

#ifdef __cplusplus
} // extern "C"
#endif

#endif /* Header_h */
