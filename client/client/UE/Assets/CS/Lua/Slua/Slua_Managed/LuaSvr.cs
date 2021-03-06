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

// uncomment this will use static binder(class BindCustom/BindUnity), 
// init will not use reflection to speed up the speed
//#define USE_STATIC_BINDER  

namespace SLua
{
	using System;
	using System.Threading;
	using System.Collections;
	using System.Collections.Generic;
	using System.Reflection;
	#if !SLUA_STANDALONE
	using UnityEngine;
	using Debug = UnityEngine.Debug;
	#endif

	public enum LuaSvrFlag {
		LSF_BASIC = 0,
		LSF_EXTLIB = 1,
	};

	public class LuaSvr 
	{
		public LuaState luaState;
		int errorReported = 0;
		public bool inited = false;

        LuaFunction luaUpdateFunc = null;
        LuaFunction luaFixUpdateFunc = null;
        LuaFunction luaLateUpdateFunc = null;
        LuaFunction luaDestroyFunc = null;

		public LuaSvr()
		{
			LuaState luaState = new LuaState();
			this.luaState = luaState;
		}

		List<Action<IntPtr>> collectBindInfo() {

			List<Action<IntPtr>> list = new List<Action<IntPtr>>();

			#if !SLUA_STANDALONE
			#if !USE_STATIC_BINDER
			Assembly[] ams = AppDomain.CurrentDomain.GetAssemblies();

			List<Type> bindlist = new List<Type>();
			for (int n = 0; n < ams.Length;n++ )
			{
				Assembly a = ams[n];
				Type[] ts = null;
				try
				{
					ts = a.GetExportedTypes();
				}
				catch
				{
					continue;
				}
				for (int k = 0; k < ts.Length; k++)
				{
					Type t = ts[k];
					if (t.IsDefined(typeof(LuaBinderAttribute), false))
					{
						bindlist.Add(t);
					}
				}
			}

			bindlist.Sort(new System.Comparison<Type>((Type a, Type b) => {
				LuaBinderAttribute la = System.Attribute.GetCustomAttribute( a, typeof(LuaBinderAttribute) ) as LuaBinderAttribute;
				LuaBinderAttribute lb = System.Attribute.GetCustomAttribute( b, typeof(LuaBinderAttribute) ) as LuaBinderAttribute;

				return la.order.CompareTo(lb.order);
			}));

			for (int n = 0; n < bindlist.Count; n++)
			{
				Type t = bindlist[n];
				var sublist = (Action<IntPtr>[])t.GetMethod("GetBindList").Invoke(null, null);
				list.AddRange(sublist);
			}
			#else
			var assemblyName = "Assembly-CSharp";
			Assembly assembly = Assembly.Load(assemblyName);
			list.AddRange(getBindList(assembly,"SLua.BindUnity"));
			list.AddRange(getBindList(assembly,"SLua.BindUnityUI"));
			list.AddRange(getBindList(assembly,"SLua.BindDll"));
			list.AddRange(getBindList(assembly,"SLua.BindCustom"));
			#endif
			#endif

			return list;

		}


		protected void doBind(IntPtr L)
		{
			var list = collectBindInfo ();

			int count = list.Count;
			for (int n = 0; n < count; n++)
			{
				Action<IntPtr> action = list[n];
				action(L);
			}
		}



		private IEnumerator doBind(IntPtr L,Action<int> _tick,Action complete)
		{
			Action<int> tick = (int p) => {
				if (_tick != null)
					_tick (p);
			};

			tick (0);
			var list = collectBindInfo ();

			tick (2);

			int bindProgress = 2;
			int lastProgress = bindProgress;
			for (int n = 0; n < list.Count; n++)
			{
				Action<IntPtr> action = list[n];
				action(L);
				bindProgress = (int)(((float)n / list.Count) * 98.0) + 2;
				if (_tick!=null && lastProgress != bindProgress && bindProgress % 5 == 0) {
					tick (bindProgress);
					yield return null;
				}
			}

			tick (100);
			complete ();
		}

