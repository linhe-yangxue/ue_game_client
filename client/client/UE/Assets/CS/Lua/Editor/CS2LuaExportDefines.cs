using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using SLua;
using Spine.Unity;
using Spine;

public class CS2LuaExportDefines : ICustomExportPost {
    // if uselist return a white list, don't check noUseList(black list) again
	public static void OnGetUseListUnityEngine(out List<Type> list)
    {
        list = new List<Type>
        {
            typeof(UnityEngine.Object),
            typeof(UnityEngine.Behaviour),
            typeof(UnityEngine.MonoBehaviour),
            typeof(UnityEngine.Transform),
            typeof(UnityEngine.GameObject),
            typeof(UnityEngine.Component),
            typeof(UnityEngine.Application),
            typeof(UnityEngine.Screen),
            typeof(UnityEngine.Camera),
            typeof(UnityEngine.Material),
            typeof(UnityEngine.MaterialPropertyBlock),
            typeof(UnityEngine.Renderer),
            typeof(UnityEngine.AsyncOperation),
            typeof(UnityEngine.AnimationClip),
            typeof(UnityEngine.AnimationEvent),
            typeof(UnityEngine.AnimationState),
            typeof(UnityEngine.Animator),
            typeof(UnityEngine.RuntimeAnimatorController),
            typeof(UnityEngine.AudioClip),
            typeof(UnityEngine.AudioSource),
            typeof(UnityEngine.AudioListener),
            typeof(UnityEngine.Physics),
            typeof(UnityEngine.RaycastHit),
            typeof(UnityEngine.Space),
            typeof(UnityEngine.CameraClearFlags),
            typeof(UnityEngine.RenderSettings),
            typeof(UnityEngine.Animation),
            typeof(UnityEngine.WrapMode),
            typeof(UnityEngine.QueueMode),
            typeof(UnityEngine.PlayMode),
            typeof(UnityEngine.AnimationBlendMode),
            typeof(UnityEngine.Profiling.Profiler),
            typeof(UnityEngine.PlayerPrefs),
            typeof(UnityEngine.QualitySettings),
            typeof(UnityEngine.BlendWeights),
            typeof(UnityEngine.Time),
            typeof(UnityEngine.TextAsset),
            typeof(UnityEngine.Shader),
            typeof(UnityEngine.Sprite),
            typeof(UnityEngine.LayerMask),
            typeof(UnityEngine.Texture),
            typeof(UnityEngine.Texture2D),
            typeof(UnityEngine.SystemInfo),
            typeof(UnityEngine.AI.NavMesh),
            typeof(UnityEngine.SpriteRenderer),
            typeof(UnityEngine.TextMesh),

            typeof(UnityEngine.Input),
            typeof(UnityEngine.KeyCode),
            typeof(UnityEngine.Touch),
            typeof(UnityEngine.TouchPhase),
            typeof(UnityEngine.Canvas),
            typeof(UnityEngine.TouchScreenKeyboard),

            typeof(UnityEngine.Rect),
            typeof(UnityEngine.RectTransform),
            typeof(UnityEngine.RectOffset),
            typeof(UnityEngine.RenderTexture),
            typeof(UnityEngine.CanvasGroup),
            typeof(UnityEngine.TextAnchor),
            typeof(UnityEngine.RectTransformUtility),
        };
    }

	public static void OnGetUseListUnityUI(out List<Type> list) {
		list = new List<Type> {
			typeof(UnityEngine.UI.Selectable),
			typeof(UnityEngine.UI.Toggle),
            typeof(UnityEngine.UI.ToggleGroup),
			typeof(UnityEngine.UI.Button),
			typeof(UnityEngine.UI.InputField),
			typeof(UnityEngine.UI.Graphic),
			typeof(UnityEngine.UI.MaskableGraphic),
			typeof(UnityEngine.UI.Image),
			typeof(UnityEngine.UI.RawImage),
			typeof(UnityEngine.UI.VerticalLayoutGroup),
            typeof(UnityEngine.UI.HorizontalLayoutGroup),
            typeof(UnityEngine.UI.HorizontalOrVerticalLayoutGroup),
            typeof(UnityEngine.UI.LayoutGroup),
            typeof(UnityEngine.UI.GridLayoutGroup),
			typeof(UnityEngine.UI.Text),
            typeof(UnityEngine.UI.Slider),
			typeof(UnityEngine.UI.LayoutElement),
            typeof(UnityEngine.UI.ContentSizeFitter),
            typeof(UnityEngine.UI.Scrollbar),
            typeof(UnityEngine.UI.ScrollRect),
            typeof(UnityEngine.UI.Mask),
        };
	}

