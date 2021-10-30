using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_UISpellCooldown : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetCooldown(IntPtr l) {
		try {
			int argc = LuaDLL.lua_gettop(l);
			if(argc==3){
				UISpellCooldown self=(UISpellCooldown)checkSelf(l);
				System.Single a1;
				checkType(l,2,out a1);
				System.Single a2;
				checkType(l,3,out a2);
				self.SetCooldown(a1,a2);
				pushValue(l,true);
				return 1;
			}
			else if(argc==6){
				UISpellCooldown self=(UISpellCooldown)checkSelf(l);
				System.Int32 a1;
				checkType(l,2,out a1);
				System.Int32 a2;
				checkType(l,3,out a2);
				System.Single a3;
				checkType(l,4,out a3);
				System.Single a4;
				checkType(l,5,out a4);
				System.Single a5;
				checkType(l,6,out a5);
				self.SetCooldown(a1,a2,a3,a4,a5);
				pushValue(l,true);
				return 1;
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
	static public int get_is_spell(IntPtr l) {
		try {
			UISpellCooldown self=(UISpellCooldown)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_spell);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_spell(IntPtr l) {
		try {
			UISpellCooldown self=(UISpellCooldown)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_spell=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_is_add(IntPtr l) {
		try {
			UISpellCooldown self=(UISpellCooldown)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.is_add);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_is_add(IntPtr l) {
		try {
			UISpellCooldown self=(UISpellCooldown)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.is_add=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"UISpellCooldown");
		addMember(l,SetCooldown);
		addMember(l,"is_spell",get_is_spell,set_is_spell,true);
		addMember(l,"is_add",get_is_add,set_is_add,true);
		createTypeMetatable(l,null, typeof(UISpellCooldown),typeof(UnityEngine.MonoBehaviour));
	}
}
