using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;
using System;
using System.Reflection;

[ExtendLuaClass(typeof(GameEventMgr))]
public class GameEventMgrManualWrap : LuaObject {
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
        addMember(l, GetAllEvents);
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetAllEvents(IntPtr l) {
        try {
            GameEventMgr g_e_m;
            checkType(l, 1, out g_e_m);
            pushValue(l, true);
            var all_events = g_e_m.GetAllEvents();
            LuaDLL.lua_newtable(l);
            for(int i = 0; i < all_events.Length; ++i) {
                var evt = all_events[i];
                LuaDLL.lua_newtable(l);
                pushValue(l, evt.event_type_);
                LuaDLL.lua_setfield(l, -2, "event_type");
                pushValue(l, evt.event_tag_);
                LuaDLL.lua_setfield(l, -2, "event_tag");
                int cnt = 0;
                if (evt.params_ != null) {
                    foreach(object obj in evt.params_) {
                        ++cnt;
                        pushValue(l, obj);
                        LuaDLL.lua_rawseti(l, -2, cnt);
                    }
                }
                pushValue(l, cnt);
                LuaDLL.lua_setfield(l, -2, "n");
                LuaDLL.lua_rawseti(l, -2, i + 1);
            }
            return 2;
        } catch(Exception e) {
            return error(l,e);
        }
    }
}
