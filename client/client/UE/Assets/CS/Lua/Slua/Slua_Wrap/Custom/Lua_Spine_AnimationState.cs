using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_Spine_AnimationState : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int constructor(IntPtr l) {
		try {
			Spine.AnimationState o;
			Spine.AnimationStateData a1;
			checkType(l,2,out a1);
			o=new Spine.AnimationState(a1);
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
	static public int Update(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
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
	static public int Apply(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			Spine.Skeleton a1;
			checkType(l,2,out a1);
			var ret=self.Apply(a1);
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
	static public int ClearTracks(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			self.ClearTracks();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ClearTrack(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.ClearTrack(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetAnimation(IntPtr l) {
		try {
			int argc = LuaDLL.lua_gettop(l);
			if(matchType(l,argc,2,typeof(int),typeof(Spine.Animation),typeof(bool))){
				Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
				System.Int32 a1;
				checkType(l,2,out a1);
				Spine.Animation a2;
				checkType(l,3,out a2);
				System.Boolean a3;
				checkType(l,4,out a3);
				var ret=self.SetAnimation(a1,a2,a3);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(matchType(l,argc,2,typeof(int),typeof(string),typeof(bool))){
				Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
				System.Int32 a1;
				checkType(l,2,out a1);
				System.String a2;
				checkType(l,3,out a2);
				System.Boolean a3;
				checkType(l,4,out a3);
				var ret=self.SetAnimation(a1,a2,a3);
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
	static public int PlayAnimation(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.String a2;
			checkType(l,3,out a2);
			System.Boolean a3;
			checkType(l,4,out a3);
			System.Single a4;
			checkType(l,5,out a4);
			var ret=self.PlayAnimation(a1,a2,a3,a4);
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
	static public int AddAnimation(IntPtr l) {
		try {
			int argc = LuaDLL.lua_gettop(l);
			if(matchType(l,argc,2,typeof(int),typeof(Spine.Animation),typeof(bool),typeof(float))){
				Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
				System.Int32 a1;
				checkType(l,2,out a1);
				Spine.Animation a2;
				checkType(l,3,out a2);
				System.Boolean a3;
				checkType(l,4,out a3);
				System.Single a4;
				checkType(l,5,out a4);
				var ret=self.AddAnimation(a1,a2,a3,a4);
				pushValue(l,true);
				pushValue(l,ret);
				return 2;
			}
			else if(matchType(l,argc,2,typeof(int),typeof(string),typeof(bool),typeof(float))){
				Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
				System.Int32 a1;
				checkType(l,2,out a1);
				System.String a2;
				checkType(l,3,out a2);
				System.Boolean a3;
				checkType(l,4,out a3);
				System.Single a4;
				checkType(l,5,out a4);
				var ret=self.AddAnimation(a1,a2,a3,a4);
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
	static public int GetAnimDuration(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.String a1;
			checkType(l,2,out a1);
			var ret=self.GetAnimDuration(a1);
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
	static public int AddAnim(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.String a2;
			checkType(l,3,out a2);
			System.Boolean a3;
			checkType(l,4,out a3);
			System.Single a4;
			checkType(l,5,out a4);
			System.Single a5;
			checkType(l,6,out a5);
			var ret=self.AddAnim(a1,a2,a3,a4,a5);
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
	static public int SetEmptyAnimation(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Single a2;
			checkType(l,3,out a2);
			var ret=self.SetEmptyAnimation(a1,a2);
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
	static public int AddEmptyAnimation(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			System.Single a2;
			checkType(l,3,out a2);
			System.Single a3;
			checkType(l,4,out a3);
			var ret=self.AddEmptyAnimation(a1,a2,a3);
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
	static public int SetEmptyAnimations(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Single a1;
			checkType(l,2,out a1);
			self.SetEmptyAnimations(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetCurrent(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			var ret=self.GetCurrent(a1);
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
	static public int get_Data(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.Data);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_Tracks(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.Tracks);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_TimeScale(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.TimeScale);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_TimeScale(IntPtr l) {
		try {
			Spine.AnimationState self=(Spine.AnimationState)checkSelf(l);
			float v;
			checkType(l,2,out v);
			self.TimeScale=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"Spine.AnimationState");
		addMember(l,Update);
		addMember(l,Apply);
		addMember(l,ClearTracks);
		addMember(l,ClearTrack);
		addMember(l,SetAnimation);
		addMember(l,PlayAnimation);
		addMember(l,AddAnimation);
		addMember(l,GetAnimDuration);
		addMember(l,AddAnim);
		addMember(l,SetEmptyAnimation);
		addMember(l,AddEmptyAnimation);
		addMember(l,SetEmptyAnimations);
		addMember(l,GetCurrent);
		addMember(l,"Data",get_Data,null,true);
		addMember(l,"Tracks",get_Tracks,null,true);
		addMember(l,"TimeScale",get_TimeScale,set_TimeScale,true);
		createTypeMetatable(l,constructor, typeof(Spine.AnimationState));
	}
}
