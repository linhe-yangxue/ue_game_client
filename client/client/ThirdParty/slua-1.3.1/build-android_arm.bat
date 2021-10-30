md android\armeabi-v7a
md android\x86
md android\arm64-v8a
md android\x86_64

cd lua
rem call ndk-build clean NDK_PROJECT_PATH=.\ NDK_APPLICATION_MK=Application.mk NDK_OUT=.\android
call ndk-build NDK_PROJECT_PATH=.\ NDK_APPLICATION_MK=Application.mk NDK_OUT=.\android

copy android\local\armeabi-v7a\liblua.a ..\android\armeabi-v7a\liblua.a
copy android\local\x86\liblua.a ..\android\x86\liblua.a
copy android\local\arm64-v8a\liblua.a ..\android\arm64-v8a\liblua.a
copy android\local\x86_64\liblua.a ..\android\x86_64\liblua.a

rem call ndk-build clean NDK_PROJECT_PATH=.\ NDK_APPLICATION_MK=Application.mk NDK_OUT=.\android

cd ..

rem call ndk-build clean NDK_PROJECT_PATH=.\ NDK_APPLICATION_MK=Application.mk NDK_OUT=.\android\armv7-a
call ndk-build NDK_PROJECT_PATH=.\ NDK_APPLICATION_MK=Application.mk NDK_OUT=.\android\armv7-a

@XCOPY /s /e /h /c /y android\armv7-a\local android\result\ >nul
rem call ndk-build clean NDK_PROJECT_PATH=.\ NDK_APPLICATION_MK=Application.mk NDK_OUT=.\android\armv7-a
