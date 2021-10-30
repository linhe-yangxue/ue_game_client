using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIAnimBase : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnEnable(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
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
			UIAnimBase self=(UIAnimBase)checkSelf(l);
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
	static public int get_OnTriggerEvent(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.OnTriggerEvent);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OnTriggerEvent(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			UIAnimBase.TriggerEvent v;
			checkType(l,2,out v);
			self.OnTriggerEvent=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_time_(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_time_(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_repeat_count(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.repeat_count);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_repeat_count(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.repeat_count=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_rect_(IntPtr l) {
		try {
			UIAnimBase self=(UIAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.rect_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIAnimBase");
		addMember(l,OnEnable);
		addMember(l,UpdateAnim);
		addMember(l,"OnTriggerEvent",get_OnTriggerEvent,set_OnTriggerEvent,true);
		addMember(l,"time_",get_time_,set_time_,true);
		addMember(l,"repeat_count",get_repeat_count,set_repeat_count,true);
		addMember(l,"rect_",get_rect_,null,true);
		createTypeMetatable(l,null, typeof(UIAnimBase),typeof(UnityEngine.MonoBehaviour));
	}
}
