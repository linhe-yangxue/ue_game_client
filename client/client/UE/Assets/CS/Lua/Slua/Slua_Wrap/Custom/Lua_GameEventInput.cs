using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_GameEventInput : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int IsPositionOnUI_s(IntPtr l) {
		try {
			UnityEngine.Vector3 a1;
			checkType(l,1,out a1);
			var ret=GameEventInput.IsPositionOnUI(a1);
			pushValue(l,true);
			pushValue(l,ret);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int IsTouchOnUI_s(IntPtr l) {
		try {
			UnityEngine.Touch a1;
			checkValueType(l,1,out a1);
			var ret=GameEventInput.IsTouchOnUI(a1);
			pushValue(l,true);
			pushValue(l,ret);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"GameEventInput");
		addMember(l,IsPositionOnUI_s);
		addMember(l,IsTouchOnUI_s);
		createTypeMetatable(l,null, typeof(GameEventInput),typeof(Singleton<GameEventInput>));
	}
}
