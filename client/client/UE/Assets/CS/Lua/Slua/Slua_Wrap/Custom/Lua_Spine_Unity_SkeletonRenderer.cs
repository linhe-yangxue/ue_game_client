using System;
using SLua;
using System.Collections.Generic;
[UnityEngine.Scripting.Preserve]
public class Lua_Spine_Unity_SkeletonRenderer : LuaObject {
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int SetSkeletonFlip(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int SetMeshSettings(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			Spine.Unity.MeshGenerator.Settings a1;
			checkValueType(l,2,out a1);
			self.SetMeshSettings(a1);
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int Awake(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			self.Awake();
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int ClearState(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int EnsureMeshGeneratorCapacity(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Int32 a1;
			checkType(l,2,out a1);
			self.EnsureMeshGeneratorCapacity(a1);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int LateUpdate(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int NewSpineGameObject_s(IntPtr l) {
		try {
			Spine.Unity.SkeletonDataAsset a1;
			checkType(l,1,out a1);
			var ret=Spine.Unity.SkeletonRenderer.NewSpineGameObject<Spine.Unity.SkeletonRenderer>(a1);
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
	static public int AddSpineComponent_s(IntPtr l) {
		try {
			UnityEngine.GameObject a1;
			checkType(l,1,out a1);
			Spine.Unity.SkeletonDataAsset a2;
			checkType(l,2,out a2);
			var ret=Spine.Unity.SkeletonRenderer.AddSpineComponent<Spine.Unity.SkeletonRenderer>(a1,a2);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int get_separatorSlotNames(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.separatorSlotNames);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_separatorSlotNames(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.String[] v;
			checkArray(l,2,out v);
			self.separatorSlotNames=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_separatorSlots(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.separatorSlots);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_zSpacing(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.zSpacing);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_zSpacing(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Single v;
			checkType(l,2,out v);
			self.zSpacing=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_useClipping(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.useClipping);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_useClipping(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.useClipping=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_immutableTriangles(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.immutableTriangles);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_immutableTriangles(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.immutableTriangles=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_pmaVertexColors(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.pmaVertexColors);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_pmaVertexColors(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.pmaVertexColors=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_clearStateOnDisable(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.clearStateOnDisable);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_clearStateOnDisable(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.clearStateOnDisable=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_tintBlack(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.tintBlack);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_tintBlack(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.tintBlack=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_singleSubmesh(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.singleSubmesh);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_singleSubmesh(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.singleSubmesh=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_addNormals(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.addNormals);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_addNormals(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.addNormals=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_calculateTangents(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.calculateTangents);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_calculateTangents(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.calculateTangents=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_logErrors(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.logErrors);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_logErrors(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.logErrors=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_disableRenderingOnOverride(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.disableRenderingOnOverride);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_disableRenderingOnOverride(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.disableRenderingOnOverride=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_valid(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.valid);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_valid(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			System.Boolean v;
			checkType(l,2,out v);
			self.valid=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_skeleton(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.skeleton);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_skeleton(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			Spine.Skeleton v;
			checkType(l,2,out v);
			self.skeleton=v;
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int get_CustomMaterialOverride(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.CustomMaterialOverride);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int get_CustomSlotMaterials(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.CustomSlotMaterials);
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
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
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
	static public int get_Color(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			pushValue(l,true);
			pushValue(l,self.Color);
			return 2;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	[UnityEngine.Scripting.Preserve]
	static public int set_Color(IntPtr l) {
		try {
			Spine.Unity.SkeletonRenderer self=(Spine.Unity.SkeletonRenderer)checkSelf(l);
			UnityEngine.Color v;
			checkType(l,2,out v);
			self.Color=v;
			pushValue(l,true);
			return 1;
		}
		catch(Exception e) {
			return error(l,e);
		}
	}
	[UnityEngine.Scripting.Preserve]
	static public void reg(IntPtr l) {
		getTypeTable(l,"Spine.Unity.SkeletonRenderer");
		addMember(l,SetSkeletonFlip);
		addMember(l,SetMeshSettings);
		addMember(l,Awake);
		addMember(l,ClearState);
		addMember(l,EnsureMeshGeneratorCapacity);
		addMember(l,Initialize);
		addMember(l,LateUpdate);
		addMember(l,NewSpineGameObject_s);
		addMember(l,AddSpineComponent_s);
		addMember(l,"skeletonDataAsset",get_skeletonDataAsset,set_skeletonDataAsset,true);
		addMember(l,"initialSkinName",get_initialSkinName,set_initialSkinName,true);
		addMember(l,"initialFlipX",get_initialFlipX,set_initialFlipX,true);
		addMember(l,"initialFlipY",get_initialFlipY,set_initialFlipY,true);
		addMember(l,"separatorSlotNames",get_separatorSlotNames,set_separatorSlotNames,true);
		addMember(l,"separatorSlots",get_separatorSlots,null,true);
		addMember(l,"zSpacing",get_zSpacing,set_zSpacing,true);
		addMember(l,"useClipping",get_useClipping,set_useClipping,true);
		addMember(l,"immutableTriangles",get_immutableTriangles,set_immutableTriangles,true);
		addMember(l,"pmaVertexColors",get_pmaVertexColors,set_pmaVertexColors,true);
		addMember(l,"clearStateOnDisable",get_clearStateOnDisable,set_clearStateOnDisable,true);
		addMember(l,"tintBlack",get_tintBlack,set_tintBlack,true);
		addMember(l,"singleSubmesh",get_singleSubmesh,set_singleSubmesh,true);
		addMember(l,"addNormals",get_addNormals,set_addNormals,true);
		addMember(l,"calculateTangents",get_calculateTangents,set_calculateTangents,true);
		addMember(l,"logErrors",get_logErrors,set_logErrors,true);
		addMember(l,"disableRenderingOnOverride",get_disableRenderingOnOverride,set_disableRenderingOnOverride,true);
		addMember(l,"valid",get_valid,set_valid,true);
		addMember(l,"skeleton",get_skeleton,set_skeleton,true);
		addMember(l,"SkeletonDataAsset",get_SkeletonDataAsset,null,true);
		addMember(l,"CustomMaterialOverride",get_CustomMaterialOverride,null,true);
		addMember(l,"CustomSlotMaterials",get_CustomSlotMaterials,null,true);
		addMember(l,"Skeleton",get_Skeleton,null,true);
		addMember(l,"Color",get_Color,set_Color,true);
		createTypeMetatable(l,null, typeof(Spine.Unity.SkeletonRenderer),typeof(UnityEngine.MonoBehaviour));
	}
}
