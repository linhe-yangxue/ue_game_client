using SLua;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameEntry : Singleton<GameEntry> {
	private string cur_scene_path = null;

    static public string sGameVersion = "1.0";
    public GameLuaEntry game_lua_entry_ = null;

    public bool is_inited = false;
    public bool need_restart = false;

    public double last_enter_lua_time = 0;
    public Thread watch_thread = null;
    public System.IntPtr watch_l;
    public object watch_lock = new object();

    override protected void Awake() {
    	GameLog.InitGameLog();
    	base.Awake();
    }

    IEnumerator Start() {
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        AssetBundles.AssetBundleManager.Initialize();
        if (game_lua_entry_ == null) {
            game_lua_entry_ = new GameLuaEntry();
            yield return game_lua_entry_.DoInit();
        }
        is_inited = true;
        StartWatchDeadLoop();
    }

	void MyLoadScene(string scene_path) {
		if (cur_scene_path != scene_path) {
			cur_scene_path = scene_path;
			SceneManager.LoadScene(cur_scene_path, LoadSceneMode.Single);
		}
	}

    void Restart() {
        AssetBundles.AssetBundleManager.ClearAll();
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

}
