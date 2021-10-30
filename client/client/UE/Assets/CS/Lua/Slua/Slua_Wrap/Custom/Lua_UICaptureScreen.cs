using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UICaptureScreen : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int IsShoot(IntPtr l) {
		try {
			UICaptureScreen self=(UICaptureScreen)checkSelf(l);
			var ret=self.IsShoot();
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
	static public int GetTexture(IntPtr l) {
		try {
			UICaptureScreen self=(UICaptureScreen)checkSelf(l);
			var ret=self.GetTexture();
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
	static public int StartScreenShoot(IntPtr l) {
		try {
			UICaptureScreen self=(UICaptureScreen)checkSelf(l);
			self.StartScreenShoot();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UICaptureScreen");
		addMember(l,IsShoot);
		addMember(l,GetTexture);
		addMember(l,StartScreenShoot);
		createTypeMetatable(l,null, typeof(UICaptureScreen),typeof(UnityEngine.MonoBehaviour));
	}
}
