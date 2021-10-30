using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_Spine_Unity_SkeletonGraphic : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Rebuild(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			UnityEngine.UI.CanvasUpdate a1;
			checkEnum(l,2,out a1);
			self.Rebuild(a1);
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
			int argc = LuaDLL.lua_gettop(l);
			if(argc==1){
				Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
				self.Update();
				pushValue(l,true);
				return 1;
			}
			else if(argc==2){
				Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
				System.Single a1;
				checkType(l,2,out a1);
				self.Update(a1);
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
	static public int LateUpdate(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			self.LateUpdate();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int GetLastMesh(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			var ret=self.GetLastMesh();
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
	static public int Clear(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			self.Clear();
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
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
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
	static public int SetSkeletonFlip(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.Boolean a1;
			checkType(l,2,out a1);
			System.Boolean a2;
			checkType(l,3,out a2);
			self.SetSkeletonFlip(a1,a2);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int UpdateMesh(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			self.UpdateMesh();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int NewSkeletonGraphicGameObject_s(IntPtr l) {
		try {
			Spine.Unity.SkeletonDataAsset a1;
			checkType(l,1,out a1);
			UnityEngine.Transform a2;
			checkType(l,2,out a2);
			var ret=Spine.Unity.SkeletonGraphic.NewSkeletonGraphicGameObject(a1,a2);
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
	static public int AddSkeletonGraphicComponent_s(IntPtr l) {
		try {
			UnityEngine.GameObject a1;
			checkType(l,1,out a1);
			Spine.Unity.SkeletonDataAsset a2;
			checkType(l,2,out a2);
			var ret=Spine.Unity.SkeletonGraphic.AddSkeletonGraphicComponent(a1,a2);
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
	static public int get_skeletonDataAsset(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.skeletonDataAsset);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_skeletonDataAsset(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			Spine.Unity.SkeletonDataAsset v;
			checkType(l,2,out v);
			self.skeletonDataAsset=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_initialSkinName(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.initialSkinName);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_initialSkinName(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.String v;
			checkType(l,2,out v);
			self.initialSkinName=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_initialFlipX(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.initialFlipX);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_initialFlipX(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.initialFlipX=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_initialFlipY(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.initialFlipY);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_initialFlipY(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.initialFlipY=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_startingAnimation(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.startingAnimation);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_startingAnimation(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.String v;
			checkType(l,2,out v);
			self.startingAnimation=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_startingLoop(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.startingLoop);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_startingLoop(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.startingLoop=v;
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
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
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
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
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
	static public int get_freeze(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.freeze);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_freeze(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.freeze=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_unscaledTime(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.unscaledTime);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_unscaledTime(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.unscaledTime=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_SkeletonDataAsset(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.SkeletonDataAsset);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_OverrideTexture(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.OverrideTexture);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_OverrideTexture(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			UnityEngine.Texture v;
			checkType(l,2,out v);
			self.OverrideTexture=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_mainTexture(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.mainTexture);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_Skeleton(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.Skeleton);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_SkeletonData(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.SkeletonData);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_IsValid(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.IsValid);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_AnimationState(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
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
	static public int get_MeshGenerator(IntPtr l) {
		try {
			Spine.Unity.SkeletonGraphic self=(Spine.Unity.SkeletonGraphic)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.MeshGenerator);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"Spine.Unity.SkeletonGraphic");
		addMember(l,Rebuild);
		addMember(l,Update);
		addMember(l,LateUpdate);
		addMember(l,GetLastMesh);
		addMember(l,Clear);
		addMember(l,Initialize);
		addMember(l,SetSkeletonFlip);
		addMember(l,UpdateMesh);
		addMember(l,NewSkeletonGraphicGameObject_s);
		addMember(l,AddSkeletonGraphicComponent_s);
		addMember(l,"skeletonDataAsset",get_skeletonDataAsset,set_skeletonDataAsset,true);
		addMember(l,"initialSkinName",get_initialSkinName,set_initialSkinName,true);
		addMember(l,"initialFlipX",get_initialFlipX,set_initialFlipX,true);
		addMember(l,"initialFlipY",get_initialFlipY,set_initialFlipY,true);
		addMember(l,"startingAnimation",get_startingAnimation,set_startingAnimation,true);
		addMember(l,"startingLoop",get_startingLoop,set_startingLoop,true);
		addMember(l,"timeScale",get_timeScale,set_timeScale,true);
		addMember(l,"freeze",get_freeze,set_freeze,true);
		addMember(l,"unscaledTime",get_unscaledTime,set_unscaledTime,true);
		addMember(l,"SkeletonDataAsset",get_SkeletonDataAsset,null,true);
		addMember(l,"OverrideTexture",get_OverrideTexture,set_OverrideTexture,true);
		addMember(l,"mainTexture",get_mainTexture,null,true);
		addMember(l,"Skeleton",get_Skeleton,null,true);
		addMember(l,"SkeletonData",get_SkeletonData,null,true);
		addMember(l,"IsValid",get_IsValid,null,true);
		addMember(l,"AnimationState",get_AnimationState,null,true);
		addMember(l,"MeshGenerator",get_MeshGenerator,null,true);
		createTypeMetatable(l,null, typeof(Spine.Unity.SkeletonGraphic),typeof(UnityEngine.UI.MaskableGraphic));
	}
}
