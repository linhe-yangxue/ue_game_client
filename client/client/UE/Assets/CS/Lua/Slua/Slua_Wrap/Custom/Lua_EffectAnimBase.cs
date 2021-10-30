using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_EffectAnimBase : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Play(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
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
	static public int Stop(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			self.Stop();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetSpeed(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.SetSpeed(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetSpeed(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			var ret=self.GetSpeed();
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
	static public int SetTime(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.SetTime(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetAnim(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			System.Single a2;
			checkType(l,3,out a2);
			self.SetAnim(a1,a2);
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
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
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
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
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
	static public int get_start_time_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.start_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_start_time_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.start_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_loop_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_loop_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_loop_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_loop_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_loop_start_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.loop_start_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_loop_start_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.loop_start_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_auto_play_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.auto_play_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_auto_play_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.auto_play_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_use_unscale_time(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.use_unscale_time);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_use_unscale_time(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.use_unscale_time=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_process_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.process_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_process_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.process_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_play_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_play_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_play_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_play_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_cur_time_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.cur_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_cur_time_(IntPtr l) {
		try {
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.cur_time_=v;
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
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
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
			EffectAnimBase self=(EffectAnimBase)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.speed_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"EffectAnimBase");
		addMember(l,Play);
		addMember(l,Stop);
		addMember(l,SetSpeed);
		addMember(l,GetSpeed);
		addMember(l,SetTime);
		addMember(l,SetAnim);
		addMember(l,"time_",get_time_,set_time_,true);
		addMember(l,"start_time_",get_start_time_,set_start_time_,true);
		addMember(l,"is_loop_",get_is_loop_,set_is_loop_,true);
		addMember(l,"loop_start_",get_loop_start_,set_loop_start_,true);
		addMember(l,"auto_play_",get_auto_play_,set_auto_play_,true);
		addMember(l,"use_unscale_time",get_use_unscale_time,set_use_unscale_time,true);
		addMember(l,"process_",get_process_,set_process_,true);
		addMember(l,"is_play_",get_is_play_,set_is_play_,true);
		addMember(l,"cur_time_",get_cur_time_,set_cur_time_,true);
		addMember(l,"speed_",get_speed_,set_speed_,true);
		createTypeMetatable(l,null, typeof(EffectAnimBase),typeof(UnityEngine.MonoBehaviour));
	}
}
