// The MIT License (MIT)

// Copyright 2015 Siney/Pangweiwei siney@yeah.net
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#define MT_VEC2 1
#define MT_VEC3 2
#define MT_VEC4 3
#define MT_Q	4
#define MT_COLOR	5
#define MT_BOUNDS   6
#define MT_RECT   7

#define LUA_LIB

#include "lua.h"
#include "lauxlib.h"

#if defined(ISMACOS) || defined(ISIOS)
// #include <sys/malloc.h>
#else
#include <malloc.h>
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef _WIN32
#include <float.h>
#define isnan _isnan
#define snprintf _snprintf
#else
#include <math.h>
#endif

static const luaL_Reg s_lib_preload[] = {
	// { "lpeg", luaopen_lpeg },
	// { "pb",    luaopen_pb }, // any 3rd lualibs added here
		{ NULL, NULL }
};

#if LUA_VERSION_NUM >= 503

static const char *luaL_findtable(lua_State *L, int idx,
	const char *fname, int szhint) {
	const char *e;
	if (idx) lua_pushvalue(L, idx);
	do {
		e = strchr(fname, '.');
		if (e == NULL) e = fname + strlen(fname);
		lua_pushlstring(L, fname, e - fname);
		if (lua_rawget(L, -2) == LUA_TNIL) {  /* no such field? */
			lua_pop(L, 1);  /* remove this nil */
			lua_createtable(L, 0, (*e == '.' ? 1 : szhint)); /* new table for field */
			lua_pushlstring(L, fname, e - fname);
			lua_pushvalue(L, -2);
			lua_settable(L, -4);  /* set new table into field */
		}
		else if (!lua_istable(L, -1)) {  /* field has a non-table value? */
			lua_pop(L, 2);  /* remove table and value */
			return fname;  /* return problematic part of the name */
		}
		lua_remove(L, -2);  /* remove previous table */
		fname = e + 1;
	} while (*e == '.');
	return NULL;
}

#else

static int lua_absindex(lua_State *L, int index) {
	return index > 0 ? index : lua_gettop(L) + index + 1;
}

#endif



LUA_API void luaS_openextlibs(lua_State *L) {
	const luaL_Reg *lib;

#if defined(luajit_c)
	luaL_findtable(L, LUA_REGISTRYINDEX, "_PRELOAD",
		sizeof(s_lib_preload) / sizeof(s_lib_preload[0]) - 1);
#else
	lua_getglobal(L,"package");
	lua_getfield(L,-1,"preload");
#endif

	for (lib = s_lib_preload; lib->func; lib++) {
		lua_pushcfunction(L, lib->func);
		lua_setfield(L, -2, lib->name);
	}

#if defined(luajit_c)
	lua_pop(L, 1);
#else
    lua_pop(L, 2);
#endif
}

LUA_API void luaS_newuserdata(lua_State *L, int val)
{
	int* pointer = (int*)lua_newuserdata(L, sizeof(int));
	*pointer = val;
}

LUA_API int luaS_rawnetobj(lua_State *L, int index)
{
	int *ud;

	if (lua_istable(L, index))
	{
		lua_pushvalue(L, index);
		while (lua_istable(L, -1))
		{
			lua_pushstring(L, "__base");
			lua_rawget(L, -2);
			lua_remove(L, -2);
		}
		if (lua_isuserdata(L, -1) > 0)
			lua_replace(L, index);
		else
			return -1;
	}

	ud = lua_touserdata(L, index);
	return (ud != NULL)?*ud:-1;
}

LUA_API void luaS_pushuserdata(lua_State *L, void* ptr)
{
	void** pointer = (void**)lua_newuserdata(L, sizeof(void*));
	*pointer = ptr;
}


LUA_API const char* luaS_tolstring32(lua_State *L, int index, int* len) {
	size_t l;
	const char* ret = lua_tolstring(L, index, &l);
	*len = (int)l;
	return ret;
}

#if LUA_VERSION_NUM>=503
static int k(lua_State *L, int status, lua_KContext ctx) {
	return status;
}

