LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := liblua
LOCAL_SRC_FILES := android/$(TARGET_ARCH_ABI)/liblua.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_MODULE := slua
LOCAL_C_INCLUDES := $(LOCAL_PATH)/lua/src
LOCAL_C_INCLUDES += $(LOCAL_PATH)/sproto
LOCAL_C_INCLUDES += $(LOCAL_PATH)/luasocket/src
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../zlib
LOCAL_C_INCLUDES += $(LOCAL_PATH)/enet
LOCAL_C_INCLUDES += $(LOCAL_PATH)/lpeg
LOCAL_C_INCLUDES += $(LOCAL_PATH)/

LOCAL_CPPFLAGS := -std=gnu++11

LOCAL_CFLAGS := -O3
# LOCAL_CFLAGS += -Dlog2\(x\)=\(log\(x\)*1.4426950408889634\)
LOCAL_CFLAGS += -ffast-math
LOCAL_CFLAGS += -DHAS_INET_PTON
LOCAL_CFLAGS += -DHAS_INET_NTOP
LOCAL_CFLAGS += -DLUA_LIB
LOCAL_CFLAGS += -DLUA_COMPAT_MODULE
LOCAL_CFLAGS += -DLUA_COMPAT_APIINTCASTS
LOCAL_CFLAGS += -DLUA_DL_DLOPEN
# LOCAL_CFLAGS += -DLUA_USE_C89
LOCAL_CFLAGS += -pie -fPIC
LOCAL_CFLAGS += -DMK_ANDROID

FILE_LIST := $(wildcard \
        $(LOCAL_PATH)/slua.c \
        $(LOCAL_PATH)/lua_log.c \
        $(LOCAL_PATH)/lpeg/*.c \
        $(LOCAL_PATH)/sproto/*.c \
        $(LOCAL_PATH)/luasocket/src/auxiliar.c \
        $(LOCAL_PATH)/luasocket/src/buffer.c \
        $(LOCAL_PATH)/luasocket/src/except.c \
        $(LOCAL_PATH)/luasocket/src/inet.c \
        $(LOCAL_PATH)/luasocket/src/io.c \
        $(LOCAL_PATH)/luasocket/src/luasocket.c \
        $(LOCAL_PATH)/luasocket/src/mime.c \
        $(LOCAL_PATH)/luasocket/src/options.c \
        $(LOCAL_PATH)/luasocket/src/select.c \
        $(LOCAL_PATH)/luasocket/src/tcp.c \
        $(LOCAL_PATH)/luasocket/src/timeout.c \
        $(LOCAL_PATH)/luasocket/src/udp.c \
        $(LOCAL_PATH)/luasocket/src/unix.c \
        $(LOCAL_PATH)/luasocket/src/usocket.c \
        $(LOCAL_PATH)/enet/callbacks.c \
        $(LOCAL_PATH)/enet/compress.c \
        $(LOCAL_PATH)/enet/host.c \
        $(LOCAL_PATH)/enet/lenet.c \
        $(LOCAL_PATH)/enet/list.c \
        $(LOCAL_PATH)/enet/packet.c \
        $(LOCAL_PATH)/enet/peer.c \
        $(LOCAL_PATH)/enet/protocol.c \
        $(LOCAL_PATH)/enet/unix.c \
        $(LOCAL_PATH)/../zlib/adler32.c \
        $(LOCAL_PATH)/../zlib/crc32.c \
        $(LOCAL_PATH)/../zlib/deflate.c \
        $(LOCAL_PATH)/../zlib/infback.c \
        $(LOCAL_PATH)/../zlib/inffast.c \
        $(LOCAL_PATH)/../zlib/inflate.c \
        $(LOCAL_PATH)/../zlib/inftrees.c \
        $(LOCAL_PATH)/../zlib/trees.c \
        $(LOCAL_PATH)/../zlib/zutil.c \
    )
LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%)

LOCAL_WHOLE_STATIC_LIBRARIES += liblua
include $(BUILD_SHARED_LIBRARY)