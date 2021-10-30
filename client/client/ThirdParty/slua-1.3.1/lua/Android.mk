LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := lua
LOCAL_SRC_FILES := ./src/lapi.c ./src/lcode.c ./src/lctype.c ./src/ldebug.c ./src/ldo.c ./src/ldump.c ./src/lfunc.c ./src/lgc.c ./src/llex.c ./src/lmem.c ./src/lobject.c ./src/lopcodes.c ./src/lparser.c ./src/lstate.c ./src/lstring.c ./src/ltable.c ./src/ltm.c ./src/lundump.c ./src/lvm.c ./src/lzio.c ./src/lauxlib.c ./src/lbaselib.c ./src/lbitlib.c ./src/lcorolib.c ./src/ldblib.c ./src/liolib.c ./src/lmathlib.c ./src/loslib.c ./src/lstrlib.c ./src/ltablib.c ./src/lutf8lib.c ./src/loadlib.c ./src/linit.c ./src/lua.c

# Auxiliary lua user defined file
# LOCAL_SRC_FILES += luauser.c
# LOCAL_CFLAGS := -DLUA_DL_DLOPEN -DLUA_USER_H='"luauser.h"'  -DLUA_USE_C89

LOCAL_CFLAGS := -DLUA_DL_DLOPEN
LOCAL_CFLAGS += -Dlog2\(x\)=\(log\(x\)*1.4426950408889634\)
# LOCAL_CFLAGS += -DLUA_USE_C89
LOCAL_CFLAGS += -DLUA_COMPAT_APIINTCASTS
# LOCAL_LDLIBS += -L$(SYSROOT)/usr/lib -llog -ldl
LOCAL_CFLAGS += -pie -fPIC
LOCAL_CFLAGS += -DMK_ANDROID
LOCAL_CFLAGS += -DLUA_COMPAT_MODULE

include $(BUILD_STATIC_LIBRARY)