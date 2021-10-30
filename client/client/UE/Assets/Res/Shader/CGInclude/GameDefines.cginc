// Copyright (c) 2017 (weiwei)

#ifndef GAME_DEFINES_H
#define GAME_DEFINES_H

/// 宏定义说明:
/// GAME_GRAPHIC_LEVEL0 最高画质(高光+法线)
/// GAME_GRAPHIC_LEVEL1 中画质(高光无法线)
/// GAME_GRAPHIC_LEVEL2 低画质(无高光无法线)
/// GAME_RAIN_EFFECT 开启下雨地面打湿效果
/// GAME_RAINWET_EFFECT_ENABLE 结合GAME_RAIN_EFFECT和GAME_GRAPHIC_LEVEL2判断真正是否开启打湿

/// 绘制顺序约定:(代码里面有引用，修改的时候记得一起改)
/// 场景             2000      Geometry
/// 地形             2200      Geometry+200
/// AlphaTest        2450      AlphaTest
/// 场景动态的物品    2460	   AlphaTest+10
/// 角色             2500      AlphaTest+50
/// 天空盒           2600      AlphaTest+150    +-50
/// 水面或半透明地板 2900      Transparent-100
/// Transparent      3000      Transparent

/// Stencil 约定:
/// unit shadow    2

#include "UnityCG.cginc"

#define GAME_GRAPHIC_LEVEL0 (!defined(GAME_GRAPHIC_LEVEL1) && !defined(GAME_GRAPHIC_LEVEL2))

struct gm_appdata_lightmap {
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float2 uv_l : TEXCOORD1;
    float3 normal : NORMAL;
#if !defined(GAME_GRAPHIC_LEVEL2)
    float4 tangent : TANGENT;
#endif
};

struct gm_appdata {
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
#if !defined(GAME_GRAPHIC_LEVEL2)
    float4 tangent : TANGENT;
#endif
};

struct gm_appdata_effect {
    float4 vertex : POSITION;
    fixed4 color : COLOR;
    float2 texcoord : TEXCOORD0;
};

struct gm_appdata_effect_normal {
    float4 vertex : POSITION;
    fixed4 color : COLOR;
    float2 texcoord : TEXCOORD0;
    float3 normal : NORMAL;
};

sampler2D _MainTex;
float4 _MainTex_ST;

half4 _GameLightColor;
half4 _GameLightDir;
half4 _GameLightRoleLight;
half4 _GameLightRoleDark;
half4 _GameLightRoleShadow;
half4 _GameLightRoleDarkDir;
half4 _GameLightDynamicAmbient;

// Computes object space light direction
inline float3 GameObjSpaceLightDir( in float4 v )
{
    return mul(unity_WorldToObject, _GameLightDir).xyz;
}

// 注意有些平台的pow指数有限制，因此这里设置成最大支持100
#define GameCalcNormalSpec(out) \
    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;\
    float3 w_normal = UnityObjectToWorldNormal(v.normal);\
    float3 w_l_dir = _GameLightDir.xyz;\
    float3 w_c_dir = _WorldSpaceCameraPos.xyz - worldPos;\
    float3 h_dir = normalize(normalize(w_l_dir) + normalize(w_c_dir));\
    out = pow(saturate(dot(h_dir, w_normal)), min(_Specular, 100))

#if defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)
    #define SHADER_API_GL
#endif

// 用于z偏移，保护uv不扭曲，z_offset是线性距离
float GetOffsetZ (float4 pos, half z_offset) {
#if defined(SHADER_API_GL)
    return (UNITY_MATRIX_P[2][3] / (pos.w - z_offset) - UNITY_MATRIX_P[2][2]) * pos.w;
#else
    return pos.z * pos.w / (pos.w - z_offset);
#endif
};

// 把类似UV的坐标（0~1），转化为clip空间坐标（-1~1），兼容各平台
// 用于blit或者直接在屏幕上画模型
half4 UVToPos(half4 uv) {
    uv.xy = uv.xy * 2 - 1;
    uv.y *= _ProjectionParams.x;
    return uv;
}

