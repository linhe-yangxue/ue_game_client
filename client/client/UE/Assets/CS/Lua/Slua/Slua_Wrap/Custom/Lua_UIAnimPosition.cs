using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIAnimPosition : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnEnable(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
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
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
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
	static public int SetStartPos(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			UnityEngine.Vector3 a1;
			checkType(l,2,out a1);
			self.SetStartPos(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetEndPos(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			UnityEngine.Vector3 a1;
			checkType(l,2,out a1);
			self.SetEndPos(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_start_pos_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.start_pos_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_start_pos_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			UnityEngine.Vector3 v;
			checkType(l,2,out v);
			self.start_pos_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_end_pos_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.end_pos_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_end_pos_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			UnityEngine.Vector3 v;
			checkType(l,2,out v);
			self.end_pos_=v;
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
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
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
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
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
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_arc_height_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.arc_height_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_arc_height_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.arc_height_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_arc_pct_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.arc_pct_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_arc_pct_(IntPtr l) {
		try {
			UIAnimPosition self=(UIAnimPosition)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.arc_pct_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIAnimPosition");
		addMember(l,OnEnable);
		addMember(l,UpdateAnim);
		addMember(l,SetStartPos);
		addMember(l,SetEndPos);
		addMember(l,"start_pos_",get_start_pos_,set_start_pos_,true);
		addMember(l,"end_pos_",get_end_pos_,set_end_pos_,true);
		addMember(l,"curve_",get_curve_,set_curve_,true);
		addMember(l,"arc_height_",get_arc_height_,set_arc_height_,true);
		addMember(l,"arc_pct_",get_arc_pct_,set_arc_pct_,true);
		createTypeMetatable(l,null, typeof(UIAnimPosition),typeof(UIAnimBase));
	}
}
