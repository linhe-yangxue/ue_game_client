using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_AssetBundles_AssetBundleSet : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int constructor(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet o;
			System.String a1;
			checkType(l,2,out a1);
			o=new AssetBundles.AssetBundleSet(a1);
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
	static public int ReadSet(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			self.ReadSet();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int WriteSet(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			self.WriteSet();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ReadVersion(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			var ret=self.ReadVersion();
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
	static public int WriteVersion(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			self.WriteVersion();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ReadManifest(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			self.ReadManifest();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Add(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			System.String a2;
			checkType(l,3,out a2);
			System.Int32 a3;
			checkType(l,4,out a3);
			self.Add(a1,a2,a3);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetMD5(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			var ret=self.GetMD5(a1);
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
	static public int GetSize(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			var ret=self.GetSize(a1);
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
	static public int get_path_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.path_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_path_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.String v;
			checkType(l,2,out v);
			self.path_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_svn_version_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.svn_version_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_svn_version_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.Int32 v;
			checkType(l,2,out v);
			self.svn_version_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_md5_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.md5_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_md5_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.String v;
			checkType(l,2,out v);
			self.md5_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_time_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.time_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_time_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			System.String v;
			checkType(l,2,out v);
			self.time_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_manifest_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.manifest_);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_manifest_(IntPtr l) {
		try {
			AssetBundles.AssetBundleSet self=(AssetBundles.AssetBundleSet)checkSelf(l);
			UnityEngine.AssetBundleManifest v;
			checkType(l,2,out v);
			self.manifest_=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"AssetBundles.AssetBundleSet");
		addMember(l,ReadSet);
		addMember(l,WriteSet);
		addMember(l,ReadVersion);
		addMember(l,WriteVersion);
		addMember(l,ReadManifest);
		addMember(l,Add);
		addMember(l,GetMD5);
		addMember(l,GetSize);
		addMember(l,"path_",get_path_,set_path_,true);
		addMember(l,"svn_version_",get_svn_version_,set_svn_version_,true);
		addMember(l,"md5_",get_md5_,set_md5_,true);
		addMember(l,"time_",get_time_,set_time_,true);
		addMember(l,"manifest_",get_manifest_,set_manifest_,true);
		AssetBundleSetManualWrap.reg(l);
		createTypeMetatable(l,constructor, typeof(AssetBundles.AssetBundleSet));
	}
}
