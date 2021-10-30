using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UISwipeView : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int InitSwipeView(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			System.Int32 a3;
			checkType(l,4,out a3);
			self.InitSwipeView(a1,a2,a3);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int InitSwipViewByPrefab(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			System.Single a3;
			checkType(l,4,out a3);
			System.Single a4;
			checkType(l,5,out a4);
			System.String a5;
			checkType(l,6,out a5);
			System.Int32 a6;
			checkType(l,7,out a6);
			self.InitSwipViewByPrefab(a1,a2,a3,a4,a5,a6);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int MoveToLast(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			self.MoveToLast();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int MoveToNext(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			self.MoveToNext();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnBeginDrag(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			UnityEngine.EventSystems.PointerEventData a1;
			checkType(l,2,out a1);
			self.OnBeginDrag(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnEndDrag(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			UnityEngine.EventSystems.PointerEventData a1;
			checkType(l,2,out a1);
			self.OnEndDrag(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int LocalToIndex(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.LocalToIndex(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SwipeToIndex(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SwipeToIndex(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnDrag(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			UnityEngine.EventSystems.PointerEventData a1;
			checkType(l,2,out a1);
			self.OnDrag(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OnViewChange(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			UISwipeView.ViewChangeDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.OnViewChange=v;
			else if(op==1) self.OnViewChange+=v;
			else if(op==2) self.OnViewChange-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OnSelectNode(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			UISwipeView.SelectNodeDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.OnSelectNode=v;
			else if(op==1) self.OnSelectNode+=v;
			else if(op==2) self.OnSelectNode-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_temp_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.temp_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_temp_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			UnityEngine.GameObject v;
			checkType(l,2,out v);
			self.temp_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_vertical_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_vertical_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_vertical_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_vertical_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_offset_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.offset_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_offset_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.offset_=v;
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
			UISwipeView self=(UISwipeView)checkSelf(l);
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
			UISwipeView self=(UISwipeView)checkSelf(l);
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
	static public int get_is_limit_range(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_limit_range);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_limit_range(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_limit_range=v;
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
			UISwipeView self=(UISwipeView)checkSelf(l);
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
			UISwipeView self=(UISwipeView)checkSelf(l);
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
	static public int get_move_speed_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.move_speed_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_move_speed_(IntPtr l) {
		try {
			UISwipeView self=(UISwipeView)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.move_speed_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UISwipeView");
		addMember(l,InitSwipeView);
		addMember(l,InitSwipViewByPrefab);
		addMember(l,MoveToLast);
		addMember(l,MoveToNext);
		addMember(l,OnBeginDrag);
		addMember(l,OnEndDrag);
		addMember(l,LocalToIndex);
		addMember(l,SwipeToIndex);
		addMember(l,OnDrag);
		addMember(l,"OnViewChange",null,set_OnViewChange,true);
		addMember(l,"OnSelectNode",null,set_OnSelectNode,true);
		addMember(l,"temp_",get_temp_,set_temp_,true);
		addMember(l,"is_vertical_",get_is_vertical_,set_is_vertical_,true);
		addMember(l,"offset_",get_offset_,set_offset_,true);
		addMember(l,"content_",get_content_,set_content_,true);
		addMember(l,"is_limit_range",get_is_limit_range,set_is_limit_range,true);
		addMember(l,"move_time_",get_move_time_,set_move_time_,true);
		addMember(l,"move_speed_",get_move_speed_,set_move_speed_,true);
		createTypeMetatable(l,null, typeof(UISwipeView),typeof(UnityEngine.EventSystems.UIBehaviour));
	}
}