half3 RGBToHSV(half3 col)
{
	half4 K = half4(0.0h, -1.0h / 3.0h, 2.0h / 3.0h, -1.0h);
	half4 p = lerp(half4(col.bg, K.wz), half4(col.gb, K.xy), step(col.b, col.g));
	half4 q = lerp(half4(p.xyw, col.r), half4(col.r, p.yzx), step(p.x, col.r));
	half d = q.x - min(q.w, q.y);
	half e = 1.0e-10;
	return half3(abs(q.z + (q.w - q.y) / (6.0h * d + e)), d / (q.x + e), q.x);
}
half3 HSVToRGB(half3 hsv)
{
	half4 K = half4(1.0h, 2.0h / 3.0h, 1.0h / 3.0h, 3.0h);
	half3 p = abs(frac(hsv.xxx + K.xyz) * 6.0h - K.www);
	return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
}

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    #define GAME_TRANSFER_FOG(o,outpos) UNITY_CALC_FOG_FACTOR((outpos).z); o.fogCoord.x = saturate(1 - unityFogFactor) * unity_FogColor.a
#else
    #define GAME_TRANSFER_FOG(o,outpos)
#endif

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
    #if defined(UNITY_PASS_FORWARDADD) || defined(ADD_MODE)
        #define GAME_APPLY_FOG(coord,col) col.rgb = lerp((col).rgb, fixed3(0, 0, 0), half((coord).x))
    #else
        #define GAME_APPLY_FOG(coord,col) col.rgb = lerp((col).rgb, fixed3((unity_FogColor).rgb), half((coord).x))
    #endif
#else
    #define GAME_APPLY_FOG(coord,col)
#endif
////////////////////////Model Dissolution
#ifdef GAME_DISSOLUTION

uniform half4 _DissolutionColor;
uniform sampler2D _DissolutionTex;
uniform float4 _DissolutionPlane;
uniform half4 _DissolutionColSawtooth;

	#define GAME_DISSOLUTION_COORDS(idx) half diss_dist : TEXCOORD##idx;
	#define GAME_TRANSFER_DISSOLUTION(o, world_pos) \
		o.diss_dist = dot(world_pos, _DissolutionPlane.xyz) + _DissolutionPlane.w;
	#define GAME_APPLY_DISSOLUTION(i, col) \
		half fade_dist = (tex2D(_DissolutionTex, i.uv).a - 1) * _DissolutionColSawtooth.y + i.diss_dist; \
		half alpha = lerp(_DissolutionColor.a, 0, saturate(fade_dist / _DissolutionColSawtooth.x));\
		col.rgb += _DissolutionColor.rgb * alpha;\
		clip(fade_dist)
	#define GAME_APPLY_DISSOLUTION_NO_COLOR(i) \
		clip(i.diss_dist + (tex2D(_DissolutionTex, i.uv).a - 1) * _DissolutionColSawtooth.y)
#else
	#define GAME_DISSOLUTION_COORDS(idx)
	#define GAME_TRANSFER_DISSOLUTION(o, world_pos)
	#define GAME_APPLY_DISSOLUTION(i, col)
	#define GAME_APPLY_DISSOLUTION_NO_COLOR(i)
#endif
////////////////////////Model Dissolution

//dynamic shadow Start
uniform half _ShadowY;
uniform half _ShadowAlpha;

struct GameShadowV2F {
	float4 pos : SV_POSITION;
	fixed4 color : COLOR;
	float2 uv : TEXCOORD0;
	UNITY_FOG_COORDS(1)
	GAME_DISSOLUTION_COORDS(2)
};

GameShadowV2F GameShadowVert(gm_appdata_effect_normal v) {
	GameShadowV2F o;
	UNITY_INITIALIZE_OUTPUT(GameShadowV2F, o);
	float4 world_pos = mul(unity_ObjectToWorld, v.vertex);
	o.pos = world_pos;
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
	half2 offset = _GameLightDir.xz * (o.pos.y - _ShadowY) / _GameLightDir.y;
	o.pos.xz -= offset;
	o.pos.y = _ShadowY;
	o.pos = mul(UNITY_MATRIX_VP, o.pos);
	o.pos.z = GetOffsetZ(o.pos, 1.5);
	o.color = lerp(1, _GameLightRoleShadow, _ShadowAlpha);
	GAME_TRANSFER_FOG(o, o.pos);
	GAME_TRANSFER_DISSOLUTION(o, world_pos);
	return o;
}
fixed4 GameShadowFrag(GameShadowV2F i) : COLOR{
	fixed4 col = i.color;
	GAME_APPLY_DISSOLUTION_NO_COLOR(i);
	GAME_APPLY_FOG(i.fogCoord, col);
	return col;
}
//dynamic shadow End

#endif