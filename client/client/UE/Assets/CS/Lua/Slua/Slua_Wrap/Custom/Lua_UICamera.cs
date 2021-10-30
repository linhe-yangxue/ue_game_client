using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UICamera : LuaObject {
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UICamera");
		createTypeMetatable(l,null, typeof(UICamera),typeof(UnityEngine.MonoBehaviour));
	}
}