LUA_API int luaS_yield(lua_State *L, int nrets) {
	return k(L, lua_yieldk(L, nrets, 0, k), 0);
}

LUA_API int luaS_pcall(lua_State *L, int nargs, int nresults, int err) {
	return k(L, lua_pcallk(L, nargs, nresults, err, 0, k), 0);
}
#endif



static void getmetatable(lua_State *L, const char* key) {
	// char ns[256];
	// snprintf(ns, 256, "UnityEngine.%s.Instance", key);

	lua_getglobal(L, key);
}

static void setmetatable(lua_State *L, int p, int what) {

	int ref;
	
#if LUA_VERSION_NUM>=503
	lua_pushglobaltable(L);
	lua_rawgeti(L, -1, what);
	lua_remove(L, -2);
#else
	lua_rawgeti(L, LUA_GLOBALSINDEX, what);
#endif
	if (!lua_isnil(L, -1)) {
		ref = (int)lua_tointeger(L, -1);
		lua_pop(L, 1);
		if (ref != LUA_REFNIL)
		{
			lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
		}
	}
	else {
		lua_pop(L, 1);

		switch (what) {
		case MT_VEC2:
			getmetatable(L, "Vector2");
			break;
		case MT_VEC3:
			getmetatable(L, "Vector3");
			break;
		case MT_VEC4:
			getmetatable(L, "Vector4");
			break;
		case MT_Q:
			getmetatable(L, "Quaternion");
			break;
		case MT_COLOR:
			getmetatable(L, "Color");
			break;
		case MT_BOUNDS:
			getmetatable(L, "Bounds");
			break;
        case MT_RECT:
			getmetatable(L, "Rect");
			break;
		}

		lua_pushvalue(L, -1);
		ref = luaL_ref(L, LUA_REGISTRYINDEX);
#if LUA_VERSION_NUM >= 503
		lua_pushglobaltable(L);
		lua_pushinteger(L, ref);
		lua_rawseti(L, -2, what);
		lua_pop(L, 1);
#else
		lua_pushinteger(L, ref);
		lua_rawseti(L, LUA_GLOBALSINDEX, what);
#endif
	}

	lua_setmetatable(L, p);
}



LUA_API int luaS_checkluatype(lua_State *L, int p, const char *t) {
	int top;
	const char* b;

	p=lua_absindex(L,p);
	if (lua_type(L, p) != LUA_TTABLE)
		return 0;
	top = lua_gettop(L);
	if (lua_getmetatable(L, p) == 0)
		return 0;

	lua_pushstring(L, "__typename");
	lua_rawget(L, -2);
	if (lua_isnil(L, -1))
	{
		lua_settop(L, top);
		return 0;
	}
	if (t != NULL) {
		b = lua_tostring(L, -1);
		lua_settop(L, top);
		return strcmp(t, b) == 0;
	}
	lua_settop(L, top);
	return 1;
}


LUA_API int luaS_checkVector4(lua_State *L, int p, float* x, float *y, float *z, float *w) {
	p=lua_absindex(L,p);
	if(lua_type(L,p)!=LUA_TTABLE)
		return -1;
	lua_getfield(L, p, "x");
	*x = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "y");
	*y = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "z");
	*z = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "w");
	*w = (float)lua_tonumber(L, -1);
	lua_pop(L, 4);
	return 0;
}

LUA_API void luaS_pushVector4(lua_State *L, float x, float y, float z, float w) {
	lua_newtable(L);
	lua_pushnumber(L, x);
	lua_setfield(L, -2, "x");
	lua_pushnumber(L, y);
	lua_setfield(L, -2, "y");
	lua_pushnumber(L, z);
	lua_setfield(L, -2, "z");
	lua_pushnumber(L, w);
	lua_setfield(L, -2, "w");
	setmetatable(L, -2, MT_VEC4);
}

