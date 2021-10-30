using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_TextPic : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetTextPicValue(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			var ret=self.SetTextPicValue(a1);
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
	static public int GetImageSize(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			var ret=self.GetImageSize();
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
	static public int OnPointerClick(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			UnityEngine.EventSystems.PointerEventData a1;
			checkType(l,2,out a1);
			self.OnPointerClick(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetTextWithEllipsis(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			var ret=self.SetTextWithEllipsis(a1);
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
	static public int RefleshImagePos(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			System.Collections.Generic.List<System.Single> a1;
			checkType(l,2,out a1);
			self.RefleshImagePos(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int OnPointerDown(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			UnityEngine.EventSystems.PointerEventData a1;
			checkType(l,2,out a1);
			self.OnPointerDown(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_PopulateMeshCallBack(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			TextPic.NoParamCallBack v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.PopulateMeshCallBack=v;
			else if(op==1) self.PopulateMeshCallBack+=v;
			else if(op==2) self.PopulateMeshCallBack-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_ClickHrefCallBack(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			TextPic.StringParamCallBack v;
			int op=LuaDelegation.checkDelegate(l,2,out v);
			if(op==0) self.ClickHrefCallBack=v;
			else if(op==1) self.ClickHrefCallBack+=v;
			else if(op==2) self.ClickHrefCallBack-=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_ImgPosList(IntPtr l) {
		try {
			TextPic self=(TextPic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.ImgPosList);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"TextPic");
		addMember(l,SetTextPicValue);
		addMember(l,GetImageSize);
		addMember(l,OnPointerClick);
		addMember(l,SetTextWithEllipsis);
		addMember(l,RefleshImagePos);
		addMember(l,OnPointerDown);
		addMember(l,"PopulateMeshCallBack",null,set_PopulateMeshCallBack,true);
		addMember(l,"ClickHrefCallBack",null,set_ClickHrefCallBack,true);
		addMember(l,"ImgPosList",get_ImgPosList,null,true);
		createTypeMetatable(l,null, typeof(TextPic),typeof(UnityEngine.UI.Text));
	}
}
