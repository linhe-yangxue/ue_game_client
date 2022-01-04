using SLua;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.SceneManagement;
using quicksdk;

public class GameEntry : QuickSDKListener{

    public static GameEntry	Instance { get; private set; }
	private string cur_scene_path = null;

    static public string sGameVersion = "1.0";
    public GameLuaEntry game_lua_entry_ = null;

    public bool is_inited = false;
    public bool need_restart = false;

    public double last_enter_lua_time = 0;
    public Thread watch_thread = null;
    public System.IntPtr watch_l;
    public object watch_lock = new object();

    public static bool CheckExist()
    {
        if( Instance )
            return true;
        else
        {
            Debug.LogError("\t找不到！");
            return false;
        }
    }

    void Awake() {
    	GameLog.InitGameLog();
    	if( !Instance)
        {
            Instance = (GameEntry)this;
        }
    	//base.Awake();
    	//EventHandle.getInstance().Start();
    	QuickSDK.getInstance ().setListener (this);
//    	QuickSDK.getInstance().reInit();
    }

    IEnumerator Start() {
       //EventHandle.getInstance().Start();
       Debug.Log("游戏开始===============调用么" + typeof(GameEntry) + "111" + typeof(Singleton<GameEventInput>) + "222" + typeof(QuickSDKListener));

//       QuickSDK.getInstance ().setListener (this);
        AssetBundles.AssetBundleManager.Initialize();
        Debug.Log("游戏开始222222");
        Debug.Log("游戏开始222222");
        Debug.Log("游戏开始222222");
        if (game_lua_entry_ == null) {
            Debug.Log("游戏开始333333");
            game_lua_entry_ = new GameLuaEntry();
            Debug.Log("游戏开始444444");
            yield return game_lua_entry_.DoInit();
        }
        Debug.Log("游戏开始555555");
        is_inited = true;
        Debug.Log("游戏开始6666666");
        StartWatchDeadLoop();
    }

    void showLog(string title, string message)
    {
        Debug.Log ("title: " + title + ", message: " + message);
    }

	void MyLoadScene(string scene_path) {
		if (cur_scene_path != scene_path) {
			cur_scene_path = scene_path;
			SceneManager.LoadScene(cur_scene_path, LoadSceneMode.Single);
		}
	}

    void Restart() {
        AssetBundles.AssetBundleManager.ClearAll();
        Debug.Log("重新启动游戏=======" + is_inited);
        if (is_inited) {
            game_lua_entry_.DoDestroy();
            StopWatchDeadLoop();
            game_lua_entry_ = null;
            is_inited = false;
        }
        need_restart = false;
        StartCoroutine(Start());
    }

    /*
	void OnGUI() {
		GUILayout.BeginArea(new Rect(Screen.width * 0.8f, 0, Screen.width * 0.2f, Screen.height));
		GUILayout.BeginVertical();
		if (GUILayout.Button("手绘风场景", GUILayout.Width(Screen.width * 0.2f), GUILayout.Height(Screen.height * 0.1f))) {
			MyLoadScene("HandpaintedForest");
		}
		if (GUILayout.Button("次时代场景", GUILayout.Width(Screen.width * 0.2f), GUILayout.Height(Screen.height * 0.1f))) {
			MyLoadScene("RainTest");
		}
		if (GUILayout.Button("无限大场景测试", GUILayout.Width(Screen.width * 0.2f), GUILayout.Height(Screen.height * 0.1f))) {
			MyLoadScene("MultiScene");
		}
		GUILayout.EndVertical();
		GUILayout.EndArea();
	}
 */
    void Update() {
        if (need_restart) {
            Restart();
        }
        if (is_inited) {
            StartEnterLua();
            game_lua_entry_.Update();
            EndEnterLua();
        }
        AssetBundles.AssetBundleManager.Update();
    }

    void FixedUpdate() {
        if (is_inited) {
            StartEnterLua();
            game_lua_entry_.FixUpdate();
            EndEnterLua();
        }
    }

    void LateUpdate() {
        if (is_inited) {
            StartEnterLua();
            game_lua_entry_.LateUpdate();
            EndEnterLua();
        }
		GameLog.LaterUpdate();
    }

