using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UITweenScale : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Play(IntPtr l) {
		try {
			UITweenScale self=(UITweenScale)checkSelf(l);
			self.Play();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_from_(IntPtr l) {
		try {
			UITweenScale self=(UITweenScale)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.from_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_from_(IntPtr l) {
		try {
			UITweenScale self=(UITweenScale)checkSelf(l);
			UnityEngine.Vector3 v;
			checkType(l,2,out v);
			self.from_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_to_(IntPtr l) {
		try {
			UITweenScale self=(UITweenScale)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.to_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_to_(IntPtr l) {
		try {
			UITweenScale self=(UITweenScale)checkSelf(l);
			UnityEngine.Vector3 v;
			checkType(l,2,out v);
			self.to_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UITweenScale");
		addMember(l,Play);
		addMember(l,"from_",get_from_,set_from_,true);
		addMember(l,"to_",get_to_,set_to_,true);
		createTypeMetatable(l,null, typeof(UITweenScale),typeof(UITweenBase));
	}
}
