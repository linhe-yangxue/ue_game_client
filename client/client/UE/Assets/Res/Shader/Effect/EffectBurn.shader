Shader "Game/Effect/Burn"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        _ZOffset ("_ZOffset", Range(-1, 1)) = 0
        _Cull ("_Cull", Range(0, 2)) = 0
        [HDR]
        _MainTex2 ("_MainTex2", 2D) = "white" {}
        [HDR]
        _BurnColor ("_BurnColor", Color) = (1,1,1,1)
        _BurnTex ("_BurnTex", 2D) = "white" {}
        _BurnWidth ("_BurnWidth", Range(0, 10)) = 3

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane"}
        Cull [_Cull] Lighting Off ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha


        Pass
        {
            CGPROGRAM
            #pragma vertex GameEffectBurnVert
            #pragma fragment GameEffectBurnFrag
            #pragma multi_compile_fog
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
