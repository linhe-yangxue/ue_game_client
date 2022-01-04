using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System;
using System.Text;
using System.Linq;
using quicksdk;

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
        // QuickSDK 通用调用
        // -------------------------------------------------

        public static void test()
        {
            EventHandle.getInstance().test();
            Debug.Log("进入到SDK--==============");
        }

//        public static void Init()
//        {
//            Debug.Log("进入QuickSDK--EventHandle初始化--==============");
//            QuickSDK.getInstance().reInit();
//            Debug.Log("完成QuickSDK--EventHandle初始化--==============");
//        }

        public static void QuickSDKLogin()
        {
            //ongetDeviceId();
            Debug.Log("进入QuickSDK--EventHandle登陆onLogin--==============");
            QuickSDK.getInstance ().login ();
            Debug.Log("完成QuickSDK--EventHandle登陆onLogin--==============");
        }

        public static void QuickSDKLoginResult(string role_name)
        {
            Debug.Log("进入QuickSDKLoginResult--==============");

            Debug.Log("完成QuickSDKLoginResult--==============");
        }

        public static void CreatRole(string urs,string role_name,string role_id)
        {
            Debug.Log("进入QuickSDK--EventHandle登陆CreatRole-==============" + urs + "666" + role_name + "777" + role_id);
            EventHandle.getInstance().onCreatRole(urs,role_name,role_id);
            Debug.Log("完成QuickSDK--EventHandle登陆CreatRole--==============");
        }

        public static void EnterGameRole(string server_id,string role_id,string role_name, string role_level)
        {
            EventHandle.getInstance().onEnterGame(server_id,role_id,role_name,role_level);
        }

        public static void UpdateRoleInfo(string curLevel)
        {
             EventHandle.getInstance().onUpdateRoleInfo(curLevel);
        }

        public static void QuickPay(string recharge_id,string recharge_count,string count)
        {
             EventHandle.getInstance().onPay(recharge_id,recharge_count,count);
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
        public static string onLoginSuccessResult;

        public static void CallLua(string func_name,string param)
        {
        Debug.Log("登陆成功后方法名==" + func_name + "用户数据" + param);
        string[] json1 = new string[2];
        Debug.Log("登陆成功后方法名111==");
        json1[0] = func_name;
        Debug.Log("登陆成功后方法名222==");
        json1[1] = param;
        Debug.Log("登陆成功后方法名333==" );
        string json_str = json1.ToString();
        Debug.Log("登陆成功后方法名444==" + json_str);


        string json2 = "{func_name:" + func_name + ",param:" + param + "}";
        Debug.Log("登陆成功后方法名555==" + json2);
        string json3 = param;
        GameEventMgr.GetInstance().GenerateEvent(GameEventMgr.ET_SDK, null, "CallLua", json3);
        //Object obj = new Object(); 


        //UnityEngine.Object json;
        //json = { "func_name":func_name,"param":param};   
        //SDK.CallLua(json);
        //CallLuatest(func_name,param);

        }

        public void CallLuatest(string func_name,string param)
        {
            
            string[] json1 = { };
            json1[0] = func_name;
            json1[1] = param;
            //json1.Add("func_name",func_name);
            //json1.Add("param",param);
            CallLua(json1.ToString());
        }


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