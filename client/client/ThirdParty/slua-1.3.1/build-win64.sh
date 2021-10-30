#!/bin/bash
#
# Windows 32-bit/64-bit

# Copyright (C) polynation games ltd - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
# Written by Christopher Redden, December 2013

# 62 Bit Version
mkdir -p window/x86_64

cd lua
make clean

make mingw BUILDMODE=static CC="gcc -m64 -DLUA_COMPAT_MODULE"
cp src/liblua.a ../window/x86_64/liblua.a

# cd ../pbc/
# make clean
# make BUILDMODE=static CC="gcc -m64"
# cp build/libpbc.a ../window/x86_64/libpbc.a

# cd ../cjson/
# make clean
# make BUILDMODE=static CC="gcc -m64"
# cp build/libcjson.a ../window/x86_64/libcjson.a

cd ..

# zlib
cd ../zlib
gcc adler32.c crc32.c deflate.c infback.c inflate.c inftrees.c inffast.c trees.c zutil.c \
    -c -m64 -I.
ar rcs libz.a \
    ./*.o
cp libz.a ../slua-1.3.1/window/x86_64/libz.a
cd ../slua-1.3.1

gcc -c -m64 -O3 -std=c99 \
    slua.c \
    lua_log.c \
    sproto/*.c \
    lpeg/*.c \
    luasocket/src/auxiliar.c \
    luasocket/src/buffer.c \
    luasocket/src/except.c \
    luasocket/src/inet.c \
    luasocket/src/io.c \
    luasocket/src/luasocket.c \
    luasocket/src/mime.c \
    luasocket/src/options.c \
    luasocket/src/select.c \
    luasocket/src/tcp.c \
    luasocket/src/timeout.c \
    luasocket/src/udp.c \
    luasocket/src/wsocket.c \
    enet/callbacks.c\
    enet/compress.c\
    enet/host.c\
    enet/lenet.c\
    enet/list.c\
    enet/packet.c\
    enet/peer.c\
    enet/protocol.c\
    enet/win32.c\
    -D_WIN32 \
    -DHAS_INET_PTON \
    -DHAS_INET_NTOP \
    -DHAS_GETADDRINFO \
    -DLUASOCKET_INET_PTON \
    -DLUA_BUILD_AS_DLL \
    -DLUA_LIB \
    -DLUA_COMPAT_MODULE \
    -DLUA_COMPAT_APIINTCASTS \
    -Ilua/src/ \
    -Ilpeg/ \
    -I./ \
    -I../zlib \
    -Isproto \
    -Ienet \
    -Iluasocket/src

g++ -m64 -O3 \
    ./*.o \
    -o window/x86_64/slua.dll -m64 -shared \
    -Lwindow/x86_64 \
    -Wl,--whole-archive \
    window/x86_64/liblua.a \
    -Wl,--no-whole-archive \
    -lwsock32 -lwinmm -lws2_32 -lgdi32 -lz -static-libstdc++ -static-libgcc

rm -f *.o
#    -o window/x86_64/slua.dll -m64 -shared \
#    -Wl,--whole-archive \
#    window/x86_64/liblua.a \
#    -Wl,--no-whole-archive -lwsock32 -lwinmm -lws2_32 -static-libgcc -static-libstdc++ -std=c99
