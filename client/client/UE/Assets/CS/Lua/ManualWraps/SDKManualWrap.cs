using System;
using UnityEngine;
using SLua;
using Object = UnityEngine.Object;

[ExtendLuaClass(typeof(SDK))]
public class SDKManualWrap : LuaObject {
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
#if UNITY_IOS
        addMember(l, EchoTest_s);
        addMember(l, SetClipboard_s);
        addMember(l, GetClipboard_s);
        addMember(l, GetBatteryState_s);
        addMember(l, GaeaInit_s);
        addMember(l, GaeaLogin_s);
        addMember(l, GaeaPay_s);
        addMember(l, GaeaUserCenter_s);
        addMember(l, GaeaForum_s);
        addMember(l, GaeaService_s);
        addMember(l, GataInit_s);
        addMember(l, GataLogEvent1_s);
        addMember(l, GataLogEvent2_s);
        addMember(l, GataLogEvent3_s);
        addMember(l, GataUserLogin_s);
        addMember(l, GataRoleCreate_s);
        addMember(l, GataRoleLogin_s);
        addMember(l, GataRoleLogout_s);
        addMember(l, GataSetLevel_s);
        addMember(l, GataSetCrashReportingEnabled_s);
        addMember(l, GataLogError_s);
        addMember(l, GataLogLocation_s);
        addMember(l, GataGetDeviceInfo_s);
#endif
    }

#if UNITY_IOS
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int EchoTest_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            var ret = SDK.EchoTest(a1);
            pushValue(l, true);
            pushValue(l, ret);
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int SetClipboard_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.SetClipboard(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetClipboard_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            var ret = SDK.GetClipboard(a1);
            pushValue(l, true);
            pushValue(l, ret);
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetBatteryState_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            var ret = SDK.GetBatteryState(a1);
            pushValue(l, true);
            pushValue(l, ret);
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GaeaInit_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GaeaInit(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GaeaLogin_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GaeaLogin(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GaeaPay_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GaeaPay(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GaeaUserCenter_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GaeaUserCenter(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GaeaForum_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GaeaForum(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GaeaService_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GaeaService(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataInit_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataInit(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataLogEvent1_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataLogEvent1(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataLogEvent2_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataLogEvent2(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataLogEvent3_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataLogEvent3(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataUserLogin_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataUserLogin(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataRoleCreate_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataRoleCreate(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataRoleLogin_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataRoleLogin(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataRoleLogout_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataRoleLogout(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataSetLevel_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataSetLevel(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataSetCrashReportingEnabled_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataSetCrashReportingEnabled(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataLogError_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataLogError(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataLogLocation_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            SDK.GataLogLocation(a1);
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GataGetDeviceInfo_s(IntPtr l) {
        try {
            System.String a1;
            checkType(l, 1, out a1);
            var ret = SDK.GataGetDeviceInfo(a1);
            pushValue(l, true);
            pushValue(l, ret);
            return 2;
        } catch (Exception e) {
            return error(l, e);
        }
    }

#endif

}
