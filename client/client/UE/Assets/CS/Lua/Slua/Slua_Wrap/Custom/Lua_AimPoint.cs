using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_AimPoint : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Shoot(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			var ret=self.Shoot();
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
	static public int CanShoot(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			self.CanShoot();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Reset(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			self.Reset();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_move_speed_rate(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.move_speed_rate);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_move_speed_rate(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.move_speed_rate=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_shoot_anim_time(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.shoot_anim_time);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_shoot_anim_time(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.shoot_anim_time=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_max_radius_rate(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.max_radius_rate);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_max_radius_rate(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.max_radius_rate=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_aim(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.aim);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_aim(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.RectTransform v;
			checkType(l,2,out v);
			self.aim=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_hit_circle(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.hit_circle);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_hit_circle(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.hit_circle=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_crit_circle(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.crit_circle);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_crit_circle(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.crit_circle=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_reload(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_reload);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_reload(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_reload=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_auto_shoot(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_auto_shoot);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_auto_shoot(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_auto_shoot=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_max_shoot_cool_time(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.max_shoot_cool_time);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_max_shoot_cool_time(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.max_shoot_cool_time=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_shoot_btn(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.shoot_btn);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_shoot_btn(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.UI.Button v;
			checkType(l,2,out v);
			self.shoot_btn=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_cool_down_image(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.cool_down_image);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_cool_down_image(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.UI.Image v;
			checkType(l,2,out v);
			self.cool_down_image=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_reload_tip(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.reload_tip);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_reload_tip(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.reload_tip=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_shoot_gun(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.shoot_gun);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_shoot_gun(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.shoot_gun=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_shoot_ready(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.shoot_ready);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_shoot_ready(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.shoot_ready=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_shoot_hide_go(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.shoot_hide_go);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_shoot_hide_go(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.shoot_hide_go=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_scroll_bgs(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.scroll_bgs);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_scroll_bgs(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			UIAnimScrollBg[] v;
			checkArray(l,2,out v);
			self.scroll_bgs=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_stop_bg_time(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.stop_bg_time);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_stop_bg_time(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.stop_bg_time=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_Is_scroll_bg_runing(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.Is_scroll_bg_runing);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_Is_scroll_bg_runing(IntPtr l) {
		try {
			AimPoint self=(AimPoint)checkSelf(l);
			bool v;
			checkType(l,2,out v);
			self.Is_scroll_bg_runing=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"AimPoint");
		addMember(l,Shoot);
		addMember(l,CanShoot);
		addMember(l,Reset);
		addMember(l,"move_speed_rate",get_move_speed_rate,set_move_speed_rate,true);
		addMember(l,"shoot_anim_time",get_shoot_anim_time,set_shoot_anim_time,true);
		addMember(l,"max_radius_rate",get_max_radius_rate,set_max_radius_rate,true);
		addMember(l,"aim",get_aim,set_aim,true);
		addMember(l,"hit_circle",get_hit_circle,set_hit_circle,true);
		addMember(l,"crit_circle",get_crit_circle,set_crit_circle,true);
		addMember(l,"is_reload",get_is_reload,set_is_reload,true);
		addMember(l,"is_auto_shoot",get_is_auto_shoot,set_is_auto_shoot,true);
		addMember(l,"max_shoot_cool_time",get_max_shoot_cool_time,set_max_shoot_cool_time,true);
		addMember(l,"shoot_btn",get_shoot_btn,set_shoot_btn,true);
		addMember(l,"cool_down_image",get_cool_down_image,set_cool_down_image,true);
		addMember(l,"reload_tip",get_reload_tip,set_reload_tip,true);
		addMember(l,"shoot_gun",get_shoot_gun,set_shoot_gun,true);
		addMember(l,"shoot_ready",get_shoot_ready,set_shoot_ready,true);
		addMember(l,"shoot_hide_go",get_shoot_hide_go,set_shoot_hide_go,true);
		addMember(l,"scroll_bgs",get_scroll_bgs,set_scroll_bgs,true);
		addMember(l,"stop_bg_time",get_stop_bg_time,set_stop_bg_time,true);
		addMember(l,"Is_scroll_bg_runing",get_Is_scroll_bg_runing,set_Is_scroll_bg_runing,true);
		createTypeMetatable(l,null, typeof(AimPoint),typeof(UnityEngine.MonoBehaviour));
	}
}
