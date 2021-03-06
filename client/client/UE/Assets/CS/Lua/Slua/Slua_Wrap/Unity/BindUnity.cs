using System;
using System.Collections.Generic;
namespace SLua {
	[LuaBinder(0)]
	public class BindUnity {
		public static Action<IntPtr>[] GetBindList() {
			Action<IntPtr>[] list= {
				Lua_UnityEngine_Object.reg,
				Lua_UnityEngine_Component.reg,
				Lua_UnityEngine_Behaviour.reg,
				Lua_UnityEngine_MonoBehaviour.reg,
				Lua_UnityEngine_Transform.reg,
				Lua_UnityEngine_GameObject.reg,
				Lua_UnityEngine_Application.reg,
				Lua_UnityEngine_Screen.reg,
				Lua_UnityEngine_Camera.reg,
				Lua_UnityEngine_Material.reg,
				Lua_UnityEngine_MaterialPropertyBlock.reg,
				Lua_UnityEngine_Renderer.reg,
				Lua_UnityEngine_AsyncOperation.reg,
				Lua_UnityEngine_AnimationClip.reg,
				Lua_UnityEngine_AnimationEvent.reg,
				Lua_UnityEngine_AnimationState.reg,
				Lua_UnityEngine_Animator.reg,
				Lua_UnityEngine_RuntimeAnimatorController.reg,
				Lua_UnityEngine_AudioClip.reg,
				Lua_UnityEngine_AudioSource.reg,
				Lua_UnityEngine_AudioListener.reg,
				Lua_UnityEngine_Physics.reg,
				Lua_UnityEngine_RaycastHit.reg,
				Lua_UnityEngine_Space.reg,
				Lua_UnityEngine_CameraClearFlags.reg,
				Lua_UnityEngine_RenderSettings.reg,
				Lua_UnityEngine_Animation.reg,
				Lua_UnityEngine_WrapMode.reg,
				Lua_UnityEngine_QueueMode.reg,
				Lua_UnityEngine_PlayMode.reg,
				Lua_UnityEngine_AnimationBlendMode.reg,
				Lua_UnityEngine_Profiling_Profiler.reg,
				Lua_UnityEngine_PlayerPrefs.reg,
				Lua_UnityEngine_QualitySettings.reg,
				Lua_UnityEngine_BlendWeights.reg,
				Lua_UnityEngine_Time.reg,
				Lua_UnityEngine_TextAsset.reg,
				Lua_UnityEngine_Shader.reg,
				Lua_UnityEngine_Sprite.reg,
				Lua_UnityEngine_LayerMask.reg,
				Lua_UnityEngine_Texture.reg,
				Lua_UnityEngine_Texture2D.reg,
				Lua_UnityEngine_SystemInfo.reg,
				Lua_UnityEngine_AI_NavMesh.reg,
				Lua_UnityEngine_SpriteRenderer.reg,
				Lua_UnityEngine_TextMesh.reg,
				Lua_UnityEngine_Input.reg,
				Lua_UnityEngine_KeyCode.reg,
				Lua_UnityEngine_Touch.reg,
				Lua_UnityEngine_TouchPhase.reg,
				Lua_UnityEngine_Canvas.reg,
				Lua_UnityEngine_TouchScreenKeyboard.reg,
				Lua_UnityEngine_Rect.reg,
				Lua_UnityEngine_RectTransform.reg,
				Lua_UnityEngine_RectOffset.reg,
				Lua_UnityEngine_RenderTexture.reg,
				Lua_UnityEngine_CanvasGroup.reg,
				Lua_UnityEngine_TextAnchor.reg,
				Lua_UnityEngine_RectTransformUtility.reg,
			};
			return list;
		}
	}
}
