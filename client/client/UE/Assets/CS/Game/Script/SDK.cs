using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System;

    public class SDK : MonoBehaviour {
        private static SDK __instance;

        public static SDK Instance {
            get {
                if (__instance == null) {
                    GameObject obj = new GameObject("SDK");
                    DontDestroyOnLoad(obj);
                    __instance = obj.AddComponent<SDK>();
                }
                return __instance;
            }
        }

        // Use this for initialization
        void Start() {
          Debug.Log("SDK----Start-----" + gameObject.name);
        }

        // Update is called once per frame
        void Update() {

        }

        // -------------------------------------------------
        // android 通用调用
        // -------------------------------------------------
        public static void CallMainActicity(string func_name, string str)
        {
            Debug.LogFormat("CallMainActicity {0}:{1}", func_name, str);
            AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            jo.Call("runOnUiThread", new AndroidJavaRunnable(() => jo.Call(func_name, str)));
        }
        public static void CallMainActicity(string func_name)
        {
            Debug.LogFormat("CallMainActicity {0}", func_name);
            AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            jo.Call("runOnUiThread", new AndroidJavaRunnable(() => jo.Call(func_name)));
        }
        public static string CallMainActicityWithReturn(string func_name, string str)
        {
            Debug.LogFormat("CallMainActicityWithReturn {0}:{1}", func_name, str);
            AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
            var result = jo.Call<string>(func_name, str);
            Debug.LogFormat("CallMainActicityWithReturn result:{0}", result);
            return result;
        }
        public static void CallJavaStaticFunc(string class_name, string func_name, string json_param)
        {
            Debug.LogFormat("CallJavaStaticFunc {0} {1}:{2}", class_name, func_name, json_param);
            AndroidJavaClass jc = new AndroidJavaClass(class_name);
            jc.CallStatic(func_name, json_param);
        }

        public static void CallJavaFunc(string class_name, string obj_name, string func_name, string json_param)
        {
            Debug.LogFormat("CallJavaFunc {0} {1} {2}:{3}", class_name, obj_name, func_name, json_param);
            AndroidJavaClass jc = new AndroidJavaClass(class_name);
            AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>(obj_name);
            jo.Call("runOnUiThread", new AndroidJavaRunnable(() => jo.Call(func_name, json_param)));
        }
        // -------------------------------------------------
        // 通用回调
        // -------------------------------------------------
        public void CallLua(string json_str)
        {
            Debug.Log("CallLua:"+json_str);
            GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_SDK, null, "CallLua", json_str);
        }
        public void CatchError(string json_str)
        {
            Debug.Log("CatchError:"+json_str);
            GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_SDK, null, "CatchError", json_str);
        }

#if UNITY_IOS
        // -------------------------------------------------
        // 工具
        // -------------------------------------------------
        [DllImport("__Internal")]
        public static extern string EchoTest(string json_str);
        [DllImport("__Internal")]
        public static extern void SetClipboard(string json_str);
        [DllImport("__Internal")]
        public static extern string GetClipboard(string json_str);
        [DllImport("__Internal")]
        public static extern string GetBatteryState(string json_str);

        // -------------------------------------------------
        // Gaea
        // -------------------------------------------------
        [DllImport("__Internal")]
        public static extern void GaeaInit(string json_str);
        [DllImport("__Internal")]
        public static extern void GaeaLogin(string json_str);
        [DllImport("__Internal")]
        public static extern void GaeaPay(string json_str);
        [DllImport("__Internal")]
        public static extern void GaeaUserCenter(string json_str);
        [DllImport("__Internal")]
        public static extern void GaeaForum(string json_str);
        [DllImport("__Internal")]
        public static extern void GaeaService(string json_str);

        // -------------------------------------------------
        // Gata
        // -------------------------------------------------
        [DllImport("__Internal")]
        public static extern void GataInit(string json_str);
        [DllImport("__Internal")]
        public static extern void GataLogEvent1(string json_str);
        [DllImport("__Internal")]
        public static extern void GataLogEvent2(string json_str);
        [DllImport("__Internal")]
        public static extern void GataLogEvent3(string json_str);
        [DllImport("__Internal")]
        public static extern void GataUserLogin(string json_str);
        [DllImport("__Internal")]
        public static extern void GataRoleCreate(string json_str);
        [DllImport("__Internal")]
        public static extern void GataRoleLogin(string json_str);
        [DllImport("__Internal")]
        public static extern void GataRoleLogout(string json_str);
        [DllImport("__Internal")]
        public static extern void GataSetLevel(string json_str);
        [DllImport("__Internal")]
        public static extern void GataSetCrashReportingEnabled(string json_str);
        [DllImport("__Internal")]
        public static extern void GataLogError(string json_str);
        [DllImport("__Internal")]
        public static extern void GataLogLocation(string json_str);
        [DllImport("__Internal")]
        public static extern string GataGetDeviceInfo(string json_str);
#endif

}