using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIDynamicList : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Init(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
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
	static public int OnDrag(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
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
			UIDynamicList self=(UIDynamicList)checkSelf(l);
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
	static public int AddPageListItem(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			System.Int32[] a1;
			checkArray(l,2,out a1);
			self.AddPageListItem(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int InsertItem(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			System.Boolean a3;
			checkType(l,4,out a3);
			self.InsertItem(a1,a2,a3);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int RemoveItem(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Boolean a2;
			checkType(l,3,out a2);
			self.RemoveItem(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SelectItem(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SelectItem(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int MoveViewToItem(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.MoveViewToItem(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateList(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			self.UpdateList();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ClearList(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			self.ClearList();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetOffsetCount(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.SetOffsetCount(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int DoDestroy(IntPtr l) {
		try {
			UIDynamicList self=(UIDynamicList)checkSelf(l);
			self.DoDestroy();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIDynamicList");
		addMember(l,Init);
		addMember(l,OnDrag);
		addMember(l,OnEndDrag);
		addMember(l,AddPageListItem);
		addMember(l,InsertItem);
		addMember(l,RemoveItem);
		addMember(l,SelectItem);
		addMember(l,MoveViewToItem);
		addMember(l,UpdateList);
		addMember(l,ClearList);
		addMember(l,SetOffsetCount);
		addMember(l,DoDestroy);
		createTypeMetatable(l,null, typeof(UIDynamicList),typeof(UnityEngine.EventSystems.UIBehaviour));
	}
}
