
#ifndef L_LUALOG_H
#define L_LUALOG_H
#include <stdio.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#ifdef __cplusplus
extern "C" {
#endif

extern lua_State* g_lua_state;

void debug_printf(char * fmt, ...);

typedef void(*LuaDllLogDelegate)(char* strs);

void SetDebugPrintFunc(LuaDllLogDelegate log_func);

#ifdef __cplusplus
}
#endif
#endif