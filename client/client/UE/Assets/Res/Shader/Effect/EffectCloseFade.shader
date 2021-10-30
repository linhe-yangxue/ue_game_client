Shader "Game/Effect/Close Fade"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        _FadeDistanceStart ("_FadeDistanceStart 开始消失距离", Range(0, 100)) = 10
        _FadeDistanceEnd ("_FadeDistanceEnd 完全消失距离", Range(0, 100)) = 5
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
            CGPROGRAM
            #pragma vertex GameEffectCloseFadeVert
            #pragma fragment GameEffectCloseFadeFrag
            #pragma multi_compile_fog
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
