using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIAnimReciveRes : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Init(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			UnityEngine.Vector3 a1;
			checkType(l,2,out a1);
			self.Init(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnEnable(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
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
	static public int Update(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			self.Update();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnDisable(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			self.OnDisable();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_x_curve_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.x_curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_x_curve_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.x_curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_y_curve_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.y_curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_y_curve_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.y_curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_init_sprite_time_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.init_sprite_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_init_sprite_time_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.init_sprite_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_start_move_time_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.start_move_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_start_move_time_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.start_move_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_move_time_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.move_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_move_time_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.move_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_init_sprite_num_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.init_sprite_num_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_init_sprite_num_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.init_sprite_num_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_init_ui_sprite_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.init_ui_sprite_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_init_ui_sprite_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			UnityEngine.Sprite v;
			checkType(l,2,out v);
			self.init_ui_sprite_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_target_pos_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.target_pos_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_target_pos_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			UnityEngine.Vector3 v;
			checkType(l,2,out v);
			self.target_pos_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_init_rect_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.init_rect_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_init_rect_(IntPtr l) {
		try {
			UIAnimReciveRes self=(UIAnimReciveRes)checkSelf(l);
			UnityEngine.Vector2 v;
			checkType(l,2,out v);
			self.init_rect_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIAnimReciveRes");
		addMember(l,Init);
		addMember(l,OnEnable);
		addMember(l,Update);
		addMember(l,OnDisable);
		addMember(l,"x_curve_",get_x_curve_,set_x_curve_,true);
		addMember(l,"y_curve_",get_y_curve_,set_y_curve_,true);
		addMember(l,"init_sprite_time_",get_init_sprite_time_,set_init_sprite_time_,true);
		addMember(l,"start_move_time_",get_start_move_time_,set_start_move_time_,true);
		addMember(l,"move_time_",get_move_time_,set_move_time_,true);
		addMember(l,"init_sprite_num_",get_init_sprite_num_,set_init_sprite_num_,true);
		addMember(l,"init_ui_sprite_",get_init_ui_sprite_,set_init_ui_sprite_,true);
		addMember(l,"target_pos_",get_target_pos_,set_target_pos_,true);
		addMember(l,"init_rect_",get_init_rect_,set_init_rect_,true);
		createTypeMetatable(l,null, typeof(UIAnimReciveRes),typeof(BaseUIAnimEffect));
	}
}
