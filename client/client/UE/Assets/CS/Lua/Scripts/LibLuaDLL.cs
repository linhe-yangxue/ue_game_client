using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Runtime.InteropServices;
using System.Reflection;
using System.Text;
using System.Security;
using SLua;

public class LibLuaDLL {
    #if UNITY_IPHONE && !UNITY_EDITOR
    const string LUADLL = "__Internal";
    #else
    const string LUADLL = "slua";
    #endif

    private static bool _sIsInitedLuaLog = false;

    public static void DoInit() {
        SLua.LuaState.openLuaLibDelegate = OpenLuaLib;
        InitLuaDllLogFunc();
    }

    #if UNITY_EDITOR_WIN || UNITY_STANDALONE_WIN
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void LuaDllLogDelegate(string strs);
    #else
    public delegate void LuaDllLogDelegate(string strs);
    #endif

    [MonoPInvokeCallbackAttribute(typeof(LuaDllLogDelegate))]
    static void LuaDllLogStr(string strs) {
        UnityEngine.Debug.Log(strs);
    }

    public static void InitLuaDllLogFunc() {
        if (_sIsInitedLuaLog) {
            return;
        }
        _sIsInitedLuaLog = true;
        SetDebugPrintFunc(new LuaDllLogDelegate(LuaDllLogStr));
    }

    public static int OpenLuaLib(IntPtr L, string fileName) {
        if (string.IsNullOrEmpty(fileName))
        {
            return 0;
        }
        string func_name = "luaopen_" + fileName.Replace(".", "_");
        Type t = typeof(LibLuaDLL);
        MethodInfo md = t.GetMethod(func_name);
        if (md == null) {
            return 0;
        }
        int r = (int)md.Invoke(null, new object[] { L });
        return r;
    }

    [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int SetDebugPrintFunc(LuaDllLogDelegate LogFunc);

    [DllImport(LUADLL, CallingConvention=CallingConvention.Cdecl)]
    public static extern int luaopen_lpeg(IntPtr L);

    [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int luaopen_sproto_core(IntPtr L);

    [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int luaopen_enet(IntPtr L);

    [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern int luaopen_socket_core(IntPtr L);

	[DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
	public static extern int luaopen_mime_core(IntPtr L);

	[DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
	public static extern int luaopen_utf8(IntPtr L);
}
