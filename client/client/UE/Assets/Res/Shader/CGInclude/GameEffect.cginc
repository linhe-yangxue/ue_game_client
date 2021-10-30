// Copyright (c) 2017 (limengbin)

#ifndef GAME_EFFECT_H
#define GAME_EFFECT_H

#include "UnityCG.cginc"
#include "../CGInclude/GameDefines.cginc"
#include "Lighting.cginc"

// --------------------------------
// param define
// --------------------------------

// base
half4 _Color;
float _ZOffset;
half _Clip;

// 2 tex
half4 _Color2;
sampler2D _MainTex2;
float4 _MainTex2_ST;

// Dissolution

// Burn
half4 _BurnColor;
sampler2D _BurnTex;
half _BurnWidth;

// Distortion
sampler2D _DistortionTex;
half _DistortionDir;

// RimLight
half4 _ColorIn;
half4 _ColorOut;
half _Blend;

// CloseFade
half _FadeDistanceStart;
half _FadeDistanceEnd;

//Distortion
half _DistortionScaleX;
half _DistortionScaleY;

// --------------------------------
// Common Define
// --------------------------------

#define EFFECT_BASE_V2F(idx) \
    float4 vertex : SV_POSITION;\
    half4 color : COLOR;\
    float2 texcoord : TEXCOORD0;\
    UNITY_FOG_COORDS(idx)

#define EFFECT_BASE_VERT \
    o.vertex = UnityObjectToClipPos(v.vertex);\
    GAME_TRANSFER_FOG(o, o.vertex); \
    o.vertex.z = GetOffsetZ(o.vertex, _ZOffset);\
    o.color = v.color * _Color;\
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

// --------------------------------
// impl
// --------------------------------

// base
struct GameEffectV2F {
    EFFECT_BASE_V2F(1)
};

GameEffectV2F GameEffectVert (gm_appdata_effect v)
{
    GameEffectV2F o;
    EFFECT_BASE_VERT;
    return o;
}

fixed4 GameEffectFrag(GameEffectV2F i) : SV_Target{
    fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;
#if defined(MASK_MODE)
    clip(col.a - _Clip);
#endif
    GAME_APPLY_FOG(i.fogCoord, col);
return col;
};

fixed4 GameEffectGammaFrag(GameEffectV2F i) : SV_Target{
    fixed4 col = tex2D(_MainTex, i.texcoord);
    //col.rgb = pow(col.rgb, 0.45h);
    col *= i.color;
#if defined(MASK_MODE)
    clip(col.a - _Clip);
#endif
    GAME_APPLY_FOG(i.fogCoord, col);
return col;
};

// 2 Tex
struct GameEffect2TexV2F {
    EFFECT_BASE_V2F(2)
    float2 texcoord2 : TEXCOORD1;
};

GameEffect2TexV2F GameEffect2TexVert (gm_appdata_effect v)
{
    GameEffect2TexV2F o;
    EFFECT_BASE_VERT;
    o.color *= _Color2;
    o.texcoord2 = TRANSFORM_TEX(v.texcoord,_MainTex2);
    return o;
}

fixed4 GameEffect2TexFrag (GameEffect2TexV2F i) : SV_Target {
    fixed4 col = tex2D(_MainTex, i.texcoord);
    fixed4 col2 = tex2D(_MainTex2, i.texcoord2);
    col = col * col2 * i.color;
#if defined(MASK_MODE)
    clip(col.a - _Clip);
#endif
    GAME_APPLY_FOG(i.fogCoord, col);
    return col;
};

// Dissolution
GameEffect2TexV2F GameEffectDissolutionVert (gm_appdata_effect v)
{
    GameEffect2TexV2F o;
    EFFECT_BASE_VERT;
    o.color.a = 1 - o.color.a;
    o.texcoord2 = TRANSFORM_TEX(v.texcoord,_MainTex2);
    return o;
}

fixed4 GameEffectDissolutionFrag (GameEffect2TexV2F i) : SV_Target {
    fixed4 col = tex2D(_MainTex, i.texcoord);
    col.rgb *= i.color.rgb;
    fixed4 dis_col = tex2D(_MainTex2, i.texcoord2);
    fixed clip = dis_col.r - i.color.a;
    fixed4 alpha = saturate(lerp(0, 100, clip));
    col.a = col.a * alpha;
    GAME_APPLY_FOG(i.fogCoord, col);
    return col;
};

// Burn
GameEffect2TexV2F GameEffectBurnVert (gm_appdata_effect v) {
    GameEffect2TexV2F o;
    EFFECT_BASE_VERT
    o.color.a = lerp(-1 / _BurnWidth, 1, 1 - o.color.a);
    o.texcoord2 = TRANSFORM_TEX(v.texcoord,_MainTex2);
    return o;
}

