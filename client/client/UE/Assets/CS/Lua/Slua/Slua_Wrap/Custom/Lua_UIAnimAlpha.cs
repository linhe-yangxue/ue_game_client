using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIAnimAlpha : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnEnable(IntPtr l) {
		try {
			UIAnimAlpha self=(UIAnimAlpha)checkSelf(l);
			self.OnEnable();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateAnim(IntPtr l) {
		try {
			UIAnimAlpha self=(UIAnimAlpha)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.UpdateAnim(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_curve_(IntPtr l) {
		try {
			UIAnimAlpha self=(UIAnimAlpha)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_curve_(IntPtr l) {
		try {
			UIAnimAlpha self=(UIAnimAlpha)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIAnimAlpha");
		addMember(l,OnEnable);
		addMember(l,UpdateAnim);
		addMember(l,"curve_",get_curve_,set_curve_,true);
		createTypeMetatable(l,null, typeof(UIAnimAlpha),typeof(UIAnimBase));
	}
}