LUA_API int luaS_checkVector3(lua_State *L, int p, float* x, float *y, float *z) {
	p=lua_absindex(L,p);
	if(lua_type(L,p)!=LUA_TTABLE)
		return -1;
	luaL_checktype(L, p, LUA_TTABLE);
	lua_getfield(L, p, "x");
	*x = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "y");
	*y = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "z");
	*z = (float)lua_tonumber(L, -1);
	lua_pop(L, 3);
	return 0;
}

LUA_API void luaS_pushVector3(lua_State *L, float x, float y, float z) {
	lua_newtable(L);
	lua_pushnumber(L, x);
	lua_setfield(L, -2, "x");
	lua_pushnumber(L, y);
	lua_setfield(L, -2, "y");
	lua_pushnumber(L, z);
	lua_setfield(L, -2, "z");
	setmetatable(L, -2, MT_VEC3);
}

LUA_API int luaS_checkVector2(lua_State *L, int p, float* x, float *y) {
	p=lua_absindex(L,p);
	if(lua_type(L,p)!=LUA_TTABLE)
		return -1;
	lua_getfield(L, p, "x");
	*x = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "y");
	*y = (float)lua_tonumber(L, -1);
	lua_pop(L, 2);
	return 0;
}

LUA_API void luaS_pushVector2(lua_State *L, float x, float y) {
	lua_newtable(L);
	lua_pushnumber(L, x);
	lua_setfield(L, -2, "x");
	lua_pushnumber(L, y);
	lua_setfield(L, -2, "y");
	setmetatable(L, -2, MT_VEC2);
}

LUA_API int luaS_checkQuaternion(lua_State *L, int p, float* x, float *y, float *z, float* w) {
	p=lua_absindex(L,p);
	if(lua_type(L,p)!=LUA_TTABLE)
		return -1;
	lua_getfield(L, p, "x");
	*x = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "y");
	*y = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "z");
	*z = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "w");
	*w = (float)lua_tonumber(L, -1);
	lua_pop(L, 4);
	return 0;
}

LUA_API void luaS_pushQuaternion(lua_State *L, float x, float y, float z, float w) {
	lua_newtable(L);
	lua_pushnumber(L, x);
	lua_setfield(L, -2, "x");
	lua_pushnumber(L, y);
	lua_setfield(L, -2, "y");
	lua_pushnumber(L, z);
	lua_setfield(L, -2, "z");
	lua_pushnumber(L, w);
	lua_setfield(L, -2, "w");
	setmetatable(L, -2, MT_Q);
}

LUA_API int luaS_checkColor(lua_State *L, int p, float* r, float *g, float *b, float* a) {
	p=lua_absindex(L,p);
	if(lua_type(L,p)!=LUA_TTABLE)
		return -1;
	lua_getfield(L, p, "r");
	*r = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "g");
	*g = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "b");
	*b = (float)lua_tonumber(L, -1);
	lua_getfield(L, p, "a");
	*a = (float)lua_tonumber(L, -1);
	lua_pop(L, 4);
	return 0;
}

LUA_API void luaS_pushColor(lua_State *L, float r, float g, float b, float a) {
	lua_newtable(L);
	lua_pushnumber(L, r);
	lua_setfield(L, -2, "r");
	lua_pushnumber(L, g);
	lua_setfield(L, -2, "g");
	lua_pushnumber(L, b);
	lua_setfield(L, -2, "b");
	lua_pushnumber(L, a);
	lua_setfield(L, -2, "a");
	setmetatable(L, -2, MT_COLOR);
}

LUA_API int luaS_checkBounds(lua_State *L, int p, float* c_x, float *c_y, float *c_z, float* e_x, float* e_y, float* e_z) {
	p=lua_absindex(L,p);
	if(lua_type(L,p)!=LUA_TTABLE) {
		return -1;
	}
	lua_getfield(L, p, "center");
	luaS_checkVector3(L, -1, c_x, c_y, c_z);
	lua_getfield(L, p, "extents");
	luaS_checkVector3(L, -1, e_x, e_y, e_z);
	lua_pop(L, 2);
	return 0;
}

