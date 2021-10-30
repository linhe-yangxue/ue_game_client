using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_TipMsgItem : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Show(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.Show(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetTargetOffset(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.SetTargetOffset(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_total_time(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.total_time);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_total_time(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.total_time=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_speed(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.speed);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_speed(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.speed=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_scale(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.scale);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_scale(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.scale=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_alpha(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.alpha);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_alpha(IntPtr l) {
		try {
			TipMsgItem self=(TipMsgItem)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.alpha=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"TipMsgItem");
		addMember(l,Show);
		addMember(l,SetTargetOffset);
		addMember(l,"total_time",get_total_time,set_total_time,true);
		addMember(l,"speed",get_speed,set_speed,true);
		addMember(l,"scale",get_scale,set_scale,true);
		addMember(l,"alpha",get_alpha,set_alpha,true);
		createTypeMetatable(l,null, typeof(TipMsgItem),typeof(UnityEngine.MonoBehaviour));
	}
}
