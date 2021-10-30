using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIHudText : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ShowHud(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			UnityEngine.Vector3 a1;
			checkType(l,2,out a1);
			UnityEngine.Vector2 a2;
			checkType(l,3,out a2);
			self.ShowHud(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_total_time_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.total_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_total_time_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.total_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_speed_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.speed_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_speed_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.speed_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_scale_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.scale_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_scale_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.scale_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_alpha_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.alpha_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_alpha_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.alpha_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_time_scale_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.time_scale_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_time_scale_(IntPtr l) {
		try {
			UIHudText self=(UIHudText)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.time_scale_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIHudText");
		addMember(l,ShowHud);
		addMember(l,"total_time_",get_total_time_,set_total_time_,true);
		addMember(l,"speed_",get_speed_,set_speed_,true);
		addMember(l,"scale_",get_scale_,set_scale_,true);
		addMember(l,"alpha_",get_alpha_,set_alpha_,true);
		addMember(l,"time_scale_",get_time_scale_,set_time_scale_,true);
		createTypeMetatable(l,null, typeof(UIHudText),typeof(UnityEngine.MonoBehaviour));
	}
}