LUA_API void luaS_pushBounds(lua_State *L, float c_x, float c_y, float c_z, float e_x, float e_y, float e_z) {
	lua_newtable(L);
	luaS_pushVector3(L, c_x, c_y, c_z);
	lua_setfield(L, -2, "center");
	luaS_pushVector3(L, e_x, e_y, e_z);
	lua_setfield(L, -2, "extents");
	setmetatable(L, -2, MT_BOUNDS);
}

LUA_API int luaS_checkRect(lua_State *L, int p, float* x, float *y, float *width, float *height) {
    p = lua_absindex(L, p);
    if (lua_type(L, p) != LUA_TTABLE)
        return -1;
    lua_getfield(L, p, "x");
    *x = (float)lua_tonumber(L, -1);
    lua_getfield(L, p, "y");
    *y = (float)lua_tonumber(L, -1);
    lua_getfield(L, p, "width");
    *width = (float)lua_tonumber(L, -1);
    lua_getfield(L, p, "height");
    *height = (float)lua_tonumber(L, -1);
    lua_pop(L, 4);
    return 0;
}

LUA_API void luaS_pushRect(lua_State *L, float x, float y, float width, float height) {
    lua_newtable(L);
    lua_pushnumber(L, x);
    lua_setfield(L, -2, "x");
    lua_pushnumber(L, y);
    lua_setfield(L, -2, "y");
    lua_pushnumber(L, width);
    lua_setfield(L, -2, "width");
    lua_pushnumber(L, height);
    lua_setfield(L, -2, "height");
    setmetatable(L, -2, MT_RECT);
}

static void setelement(lua_State* L, int p, float v, const char* key) {
	if (!isnan(v)) {
		lua_pushstring(L, key);
		lua_pushnumber(L, v);
		lua_settable(L, p);
	}
}


static void setelementid(lua_State* L, int p, float v, int id) {
	if (!isnan(v)) {
		lua_pushnumber(L, v);
		lua_rawseti(L, p, id);
	}
}

LUA_API void luaS_setDataVec(lua_State *L, int p, float x, float y, float z, float w) {
	p=lua_absindex(L,p);
	setelement(L, p, x, "x");
	setelement(L, p, y, "y");
	setelement(L, p, z, "z");
	setelement(L, p, w, "w");
}

LUA_API void luaS_setColor(lua_State *L, int p, float r, float g, float b, float a) {
	p=lua_absindex(L,p);
	setelement(L, p, r, "r");
	setelement(L, p, g, "g");
	setelement(L, p, b, "b");
	setelement(L, p, a, "a");
}

static void cacheud(lua_State *l, int index, int cref) {
	lua_rawgeti(l, LUA_REGISTRYINDEX, cref);
	lua_pushvalue(l, -2);
	lua_rawseti(l, -2, index);
	lua_pop(l, 1);
}


LUA_API int luaS_pushobject(lua_State *l, int index, const char* t, int gco, int cref) {

	int is_reflect = 0;

	luaS_newuserdata(l, index);
	if (gco) cacheud(l, index, cref);


	luaL_getmetatable(l, t);
	if (lua_isnil(l, -1))
	{
		lua_pop(l, 1);
		luaL_getmetatable(l, "LuaVarObject");
		is_reflect = 1;
	}

	lua_setmetatable(l, -2);
	return is_reflect;
}

LUA_API int luaS_getcacheud(lua_State *l, int index, int cref) {
	lua_rawgeti(l, LUA_REGISTRYINDEX, cref);
	lua_rawgeti(l, -1, index);
	if (!lua_isnil(l, -1))
	{
		lua_remove(l, -2);
		return 1;
	}
	lua_pop(l, 2);
	return 0;
}

LUA_API int luaS_subclassof(lua_State *l, int p, const char* t) {

	const char* tname;
	int ok;
	int top = lua_gettop(l);

	lua_pushvalue(l, p);
	while (lua_istable(l, -1))
	{
		lua_pushstring(l, "__base");
		lua_rawget(l, -2);
	}

	if (lua_isnil(l, -1)) {
		lua_settop(l, top);
		return 0;
	}

	if (t != NULL) {
		lua_getmetatable(l, -1);
		lua_getfield(l, -1, "__typename");
		tname = lua_tostring(l, -1);
		ok = strcmp(tname, t);
		lua_settop(l, top);
		return ok == 0;
	}
	return 1;
}