fixed4 GameEffectBurnFrag (GameEffect2TexV2F i) : SV_Target {
    fixed4 col = tex2D(_MainTex, i.texcoord);
    col.rgb *= i.color.rgb;
    fixed4 dis_col = tex2D(_MainTex2, i.texcoord2);
    fixed clip = dis_col.r - i.color.a;
    fixed4 alpha = saturate(lerp(0, 100, clip));
    col.a = col.a * alpha;
    half burn = saturate(lerp(0, 1, clip * _BurnWidth));
    fixed4 burn_col = tex2D(_BurnTex, half2(burn, 0));
    col.rgb = col.rgb + burn_col * _BurnColor;
    GAME_APPLY_FOG(i.fogCoord, col);
    return col;
};

//Distortion 2Tex
GameEffect2TexV2F Distortion2TexVert(gm_appdata_effect v) {
	GameEffect2TexV2F o;
	EFFECT_BASE_VERT
	o.texcoord2 = TRANSFORM_TEX(v.texcoord, _MainTex2);
	return o;
}
fixed4 Distortion2TexFrag(GameEffect2TexV2F f) : SV_TARGET {
	fixed2 uv_offset = UnpackNormal(tex2D(_MainTex2, f.texcoord2));
	f.texcoord += uv_offset * half2(_DistortionScaleX, _DistortionScaleY);
	fixed4 ret_col = tex2D(_MainTex, f.texcoord) * f.color;
	GAME_APPLY_FOG(f.fogCoord, ret_col);
	return ret_col;
}

// RimLight
struct GameEffectRimLightV2F {
    EFFECT_BASE_V2F(2)
    float3 normal : TEXCOORD1;
};

GameEffectRimLightV2F GameEffectRimLightVert (gm_appdata_effect_normal v)
{
    GameEffectRimLightV2F o;
    EFFECT_BASE_VERT;
    o.normal = normalize(mul((float3x3)UNITY_MATRIX_MV, v.normal));
    return o;
}

fixed4 GameEffectRimLightFrag (GameEffectRimLightV2F i) : SV_Target {
    fixed4 col = tex2D(_MainTex, i.texcoord);
    half3 normal = normalize(i.normal);
    half light = pow(1 - normal.z, _Blend);
    col *= lerp(_ColorIn, _ColorOut, light) * i.color;
    return col;
};

// CloseFade
struct GameEffectCloseFadeV2F {
    EFFECT_BASE_V2F(2)
    half fade : TEXCOORD1;
};

GameEffectCloseFadeV2F GameEffectCloseFadeVert (gm_appdata_effect v)
{
    GameEffectCloseFadeV2F o;
    EFFECT_BASE_VERT;
    o.fade = (o.vertex.w - _FadeDistanceEnd) / (_FadeDistanceStart - _FadeDistanceEnd);
    return o;
}

fixed4 GameEffectCloseFadeFrag (GameEffectCloseFadeV2F i) : SV_Target {
    fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;
    col.a *= saturate(i.fade);
    GAME_APPLY_FOG(i.fogCoord, col);
    return col;
};

// Lit
struct GameEffectLitV2F {
    EFFECT_BASE_V2F(1)
};

GameEffectLitV2F GameEffectLitVert (gm_appdata_effect_normal v)
{
    GameEffectLitV2F o;
    EFFECT_BASE_VERT;
#if defined(DIRECTIONAL)
    half light = saturate(dot(_WorldSpaceLightPos0, UnityObjectToWorldNormal(v.normal)));
    o.color.rgb *= _LightColor0.rgb * light * _GameLightColor + _GameLightDynamicAmbient;
#else
    o.color.rgb *= _GameLightColor + _GameLightDynamicAmbient;
#endif
    return o;
}

fixed4 GameEffectLitFrag (GameEffectLitV2F i) : SV_Target {
    fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;
    GAME_APPLY_FOG(i.fogCoord, col);
    return col;
};

// Rotate
half _RotateAngle;
half _RotateOffset;


fixed4 GameEffectRotateFrag (GameEffectV2F i) : SV_Target {
    half2 uv = i.texcoord - 0.5h;
    half angle = (_RotateOffset - length(uv)) * _RotateAngle;
    half cos_a = cos(angle);
    half sin_a = sin(angle);
    half2x2 m = half2x2(cos_a, sin_a, -sin_a, cos_a);
    uv = mul(m, uv) + 0.5f;
    fixed4 col = tex2D(_MainTex, uv) * i.color;
    GAME_APPLY_FOG(i.fogCoord, col);
    return col;
};


#endif