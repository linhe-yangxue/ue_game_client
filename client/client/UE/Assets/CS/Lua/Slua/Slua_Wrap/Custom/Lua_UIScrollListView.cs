using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UIScrollListView : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int InitScrollListView(IntPtr l) {
		try {
			UIScrollListView self=(UIScrollListView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Int32 a2;
			checkType(l,3,out a2);
			self.InitScrollListView(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ResetScrollListView(IntPtr l) {
		try {
			UIScrollListView self=(UIScrollListView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.ResetScrollListView(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ChangeTotalCount(IntPtr l) {
		try {
			UIScrollListView self=(UIScrollListView)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.ChangeTotalCount(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetStartFlagIndex(IntPtr l) {
		try {
			UIScrollListView self=(UIScrollListView)checkSelf(l);
			var ret=self.GetStartFlagIndex();
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
	static public int GetEndFlagIndex(IntPtr l) {
		try {
			UIScrollListView self=(UIScrollListView)checkSelf(l);
			var ret=self.GetEndFlagIndex();
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
	static public int set_OnViewChange(IntPtr l) {
		try {
			UIScrollListView self=(UIScrollListView)checkSelf(l);
			UIScrollListView.ViewChangeDelegate v;
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
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UIScrollListView");
		addMember(l,InitScrollListView);
		addMember(l,ResetScrollListView);
		addMember(l,ChangeTotalCount);
		addMember(l,GetStartFlagIndex);
		addMember(l,GetEndFlagIndex);
		addMember(l,"OnViewChange",null,set_OnViewChange,true);
		createTypeMetatable(l,null, typeof(UIScrollListView),typeof(UnityEngine.MonoBehaviour));
	}
}
