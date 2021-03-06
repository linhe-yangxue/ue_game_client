Shader "Game/Effect/Blend Lit"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        _ZOffset ("_ZOffset", Range(-1, 1)) = 0
        _Cull ("_Cull", Range(0, 2)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane"}
        Cull [_Cull] Lighting Off ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
			Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile _ DIRECTIONAL
            #pragma multi_compile_fog

            #include "../CGInclude/GameEffect.cginc"

            #pragma vertex GameEffectLitVert
            #pragma fragment GameEffectLitFrag
            ENDCG
        }
    }
}