    void OnApplicationQuit() {
        if (is_inited) {
            StartEnterLua();
            game_lua_entry_.DoDestroy();
            EndEnterLua();
            StopWatchDeadLoop();
            game_lua_entry_ = null;
        }
    }

    void OnApplicationPause(bool pauseStatus)
    {
    }



    public void StartWatchDeadLoop() {
        StopWatchDeadLoop();
        watch_l = game_lua_entry_.lua_svr_.luaState.L;
        watch_thread = new Thread(new ThreadStart(Watch));
        watch_thread.Start();
    }

    public void StopWatchDeadLoop() {
        if (watch_thread != null) {
            watch_thread.Abort();
            watch_thread = null;
        }
    }

    public void StartEnterLua() {
        lock (watch_lock) {
            last_enter_lua_time = NativeAppUtils.GetTimeStamp();
        }
    }
    public void EndEnterLua() {
        lock (watch_lock) {
            last_enter_lua_time = 0;
        }
    }

    void Watch() {
        while (true) {
            lock (watch_lock) {
                if (last_enter_lua_time != 0) {
                    var time = NativeAppUtils.GetTimeStamp();
                    if (time - last_enter_lua_time > 10) {
                        LuaDLL.luaS_SetBreakSig(watch_l);
                    }
                }
            }
            Thread.Sleep(1000);
        }
    }

    //************************************************************以下是需要实现的回调接口*************************************************************************************************************************
    //callback
    public override void onInitSuccess()
    {
        showLog("onInitSuccess", "");
        //QuickSDK.getInstance ().login (); //如果游戏需要启动时登录，需要在初始化成功之后调用
    }

    public override void onInitFailed(ErrorMsg errMsg)
    {
        showLog("onInitFailed", "msg: " + errMsg.errMsg);
    }

    public override void onLoginSuccess(UserInfo userInfo)
    {
        showLog ("onLoginSuccess", "uid: " + userInfo.uid + " ,username: " + userInfo.userName + " ,userToken: " + userInfo.token + ", msg: " + userInfo.errMsg);
        //Application.LoadLevel ("scene2");
        SDK.onLoginSuccessResult = "qqqq";  //userInfo.userName;
        Debug.Log("userInfo.userName===" + userInfo.userName);
        SDK.CallLua("QuickSDKLoginResults",userInfo.userName);
    }

    public override void onSwitchAccountSuccess(UserInfo userInfo){
        //切换账号成功，清除原来的角色信息，使用获取到新的用户信息，回到进入游戏的界面，不需要再次调登录
        showLog ("onLoginSuccess", "uid: " + userInfo.uid + " ,username: " + userInfo.userName + " ,userToken: " + userInfo.token + ", msg: " + userInfo.errMsg);
        //Application.LoadLevel ("scene2");
    }

    public override void onLoginFailed (ErrorMsg errMsg)
    {
        showLog("onLoginFailed", "msg: "+ errMsg.errMsg);
        onExitSuccess ();
    }

    public override void onLogoutSuccess ()
    {
        showLog("onLogoutSuccess", "");
        //注销成功后回到登陆界面
        //Application.LoadLevel("scene1");
    }



    public override void onPaySuccess (PayResult payResult)
    {
        showLog("onPaySuccess", "orderId: "+payResult.orderId+", cpOrderId: "+payResult.cpOrderId+" ,extraParam"+payResult.extraParam);
    }

    public override void onPayCancel (PayResult payResult)
    {
        showLog("onPayCancel", "orderId: "+payResult.orderId+", cpOrderId: "+payResult.cpOrderId+" ,extraParam"+payResult.extraParam);
    }

    public override void onPayFailed (PayResult payResult)
    {
        showLog("onPayFailed", "orderId: "+payResult.orderId+", cpOrderId: "+payResult.cpOrderId+" ,extraParam"+payResult.extraParam);
    }

    public override void onExitSuccess ()
    {
        showLog ("onExitSuccess", "");
        //退出成功的回调里面调用  QuickSDK.getInstance ().exitGame ();  即可实现退出游戏，杀进程。为避免与渠道发生冲突，请不要使用  Application.Quit ();
        QuickSDK.getInstance ().exitGame ();
    }

    public override void onSucceed(string infos)
    {
        showLog("onSucceed", infos);
    }

    public override void onFailed(string message)
    {
        showLog("onFailed", "msg: " + message);
    }

}
