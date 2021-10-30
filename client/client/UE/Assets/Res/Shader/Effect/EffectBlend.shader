Shader "Game/Effect/Blend"
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
            CGPROGRAM
            #pragma vertex GameEffectVert
            #pragma fragment GameEffectFrag
            #pragma multi_compile_fog
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
