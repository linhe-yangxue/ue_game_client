using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_AssetBundles_AssetBundleConst : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetPlatformName_s(IntPtr l) {
		try {
			var ret=AssetBundles.AssetBundleConst.GetPlatformName();
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
	static public int get_build_path(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,AssetBundles.AssetBundleConst.build_path);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_set_filename(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,AssetBundles.AssetBundleConst.set_filename);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_set_version_filename(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,AssetBundles.AssetBundleConst.set_version_filename);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_lang_abname(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,AssetBundles.AssetBundleConst.lang_abname);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_lang_abname(IntPtr l) {
		try {
			System.String[] v;
			checkArray(l,2,out v);
			AssetBundles.AssetBundleConst.lang_abname=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_inner_path(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,AssetBundles.AssetBundleConst.inner_path);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_external_path(IntPtr l) {
		try {
			pushValue(l,true);
			pushValue(l,AssetBundles.AssetBundleConst.external_path);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"AssetBundles.AssetBundleConst");
		addMember(l,GetPlatformName_s);
		addMember(l,"build_path",get_build_path,null,false);
		addMember(l,"set_filename",get_set_filename,null,false);
		addMember(l,"set_version_filename",get_set_version_filename,null,false);
		addMember(l,"lang_abname",get_lang_abname,set_lang_abname,false);
		addMember(l,"inner_path",get_inner_path,null,false);
		addMember(l,"external_path",get_external_path,null,false);
		AssetBundleConstManualWrap.reg(l);
		createTypeMetatable(l,null, typeof(AssetBundles.AssetBundleConst));
	}
}
