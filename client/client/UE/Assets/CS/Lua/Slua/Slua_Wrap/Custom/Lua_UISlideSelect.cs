using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UISlideSelect : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Init(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			self.Init();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetParam(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			self.SetParam(a1,a2);
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
	static public int OnDrag(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
	static public int OnEndDrag(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
	static public int SetDraggable(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			System.Boolean a1;
			checkType(l,2,out a1);
			self.SetDraggable(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SlideToIndex(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SlideToIndex(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SlideByOffset(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SlideByOffset(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetToIndex(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SetToIndex(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ResetLoopOffset(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			self.ResetLoopOffset();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_UpdateSelect(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			UISlideSelect.UpdateSelectDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.UpdateSelect=v;
			else if(op==1) self.UpdateSelect+=v;
			else if(op==2) self.UpdateSelect-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_SlideBegin(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			UISlideSelect.SlideBeginDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.SlideBegin=v;
			else if(op==1) self.SlideBegin+=v;
			else if(op==2) self.SlideBegin-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_SlideEnd(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			UISlideSelect.SlideEndDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.SlideEnd=v;
			else if(op==1) self.SlideEnd+=v;
			else if(op==2) self.SlideEnd-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_transform_list_(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.transform_list_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_transform_list_(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			UnityEngine.RectTransform[] v;
			checkArray(l,2,out v);
			self.transform_list_=v;
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
	static public int get_move_time_(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_drag_range_(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.drag_range_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_drag_range_(IntPtr l) {
		try {
			UISlideSelect self=(UISlideSelect)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.drag_range_=v;
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
			UISlideSelect self=(UISlideSelect)checkSelf(l);
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
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UISlideSelect");
		addMember(l,Init);
		addMember(l,SetParam);
		addMember(l,OnBeginDrag);
		addMember(l,OnDrag);
		addMember(l,OnEndDrag);
		addMember(l,SetDraggable);
		addMember(l,SlideToIndex);
		addMember(l,SlideByOffset);
		addMember(l,SetToIndex);
		addMember(l,ResetLoopOffset);
		addMember(l,"UpdateSelect",null,set_UpdateSelect,true);
		addMember(l,"SlideBegin",null,set_SlideBegin,true);
		addMember(l,"SlideEnd",null,set_SlideEnd,true);
		addMember(l,"transform_list_",get_transform_list_,set_transform_list_,true);
		addMember(l,"is_loop_",get_is_loop_,set_is_loop_,true);
		addMember(l,"move_time_",get_move_time_,set_move_time_,true);
		addMember(l,"move_speed_",get_move_speed_,set_move_speed_,true);
		addMember(l,"drag_range_",get_drag_range_,set_drag_range_,true);
		addMember(l,"is_vertical_",get_is_vertical_,set_is_vertical_,true);
		createTypeMetatable(l,null, typeof(UISlideSelect),typeof(UnityEngine.EventSystems.UIBehaviour));
	}
}