    // 在Make Custom时调用
    public static void OnAddCustomClass(LuaCodeGen.ExportGenericDelegate add)
    {
        add(typeof(Debugger), null);
        add(typeof(GameEventMgr), null);
        add(typeof(GameEventInput), null);
        // add(typeof(GameUnitController), null);
        add(typeof(NativeAppUtils), null);
        add(typeof(LoadOperationBase), null);
        add(typeof(AssetBundles.ABLoadOptBase), null);
        add(typeof(AssetBundles.ABLoadSimulationOpt), null);
        add(typeof(AssetBundles.ABLoadSubAssetOpt), null);
        add(typeof(AssetBundles.AssetBundleSet), null);
        add(typeof(AssetBundles.AssetBundleConst), null);
        add(typeof(GameResourceMgr), null);
        // add(typeof(NetWorkUtil), null);
        add(typeof(UICamera), null);
        add(typeof(UISpellCooldown), null);
        // add(typeof(TL.Timeline), null);
        // add(typeof(TL.TimelinePlayer), null);
        add(typeof(UIHudText), null);
        // add(typeof(DrawMesh), null);
        add(typeof(TipMsgItem), null);
        add(typeof(UILoopListView), null);
        add(typeof(UITreeView), null);
        add(typeof(UITreeNodeData), null);
        add(typeof(UISwipeView), null);
        add(typeof(UISlideSelect), null);
        // add(typeof(ModelCombine), null);
        // add(typeof(FACE.FaceAsset), null);
        // add(typeof(GameUnit.Face.FaceAsset), null);
        // add(typeof(GameUnit.Skeleton.SkeletonAsset), null);
        add(typeof(UIColorPicker), null);
        // add(typeof(PostProcessMgr), null);
        // add(typeof(PostProcessSetting), null);
        // add(typeof(GameSkybox), null);
        add(typeof(UIAnimPosition), null);
        add(typeof(UIActivityEffect), null);
        // add(typeof(GameSceneMgr), null);
        add(typeof(UIFollowTarget2D), null);
        add(typeof(UIChatSwipeView), null);
        add(typeof(GuideMask), null);
        add(typeof(UIDynamicList), null);
        add(typeof(UIAnimReciveRes), null);
        add(typeof(UIScrollListView), null);
        add(typeof(AimPoint), null);
        add(typeof(UICaptureScreen), null);
        //spine
        add(typeof(Spine.AnimationState), null);
        add(typeof(SkeletonGraphic), null);
        add(typeof(MeshRenderer), null);
        add(typeof(SkeletonAnimation), null);
        add(typeof(SkeletonRenderer), null);

        add(typeof(SkeletonGraphicGhost), null);
        add(typeof(EffectAnimBase), null);
        add(typeof(TextPic),null);
        add(typeof(EffectLine), null);
        add(typeof(UIAnimBase), null);
        add(typeof(UIAnimAlpha), null);
        // --- tween begin ----
        // add(typeof(Tweening.Tween), null);
        // add(typeof(Tweening.Tweener), null);
        // add(typeof(Tweening.Sequence), null);
        // add(typeof(Tweening.LoopType), null);
        // add(typeof(Tweening.Ease), null);

        add(typeof(UITweenBase), null);
        add(typeof(UITweenPosition), null);
        add(typeof(UITweenScale), null);
        add(typeof(UITweenAlpha), null);
        // --- tween end ----
        add(typeof(SDK), null);
    }

    public static List<string> FunctionFilterList = new List<string>()
    {
            "UnityEngine.Physics.OverlapCapsuleNonAlloc",
            "UnityEngine.Physics.OverlapBoxNonAlloc",
            "UnityEngine.Physics.OverlapSphereNonAlloc",
            "UnityEngine.QualitySettings.streamingMipmapsRenderersPerFrame",
    };
}
