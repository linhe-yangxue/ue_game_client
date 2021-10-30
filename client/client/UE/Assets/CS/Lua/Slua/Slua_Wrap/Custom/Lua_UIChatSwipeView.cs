using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIChatSwipeView : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Init(IntPtr l) {
		try {
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
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
	static public int OnBeginDrag(IntPtr l) {
		try {
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
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
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
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
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
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
	static public int set_UpdateChat(IntPtr l) {
		try {
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
			UIChatSwipeView.UpdateChatDelegate v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.UpdateChat=v;
			else if(op==1) self.UpdateChat+=v;
			else if(op==2) self.UpdateChat-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_hide_scroll_delay_(IntPtr l) {
		try {
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.hide_scroll_delay_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_hide_scroll_delay_(IntPtr l) {
		try {
			UIChatSwipeView self=(UIChatSwipeView)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.hide_scroll_delay_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIChatSwipeView");
		addMember(l,Init);
		addMember(l,OnBeginDrag);
		addMember(l,OnDrag);
		addMember(l,OnEndDrag);
		addMember(l,"UpdateChat",null,set_UpdateChat,true);
		addMember(l,"hide_scroll_delay_",get_hide_scroll_delay_,set_hide_scroll_delay_,true);
		createTypeMetatable(l,null, typeof(UIChatSwipeView),typeof(UnityEngine.EventSystems.UIBehaviour));
	}
}
