Shader "Game/Effect/Rotate"
{
    Properties
    {
        [HDR]
        _Color ("_Color", Color) = (1,1,1,1)
        _MainTex ("_MainTex", 2D) = "white" {}
        [PowerSlider(2)]_RotateAngle ("_RotateAngle", Range(-50, 50)) = 0
        _RotateOffset ("_RotateOffset", Range(0, 2)) = 1
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
            #pragma fragment GameEffectRotateFrag
            #pragma multi_compile_fog
            #include "../CGInclude/GameEffect.cginc"
            ENDCG
        }
    }
}
