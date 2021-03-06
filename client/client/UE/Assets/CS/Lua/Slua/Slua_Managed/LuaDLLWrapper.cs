namespace SLua {
    using System;
    using System.Runtime.InteropServices;
    using System.Reflection;
    using System.Collections;
    using System.Text;
    using System.Security;



    /**     Modify Record:
     
    lua_xmove：        return void
    //lua_gc：           LuaDLLWrapper： enum->int。 
      
    lua_objlen：　　   lua 5.1：  luaS_objlen　size_t->int
    lua_rawlen:        lua 5.3：  luaS_rawlen　size_t->int
     
    lua_setmetatable： lua 5.1 return int
                       lua 5.3 return void
     
    //lua_type：         LuaDLLWrapper：  return int->enum
    lua_isnumber：　   LuaDLLWrapper：　return bool->int  
    lua_isstring:      LuaDLLWrapper：　return bool->int
    lua_iscfunction:   LuaDLLWrapper：　return bool->int
 
    lua_call:          5.1 return int->void
     
    lua_toboolean:     LuaDLLWrapper：   return bool->int
     
    lua_atpanic:       return void->intptr 
     
    lua_pushboolean:   LuaDLLWrapper： bool ->int
    lua_pushlstring:   LuaDLLWrapper: luaS_pushlstring. size_t->int

    luaL_getmetafield:  LuaDLLWrapper: return bool->int
    luaL_loadbuffe:     LuaDLLWrapper  luaLS_loadbuffer  size_t  CharSet
     
    lua_error:         return void->int
    lua_checkstack：　　LuaDLLWrapper　return bool->int


    **/

    public class LuaDLLWrapper {

#if UNITY_IPHONE && !UNITY_EDITOR
	const string LUADLL = "__Internal";
#else
        const string LUADLL = "slua";
#endif

#if LUA_5_3
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaS_rawlen(IntPtr luaState, int index);
#else
		[DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaS_objlen(IntPtr luaState, int stackPos);
#endif


        //[DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        //public static extern int lua_gc(IntPtr luaState, int what, int data);

        //[DllImport(LUADLL,CallingConvention=CallingConvention.Cdecl)]
        //public static extern int lua_type(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_isnumber(IntPtr luaState, int index);


        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_isstring(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_iscfunction(IntPtr luaState, int index);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_toboolean(IntPtr luaState, int index);


        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void lua_pushboolean(IntPtr luaState, int value);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void luaS_pushlstring(IntPtr luaState, byte[] str, int size);


        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_getmetafield(IntPtr luaState, int stackPos, string field);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaLS_loadbuffer(IntPtr luaState, byte[] buff, int size, string name);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int lua_checkstack(IntPtr luaState, int extra);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaLS_pack(IntPtr src_buff, int src_size, out IntPtr dst_buff, out int dst_size);

        public static int PackLua(byte[] src_buff, int src_size, out byte[] dst_buff) {
            IntPtr src_buff_ptr = Marshal.AllocHGlobal(src_size);
            Marshal.Copy(src_buff, 0, src_buff_ptr, src_size);
            IntPtr dst_buff_ptr = IntPtr.Zero;
            int dst_size = 0;
            var ret = luaLS_pack(src_buff_ptr, src_size, out dst_buff_ptr, out dst_size);
            if (ret != 0) {
                dst_size = 0;
                dst_buff = null;
                return ret;
            }
            dst_buff = new byte[dst_size];
            Marshal.Copy(dst_buff_ptr, dst_buff, 0, dst_size);
            Marshal.FreeHGlobal(src_buff_ptr);
            return 0;
        }
#if UNITY_EDITOR
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaLS_unpack(IntPtr src_buff, int src_size, out IntPtr dst_buff, out int dst_size);

        public static int UnpackLua(byte[] src_buff, int src_size, out byte[] dst_buff) {
            IntPtr src_buff_ptr = Marshal.AllocHGlobal(src_size);
            Marshal.Copy(src_buff, 0, src_buff_ptr, src_size);
            IntPtr dst_buff_ptr = IntPtr.Zero;
            int dst_size = 0;
            var ret = luaLS_unpack(src_buff_ptr, src_size, out dst_buff_ptr, out dst_size);
            //UnityEngine.Debug.LogWarning("luaLS_unpack:" + ret + ":" + dst_size);
            if (ret != 0) {
                dst_size = 0;
                dst_buff = null;
                return ret;
            }
            dst_buff = new byte[dst_size];
            Marshal.Copy(dst_buff_ptr, dst_buff, 0, dst_size);
            Marshal.FreeHGlobal(src_buff_ptr);
            return 0;
        }
#endif
    }

}
