Shader "Game/Effect/Add 2Tex"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        _ZOffset ("_ZOffset", Range(-1, 1)) = 0
        _Cull ("_Cull", Range(0, 2)) = 0
        [HDR]
        _Color2 ("_Color2", Color) = (1,1,1,1)
        _MainTex2 ("_MainTex2", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane"}
        Cull [_Cull] Lighting Off ZWrite Off
        Blend SrcAlpha One

        Pass
        {
            CGPROGRAM
            #pragma vertex GameEffect2TexVert
            #pragma fragment GameEffect2TexFrag
            #pragma multi_compile_fog
            #define ADD_MODE
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
