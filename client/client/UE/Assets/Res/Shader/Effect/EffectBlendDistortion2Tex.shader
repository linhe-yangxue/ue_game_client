// Upgrade NOTE: replaced 'defined _MODE_BLEND' with 'defined (_MODE_BLEND)'


Shader "Game/Effect/Blend Distortion 2Tex"
{
	Properties
	{
		[HDR]
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("_MainTex", 2D) = "white" {}
		_ZOffset("_ZOffset", Range(-1, 1)) = 0
		[Enum(No, 0, Front, 1, Back, 2)]
		_Cull("_Cull", Float) = 0
		//
		_MainTex2("法线贴图表示UV扭曲", 2D) = "bump" {}
		[PowerSlider(2)]
		_DistortionScaleX("_DistortionScaleX", Range(-5, 5)) = 1
		[PowerSlider(2)]
		_DistortionScaleY("_DistortionScaleY", Range(-5, 5)) = 1
	}
		SubShader
		{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "PreviewType" = "Plane" }
		Cull[_Cull] Lighting Off ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex Distortion2TexVert
			#pragma fragment Distortion2TexFrag
			#pragma multi_compile_fog
			#include "../CGInclude/GameEffect.cginc"
			ENDCG
		}
	}
}
