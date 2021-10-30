#include "lua_log.h"
#include <stdarg.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

lua_State* g_lua_state = 0;

char buffer[512];
/*
void debug_printf(char * fmt, ...) {
    if (g_lua_state == 0) {
        return;
    }
    memset(buffer, 0, 256);
    memset(buffer2, 0, 512);
    va_list argptr;
    int cnt;
    va_start(argptr, fmt);
    cnt = vsprintf(buffer, fmt, argptr);
    va_end(argptr);
    sprintf(buffer2, "print(%s)", buffer);
    luaL_dostring(g_lua_state, buffer2);
}
*/

LuaDllLogDelegate g_log_del = 0;

#if defined(_WIN32)
    #define MyEXPORT __declspec(dllexport)
#else
    #define MyEXPORT extern
#endif

void debug_printf(char * fmt, ...) {
    if (g_log_del == 0) {
        return;
    }
    memset(buffer, 0, 512);
    va_list argptr;
    int cnt;
    va_start(argptr, fmt);
    cnt = vsprintf(buffer, fmt, argptr);
    va_end(argptr);
    g_log_del(buffer);
}

MyEXPORT void SetDebugPrintFunc(LuaDllLogDelegate log_func) {
    g_log_del = log_func;
}

#ifdef __cplusplus
}
#endif
