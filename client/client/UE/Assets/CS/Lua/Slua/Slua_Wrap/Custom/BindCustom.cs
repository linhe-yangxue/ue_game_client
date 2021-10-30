using System;
using System.Collections.Generic;
namespace SLua {
	[LuaBinder(3)]
	public class BindCustom {
		public static Action<IntPtr>[] GetBindList() {
			Action<IntPtr>[] list= {
				Lua_Debugger.reg,
				Lua_GameEventMgr.reg,
				Lua_GameEventInput.reg,
				Lua_NativeAppUtils.reg,
				Lua_LoadOperationBase.reg,
				Lua_AssetBundles_ABLoadOptBase.reg,
				Lua_AssetBundles_ABLoadSimulationOpt.reg,
				Lua_AssetBundles_ABLoadSubAssetOpt.reg,
				Lua_AssetBundles_AssetBundleSet.reg,
				Lua_AssetBundles_AssetBundleConst.reg,
				Lua_GameResourceMgr.reg,
				Lua_UICamera.reg,
				Lua_UISpellCooldown.reg,
				Lua_UIHudText.reg,
				Lua_TipMsgItem.reg,
				Lua_UILoopListView.reg,
				Lua_UITreeView.reg,
				Lua_UITreeNodeData.reg,
				Lua_UISwipeView.reg,
				Lua_UISlideSelect.reg,
				Lua_UIColorPicker.reg,
				Lua_UIAnimBase.reg,
				Lua_UIAnimPosition.reg,
				Lua_UIActivityEffect.reg,
				Lua_UIFollowTarget2D.reg,
				Lua_UIChatSwipeView.reg,
				Lua_GuideMask.reg,
				Lua_UIDynamicList.reg,
				Lua_UIAnimReciveRes.reg,
				Lua_UIScrollListView.reg,
				Lua_AimPoint.reg,
				Lua_UICaptureScreen.reg,
				Lua_Spine_AnimationState.reg,
				Lua_Spine_Unity_SkeletonGraphic.reg,
				Lua_UnityEngine_MeshRenderer.reg,
				Lua_Spine_Unity_SkeletonRenderer.reg,
				Lua_Spine_Unity_SkeletonAnimation.reg,
				Lua_SkeletonGraphicGhost.reg,
				Lua_EffectAnimBase.reg,
				Lua_TextPic.reg,
				Lua_EffectLine.reg,
				Lua_UIAnimAlpha.reg,
				Lua_UITweenBase.reg,
				Lua_UITweenPosition.reg,
				Lua_UITweenScale.reg,
				Lua_UITweenAlpha.reg,
				Lua_SDK.reg,
				GameEntryManualWrap.reg,
				MockSslManualWrap.reg,
			};
			return list;
		}
	}
}