#if LUA_VERSION_NUM>=502
LUALIB_API int luaS_rawlen(lua_State *L, int idx)
{
	size_t ret = lua_rawlen(L, idx);
	return (int)ret;
}
#else
LUALIB_API int luaS_objlen(lua_State *L, int idx)
{
	size_t ret = lua_objlen(L, idx);
	return (int)ret;
}
#endif


LUALIB_API void  luaS_pushlstring(lua_State *L, const char *s, int l)
{
	lua_pushlstring(L, s, (size_t)l);
}

static char* s_reserve_buff_ = NULL;
static int s_reserve_buff_len_ = 0;
#define K 0xA72F
#define C1 0x61CD
#define C2 0xBC17
#include <compress.c>
#include <uncompr.c>

void __encrypt(signed char* buff, int size) {
    unsigned short key = K;
    int i = 0;
    for (i = 0; i < size; ++i) {
        buff[i] = buff[i] ^ ((char)(key >> 8));
        key = (buff[i] + key) * C1 + C2;
    }
}

void __decrypt(signed char* buff, int size) {
    unsigned short key = K;
    int i = 0;
    for (i = 0; i < size; ++i) {
        int c_v = (int)buff[i];
        int cur_key = (int)(key >> 8);
        buff[i] = (char)(c_v ^ cur_key);
        key = (c_v + key) * C1 + C2;
    }
}

static char* getReserveBuff(int size) {
    if (s_reserve_buff_ == NULL || s_reserve_buff_len_ < size) {
        if (s_reserve_buff_ != NULL) {
            free(s_reserve_buff_);
            s_reserve_buff_ = NULL;
            s_reserve_buff_len_ = 0;
        }
        s_reserve_buff_len_ = size + 1024;
        s_reserve_buff_ = malloc(s_reserve_buff_len_);
    }
    return s_reserve_buff_;
}

static int pack(char* src_buff, int src_size, char** dst_buff, int* dst_size) {
    uLongf body_size = compressBound(src_size);
    uLongf head_size = 4;
    *dst_buff = getReserveBuff((int)(body_size + head_size));
    int ret = compress2((Bytef*)(*dst_buff + head_size), &body_size, (const Bytef*)src_buff, (uLong)src_size, Z_BEST_COMPRESSION);
    if (ret) return ret;
    *((int*)(*dst_buff)) = src_size;
    *dst_size = (int)(body_size + head_size);
    __encrypt((signed char*)*dst_buff, *dst_size);
    return 0;
}

static int unpack(char *src_buff, int src_size, char** dst_buff, int* dst_size) {
    __decrypt((signed char*)src_buff, src_size);
    *dst_size = *((int*)src_buff);
    uLongf size = (uLongf)(*dst_size);
    *dst_buff = getReserveBuff(*dst_size);
    int ret = uncompress((Bytef*)*dst_buff, &size, (const Bytef*)(src_buff + 4), (uLong)src_size - 4);
    *dst_size = (int)size;
    return ret;
}

// 注意会修改原buff内容
LUALIB_API int luaLS_loadbuffer(lua_State *L, char *buff, int sz, const char *name)
{
    char* new_buff;
    int new_len;
    int ret = unpack(buff, sz, &new_buff, &new_len);
    if (ret) return ret;
    return luaL_loadbuffer(L, new_buff, new_len, name);
}

LUALIB_API int luaLS_pack(char* src_buff, int src_size, char** dst_buff, int* dst_size) {
    return pack(src_buff, src_size, dst_buff, dst_size);
}

LUALIB_API int luaLS_unpack(char* src_buff, int src_size, char** dst_buff, int* dst_size) {
    return unpack(src_buff, src_size, dst_buff, dst_size);
}


// 检查死循环工具
LUALIB_API void luaS_SetBreakSig(lua_State* L) {
  skynet_sig_L = L;
}
