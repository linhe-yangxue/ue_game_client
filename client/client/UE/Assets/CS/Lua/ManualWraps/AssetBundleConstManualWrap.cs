using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;
using System;
using AssetBundles;


[ExtendLuaClass(typeof(AssetBundleConst))]
public class AssetBundleConstManualWrap : LuaObject {
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
        addMember(l, GetLangABName_s);
    }

    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetLangABName_s(IntPtr l) {
        try {
            var lua_state = LuaState.get(l);
            LuaTable lua_table = new LuaTable(lua_state);
            for (int i = 0; i < AssetBundleConst.lang_abname.Length; i++)
            {
                lua_table[i+1] = AssetBundleConst.lang_abname[i];
            }
            pushValue(l, true);
            pushValue(l, lua_table);
            return 2;
        } catch (Exception e) {
            return error(l,e);
        }
    }
}
