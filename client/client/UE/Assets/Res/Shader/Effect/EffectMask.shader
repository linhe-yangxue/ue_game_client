Shader "Game/Effect/Mask"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        _Clip ("_Clip", Range(0, 1)) = 0.5
        _ZOffset ("_ZOffset", Range(-1, 1)) = 0
        _Cull("_Cull", Range(0, 2)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "IgnoreProjector"="True" "PreviewType"="Plane"}
        Cull[_Cull] Lighting Off ZWrite On

        Pass
        {
            CGPROGRAM
            #pragma vertex GameEffectVert
            #pragma fragment GameEffectFrag
            #pragma multi_compile_fog
            #define MASK_MODE
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
