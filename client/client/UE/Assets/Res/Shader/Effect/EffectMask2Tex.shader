Shader "Game/Effect/Mask 2Tex"
{
    Properties
    {
        [HDR]
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        _Clip("_Clip", Range(0, 1)) = 0.5
        _ZOffset ("_ZOffset", Range(-1, 1)) = 0
        _Cull ("_Cull", Range(0, 2)) = 0
        [HDR]
        _Color2 ("_Color2", Color) = (1,1,1,1)
        _MainTex2 ("_MainTex2", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane"}
        Cull [_Cull] Lighting Off ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma vertex GameEffect2TexVert
            #pragma fragment GameEffect2TexFrag
            #pragma multi_compile_fog
            #define MASK_MODE
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
