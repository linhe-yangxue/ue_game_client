using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_AssetBundles_ABLoadSimulationOpt : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int constructor(IntPtr l) {
		try {
			AssetBundles.ABLoadSimulationOpt o;
			UnityEngine.Object a1;
			checkType(l,2,out a1);
			System.Boolean a2;
			checkType(l,3,out a2);
			o=new AssetBundles.ABLoadSimulationOpt(a1,a2);
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
	static public int IsDone(IntPtr l) {
		try {
			AssetBundles.ABLoadSimulationOpt self=(AssetBundles.ABLoadSimulationOpt)checkSelf(l);
			var ret=self.IsDone();
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
	static public int get_progress(IntPtr l) {
		try {
			AssetBundles.ABLoadSimulationOpt self=(AssetBundles.ABLoadSimulationOpt)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.progress);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_allowSceneActivation(IntPtr l) {
		try {
			AssetBundles.ABLoadSimulationOpt self=(AssetBundles.ABLoadSimulationOpt)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.allowSceneActivation);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_allowSceneActivation(IntPtr l) {
		try {
			AssetBundles.ABLoadSimulationOpt self=(AssetBundles.ABLoadSimulationOpt)checkSelf(l);
			bool v;
			checkType(l,2,out v);
			self.allowSceneActivation=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_asset(IntPtr l) {
		try {
			AssetBundles.ABLoadSimulationOpt self=(AssetBundles.ABLoadSimulationOpt)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.asset);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"AssetBundles.ABLoadSimulationOpt");
		addMember(l,IsDone);
		addMember(l,"progress",get_progress,null,true);
		addMember(l,"allowSceneActivation",get_allowSceneActivation,set_allowSceneActivation,true);
		addMember(l,"asset",get_asset,null,true);
		createTypeMetatable(l,constructor, typeof(AssetBundles.ABLoadSimulationOpt),typeof(AssetBundles.ABLoadOptBase));
	}
}
