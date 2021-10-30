using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UITweenBase : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetDurationTime(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			var ret=self.GetDurationTime();
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
	static public int SetDurationTime(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.SetDurationTime(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetDelayTime(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			var ret=self.GetDelayTime();
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
	static public int SetDelayTime(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.SetDelayTime(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Play(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
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
	static public int get_is_auto_play_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_auto_play_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_auto_play_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_auto_play_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_auto_kill_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_auto_kill_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_auto_kill_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_auto_kill_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_duration_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.duration_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_duration_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.duration_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_delay_time_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.delay_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_delay_time_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.delay_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_loops_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.loops_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_loops_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.loops_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ease_type_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushEnum(l,(int)self.ease_type_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_ease_type_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			Tweening.Ease v;
			checkEnum(l,2,out v);
			self.ease_type_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_loop_type_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			pushValue(l,true);
			pushEnum(l,(int)self.loop_type_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_loop_type_(IntPtr l) {
		try {
			UITweenBase self=(UITweenBase)checkSelf(l);
			Tweening.LoopType v;
			checkEnum(l,2,out v);
			self.loop_type_=v;
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
			UITweenBase self=(UITweenBase)checkSelf(l);
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
		getTypeTable(l,"UITweenBase");
		addMember(l,GetDurationTime);
		addMember(l,SetDurationTime);
		addMember(l,GetDelayTime);
		addMember(l,SetDelayTime);
		addMember(l,Play);
		addMember(l,"is_auto_play_",get_is_auto_play_,set_is_auto_play_,true);
		addMember(l,"is_auto_kill_",get_is_auto_kill_,set_is_auto_kill_,true);
		addMember(l,"duration_",get_duration_,set_duration_,true);
		addMember(l,"delay_time_",get_delay_time_,set_delay_time_,true);
		addMember(l,"loops_",get_loops_,set_loops_,true);
		addMember(l,"ease_type_",get_ease_type_,set_ease_type_,true);
		addMember(l,"loop_type_",get_loop_type_,set_loop_type_,true);
		addMember(l,"rect_",get_rect_,null,true);
		createTypeMetatable(l,null, typeof(UITweenBase),typeof(UnityEngine.MonoBehaviour));
	}
}
