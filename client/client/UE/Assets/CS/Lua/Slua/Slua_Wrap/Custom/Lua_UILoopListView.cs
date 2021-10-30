using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UILoopListView : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Refresh(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Boolean a1;
			checkType(l,2,out a1);
			self.Refresh(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SelectNext(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			self.SelectNext();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SelectLast(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			self.SelectLast();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SelectIndex(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Boolean a2;
			checkType(l,3,out a2);
			self.SelectIndex(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetCurIndex(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			var ret=self.GetCurIndex();
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
	static public int SetCurIndex(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SetCurIndex(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateItemOffset(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UILoopListView.LoopSwipeItem a1;
			checkType(l,2,out a1);
			System.Single a2;
			checkType(l,3,out a2);
			self.UpdateItemOffset(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateItemPos(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UILoopListView.LoopSwipeItem a1;
			checkType(l,2,out a1);
			System.Single a2;
			checkType(l,3,out a2);
			self.UpdateItemPos(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetAlpha(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			var ret=self.GetAlpha(a1);
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
	static public int GetPositionX(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			var ret=self.GetPositionX(a1);
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
	static public int GetPositionY(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			var ret=self.GetPositionY(a1);
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
	static public int GetScale(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			var ret=self.GetScale(a1);
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
	static public int set_OnItemSelect(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UILoopListView.ItemSelectDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.OnItemSelect=v;
			else if(op==1) self.OnItemSelect+=v;
			else if(op==2) self.OnItemSelect-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_content_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.content_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_content_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UnityEngine.RectTransform v;
			checkType(l,2,out v);
			self.content_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_anim_time_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.anim_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_anim_time_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.anim_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_init_anim_time_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.init_anim_time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_init_anim_time_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.init_anim_time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_start_value_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.start_value_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_start_value_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.start_value_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_show_count_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.show_count_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_show_count_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.show_count_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_pos_x_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.pos_x_curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_pos_x_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.pos_x_curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_pos_y_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.pos_y_curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_pos_y_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.pos_y_curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_scale_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.scale_curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_scale_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.scale_curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_alpha_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.alpha_curve_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_alpha_curve_(IntPtr l) {
		try {
			UILoopListView self=(UILoopListView)checkSelf(l);
			UnityEngine.AnimationCurve v;
			checkType(l,2,out v);
			self.alpha_curve_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UILoopListView");
		addMember(l,Refresh);
		addMember(l,SelectNext);
		addMember(l,SelectLast);
		addMember(l,SelectIndex);
		addMember(l,GetCurIndex);
		addMember(l,SetCurIndex);
		addMember(l,UpdateItemOffset);
		addMember(l,UpdateItemPos);
		addMember(l,GetAlpha);
		addMember(l,GetPositionX);
		addMember(l,GetPositionY);
		addMember(l,GetScale);
		addMember(l,"OnItemSelect",null,set_OnItemSelect,true);
		addMember(l,"content_",get_content_,set_content_,true);
		addMember(l,"anim_time_",get_anim_time_,set_anim_time_,true);
		addMember(l,"init_anim_time_",get_init_anim_time_,set_init_anim_time_,true);
		addMember(l,"start_value_",get_start_value_,set_start_value_,true);
		addMember(l,"show_count_",get_show_count_,set_show_count_,true);
		addMember(l,"pos_x_curve_",get_pos_x_curve_,set_pos_x_curve_,true);
		addMember(l,"pos_y_curve_",get_pos_y_curve_,set_pos_y_curve_,true);
		addMember(l,"scale_curve_",get_scale_curve_,set_scale_curve_,true);
		addMember(l,"alpha_curve_",get_alpha_curve_,set_alpha_curve_,true);
		createTypeMetatable(l,null, typeof(UILoopListView),typeof(UnityEngine.MonoBehaviour));
	}
}
