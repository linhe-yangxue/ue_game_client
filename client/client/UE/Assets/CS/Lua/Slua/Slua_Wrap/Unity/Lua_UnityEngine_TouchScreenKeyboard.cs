using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UnityEngine_TouchScreenKeyboard : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int constructor(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard o;
			System.String a1;
			checkType(l,2,out a1);
			UnityEngine.TouchScreenKeyboardType a2;
			checkEnum(l,3,out a2);
			System.Boolean a3;
			checkType(l,4,out a3);
			System.Boolean a4;
			checkType(l,5,out a4);
			System.Boolean a5;
			checkType(l,6,out a5);
			System.Boolean a6;
			checkType(l,7,out a6);
			System.String a7;
			checkType(l,8,out a7);
			System.Int32 a8;
			checkType(l,9,out a8);
			o=new UnityEngine.TouchScreenKeyboard(a1,a2,a3,a4,a5,a6,a7,a8);
			pushValue(l,true);
			pushValue(l,o);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Open_s(IntPtr l) {
		try {
			int argc = LuaDLL.lua_gettop(l);
			if(argc==1){
				System.String a1;
				checkType(l,1,out a1);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==2){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==3){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				System.Boolean a3;
				checkType(l,3,out a3);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2,a3);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==4){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				System.Boolean a3;
				checkType(l,3,out a3);
				System.Boolean a4;
				checkType(l,4,out a4);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2,a3,a4);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==5){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				System.Boolean a3;
				checkType(l,3,out a3);
				System.Boolean a4;
				checkType(l,4,out a4);
				System.Boolean a5;
				checkType(l,5,out a5);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2,a3,a4,a5);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==6){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				System.Boolean a3;
				checkType(l,3,out a3);
				System.Boolean a4;
				checkType(l,4,out a4);
				System.Boolean a5;
				checkType(l,5,out a5);
				System.Boolean a6;
				checkType(l,6,out a6);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2,a3,a4,a5,a6);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==7){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				System.Boolean a3;
				checkType(l,3,out a3);
				System.Boolean a4;
				checkType(l,4,out a4);
				System.Boolean a5;
				checkType(l,5,out a5);
				System.Boolean a6;
				checkType(l,6,out a6);
				System.String a7;
				checkType(l,7,out a7);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2,a3,a4,a5,a6,a7);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(argc==8){
				System.String a1;
				checkType(l,1,out a1);
				UnityEngine.TouchScreenKeyboardType a2;
				checkEnum(l,2,out a2);
				System.Boolean a3;
				checkType(l,3,out a3);
				System.Boolean a4;
				checkType(l,4,out a4);
				System.Boolean a5;
				checkType(l,5,out a5);
				System.Boolean a6;
				checkType(l,6,out a6);
				System.String a7;
				checkType(l,7,out a7);
				System.Int32 a8;
				checkType(l,8,out a8);
				var ret=UnityEngine.TouchScreenKeyboard.Open(a1,a2,a3,a4,a5,a6,a7,a8);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			pushValue(l,false);
			LuaDLL.lua_pushstring(l,"No matched override function to call");
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_isSupported(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,UnityEngine.TouchScreenKeyboard.isSupported);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_text(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.text);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_text(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			string v;
			checkType(l,2,out v);
			self.text=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_hideInput(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,UnityEngine.TouchScreenKeyboard.hideInput);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_hideInput(IntPtr l) {
		try {
			bool v;
			checkType(l,2,out v);
			UnityEngine.TouchScreenKeyboard.hideInput=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_active(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.active);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_active(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			bool v;
			checkType(l,2,out v);
			self.active=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_status(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushEnum(l,(int)self.status);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_characterLimit(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.characterLimit);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_characterLimit(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			int v;
			checkType(l,2,out v);
			self.characterLimit=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_canGetSelection(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.canGetSelection);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_canSetSelection(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.canSetSelection);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_selection(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.selection);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_selection(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			UnityEngine.RangeInt v;
			checkValueType(l,2,out v);
			self.selection=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_type(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushEnum(l,(int)self.type);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_targetDisplay(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.targetDisplay);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_targetDisplay(IntPtr l) {
		try {
			UnityEngine.TouchScreenKeyboard self=(UnityEngine.TouchScreenKeyboard)checkSelf(l);
			int v;
			checkType(l,2,out v);
			self.targetDisplay=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_area(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,UnityEngine.TouchScreenKeyboard.area);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_visible(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,UnityEngine.TouchScreenKeyboard.visible);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UnityEngine.TouchScreenKeyboard");
		addMember(l,Open_s);
		addMember(l,"isSupported",get_isSupported,null,false);
		addMember(l,"text",get_text,set_text,true);
		addMember(l,"hideInput",get_hideInput,set_hideInput,false);
		addMember(l,"active",get_active,set_active,true);
		addMember(l,"status",get_status,null,true);
		addMember(l,"characterLimit",get_characterLimit,set_characterLimit,true);
		addMember(l,"canGetSelection",get_canGetSelection,null,true);
		addMember(l,"canSetSelection",get_canSetSelection,null,true);
		addMember(l,"selection",get_selection,set_selection,true);
		addMember(l,"type",get_type,null,true);
		addMember(l,"targetDisplay",get_targetDisplay,set_targetDisplay,true);
		addMember(l,"area",get_area,null,false);
		addMember(l,"visible",get_visible,null,false);
		createTypeMetatable(l,constructor, typeof(UnityEngine.TouchScreenKeyboard));
	}
}