		Action<IntPtr>[] getBindList(Assembly assembly,string ns) {
			Type t=assembly.GetType(ns);
			if(t!=null)
				return (Action<IntPtr>[]) t.GetMethod("GetBindList").Invoke(null, null);
			return new Action<IntPtr>[0];
		}

        protected void doinit(IntPtr L,LuaSvrFlag flag)
		{
			#if !SLUA_STANDALONE
			#if UNITY_EDITOR
			if (UnityEditor.EditorApplication.isPlaying)
			#endif
			#endif

            if((flag&LuaSvrFlag.LSF_EXTLIB)!=0) {
				LuaDLL.luaS_openextlibs(L);
            }
			inited = true;
		}

        protected void checkTop(IntPtr L)
		{
			if (LuaDLL.lua_gettop(luaState.L) != errorReported)
			{
				Logger.LogError("Some function not remove temp value from lua stack. You should fix it.");
				errorReported = LuaDLL.lua_gettop(luaState.L);
			}
		}

        #if SLUA_STANDALONE
        public void Init(Action<int> tick = null, Action complete = null, LuaSvrFlag flag = LuaSvrFlag.LSF_BASIC)
        #else
        public IEnumerator Init(Action<int> tick = null, Action complete = null, LuaSvrFlag flag = LuaSvrFlag.LSF_BASIC)
        #endif
		{
			IntPtr L = luaState.L;
			LuaObject.init(L);

			#if SLUA_STANDALONE
			doBind(L);
			doinit(L, flag);
            if (complete != null) {
			    complete();
            }
			checkTop(L);
			#else


			#if UNITY_EDITOR
			if (!UnityEditor.EditorApplication.isPlaying)
			{
				doBind(L);
				doinit(L, flag);
                if (complete != null) {
				    complete();
                }
				checkTop(L);
                yield return null;
			}
			else
			{
			#endif
                yield return doBind(L,tick, () =>
					{
						doinit(L, flag);
                        if (complete != null) {
						    complete();
                        }
						checkTop(L);
					});
			#if UNITY_EDITOR
			}
			#endif
			#endif
		}

        public void Start(string main, string lua_start_func = "main", string lua_destroy_func = null, string lua_update_func = null, string lua_fixed_update_func = null, string lua_late_update_func = null)
		{
			if (main != null)
			{
				luaState.doFile(main);
                // InitLayers();  已移到了Layer.lua那里自己初始化
                LuaFunction func = (LuaFunction)luaState[lua_start_func];
                if(func != null) {
					func.call();
                }
                this.luaDestroyFunc = (LuaFunction)luaState[lua_destroy_func];
                this.luaUpdateFunc = (LuaFunction)luaState[lua_update_func];
                this.luaFixUpdateFunc = (LuaFunction)luaState[lua_fixed_update_func];
                this.luaLateUpdateFunc = (LuaFunction)luaState[lua_late_update_func];
			}
		}

        void InitLayers() {
            LuaTable layers = (LuaTable)luaState["Layer"];
            for (int i = 0; i < 32; i++) {
                string str = LayerMask.LayerToName(i);
                if (str != string.Empty) {
                    layers[str] = i;
                }
            }
        }

        public void Update()
		{
			if (!inited)
				return;

			if (LuaDLL.lua_gettop(luaState.L) != errorReported)
			{
				errorReported = LuaDLL.lua_gettop(luaState.L);
				Logger.LogError(string.Format("Some function not remove temp value({0}) from lua stack. You should fix it.",LuaDLL.luaL_typename(luaState.L,errorReported)));
			}

            if (luaUpdateFunc != null) {
                luaUpdateFunc.call(Time.deltaTime, Time.unscaledDeltaTime);
            }

			luaState.checkRef();
		}

        public void FixUpdate() {
            if (luaFixUpdateFunc != null) {
                luaFixUpdateFunc.call(Time.fixedDeltaTime);
            }
        }

        public void LateUpdate() {
            if (luaLateUpdateFunc != null) {
                luaLateUpdateFunc.call(Time.deltaTime);
            }
        }

        public void Destroy() {
            if (luaDestroyFunc != null) {
                luaDestroyFunc.call();
            }
            if (luaState != null) {
                luaState.Dispose();
                luaState = null;
            }
        }
	}
}
