Shader "Game/Effect/RimLight Blend"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        [HDR]
        _ColorIn ("_ColorIn", Color) = (1,1,1,0)
        [HDR]
        _ColorOut ("_ColorOut", Color) = (1,1,1,1)
        [PowerSlider(2)]_Blend ("_Blend", Range(0, 10)) = 1
        _ZOffset ("_ZOffset", Range(-1, 1)) = 0
        _Cull ("_Cull", Range(0, 2)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "PreviewType"="Sphere"}
        Cull [_Cull] Lighting Off ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex GameEffectRimLightVert
            #pragma fragment GameEffectRimLightFrag
            #pragma multi_compile_fog
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
