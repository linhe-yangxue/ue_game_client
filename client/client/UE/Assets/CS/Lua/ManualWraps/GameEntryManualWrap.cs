using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;
using System;

[ManualLuaClassAttribute("BindCustom")]
public class GameEntryManualWrap : LuaObject {

    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
        getTypeTable(l, "GameEntry");
        addMember(l, Restart, false);
        createTypeMetatable(l, null, typeof(GameEntry));  //, typeof(Singleton<GameEntry>)
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int Restart(IntPtr l) {
        try {
            GameEntry.Instance.need_restart = true;
            pushValue(l, true);
            return 1;
        } catch (Exception e) {
            return error(l, e);
        }
    }
}
