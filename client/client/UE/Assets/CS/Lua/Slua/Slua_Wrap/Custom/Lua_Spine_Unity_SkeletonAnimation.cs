using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_Spine_Unity_SkeletonAnimation : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ClearState(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			self.ClearState();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Initialize(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			System.Boolean a1;
			checkType(l,2,out a1);
			self.Initialize(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Update(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.Update(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int AddToGameObject_s(IntPtr l) {
		try {
			UnityEngine.GameObject a1;
			checkType(l,1,out a1);
			Spine.Unity.SkeletonDataAsset a2;
			checkType(l,2,out a2);
			var ret=Spine.Unity.SkeletonAnimation.AddToGameObject(a1,a2);
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
	static public int NewSkeletonAnimationGameObject_s(IntPtr l) {
		try {
			Spine.Unity.SkeletonDataAsset a1;
			checkType(l,1,out a1);
			var ret=Spine.Unity.SkeletonAnimation.NewSkeletonAnimationGameObject(a1);
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
	static public int get_state(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.state);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_state(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			Spine.AnimationState v;
			checkType(l,2,out v);
			self.state=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_loop(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.loop);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_loop(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.loop=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_timeScale(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.timeScale);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_timeScale(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.timeScale=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_AnimationState(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.AnimationState);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_AnimationName(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.AnimationName);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_AnimationName(IntPtr l) {
		try {
			Spine.Unity.SkeletonAnimation self=(Spine.Unity.SkeletonAnimation)checkSelf(l);
			string v;
			checkType(l,2,out v);
			self.AnimationName=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"Spine.Unity.SkeletonAnimation");
		addMember(l,ClearState);
		addMember(l,Initialize);
		addMember(l,Update);
		addMember(l,AddToGameObject_s);
		addMember(l,NewSkeletonAnimationGameObject_s);
		addMember(l,"state",get_state,set_state,true);
		addMember(l,"loop",get_loop,set_loop,true);
		addMember(l,"timeScale",get_timeScale,set_timeScale,true);
		addMember(l,"AnimationState",get_AnimationState,null,true);
		addMember(l,"AnimationName",get_AnimationName,set_AnimationName,true);
		createTypeMetatable(l,null, typeof(Spine.Unity.SkeletonAnimation),typeof(Spine.Unity.SkeletonRenderer));
	}
}
