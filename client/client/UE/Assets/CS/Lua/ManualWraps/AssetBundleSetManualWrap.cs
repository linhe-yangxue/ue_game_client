using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SLua;
using System;
using AssetBundles;


[ExtendLuaClass(typeof(AssetBundleSet))]
public class AssetBundleSetManualWrap : LuaObject {
    [UnityEngine.Scripting.Preserve]
    public static void reg(IntPtr l) {
        addMember(l, GetList);
    }
    [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
    [UnityEngine.Scripting.Preserve]
    static public int GetList(IntPtr l) {
		try {
            AssetBundleSet self = (AssetBundleSet)checkSelf(l);
            var lua_state = LuaState.get(l);
            LuaTable lua_table = new LuaTable(lua_state);
            foreach (var item in self.list_) {
                LuaTable line = new LuaTable(lua_state);
                line["name"] = item.Key;
                line["md5"] = item.Value.md5_;
                line["size"] = item.Value.size_;
                lua_table[item.Key] = line;
            }
            pushValue(l, true);
            pushValue(l, lua_table);
            return 2;
        } catch (Exception e) {
            return error(l,e);
        }
	}
}
