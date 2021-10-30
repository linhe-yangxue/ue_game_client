using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_AssetBundles_ABLoadSubAssetOpt : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int constructor(IntPtr l) {
		try {
			AssetBundles.ABLoadSubAssetOpt o;
			UnityEngine.AsyncOperation a1;
			checkType(l,2,out a1);
			System.String a2;
			checkType(l,3,out a2);
			System.Type a3;
			checkType(l,4,out a3);
			o=new AssetBundles.ABLoadSubAssetOpt(a1,a2,a3);
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
	static public int get_asset(IntPtr l) {
		try {
			AssetBundles.ABLoadSubAssetOpt self=(AssetBundles.ABLoadSubAssetOpt)checkSelf(l);
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
		getTypeTable(l,"AssetBundles.ABLoadSubAssetOpt");
		addMember(l,"asset",get_asset,null,true);
		createTypeMetatable(l,constructor, typeof(AssetBundles.ABLoadSubAssetOpt),typeof(AssetBundles.ABLoadOptBase));
	}
}
