#!/bin/bash

mkdir -p android/armeabi-v7a
mkdir -p android/x86
echo APP_BUILD_SCRIPT:=Android.mk >./Application.mk
echo APP_ABI:=armeabi-v7a x86 >>./Application.mk
echo APP_PLATFORM:=android-14 >>./Application.mk
echo APP_STL:=gnustl_static >> ./Application.mk

cd lua
ndk-build clean NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android
ndk-build NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android

cp android/local/armeabi-v7a/liblua.a ../android/armeabi-v7a/liblua.a
cp android/local/x86/liblua.a ../android/x86/liblua.a

ndk-build clean NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android

#cd ..

#cd mapmanager
#ndk-build clean NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android
#ndk-build NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android

#cp android/local/armeabi-v7a/libmapmanager.a ../android/armeabi-v7a/libmapmanager.a
#cp android/local/x86/libmapmanager.a ../android/x86/libmapmanager.a

cd ..

ndk-build clean NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android/armv7-a
ndk-build NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android/armv7-a

cp -r android/armv7-a/local android/result
ndk-build clean NDK_PROJECT_PATH=./ NDK_APPLICATION_MK=Application.mk NDK_OUT=./android/armv7-a

