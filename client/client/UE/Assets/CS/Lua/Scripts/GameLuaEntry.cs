using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using SLua;

public class GameLuaEntry {

    LuaScriptReader _script_reader_ = null;
    bool _is_inited_ = false;

    public LuaSvr lua_svr_ = null;

    public void Check2Reload() {
        if (_script_reader_ != null) {
            _script_reader_.Check2Reload();
        }
    }

	// Use this for initialization
    public IEnumerator DoInit () {
        if (_is_inited_) {
            yield break;
        }
        _is_inited_ = true;

        LibLuaDLL.DoInit();

        _script_reader_ = new LuaScriptReader();
        _script_reader_.DoInit();

        lua_svr_ = new LuaSvr();
        yield return lua_svr_.Init();
        // MapMgrDLL.luaopen_map_manager(lua_svr_.luaState.L);
        lua_svr_.Start("GameEntry", "GameInit", "GameDestroy", "GameUpdate", "GameFixedUpdate", "GameLateUpdate");
	}
	
	// Update is called once per frame
	public void Update () {
        if (lua_svr_ != null) {
            lua_svr_.Update();
        }
	}

    public void FixUpdate() {
        if (lua_svr_ != null) {
            lua_svr_.FixUpdate();
        }
    }

    public void LateUpdate() {
        if (lua_svr_ != null) {
            lua_svr_.LateUpdate();
        }
    }

    public void DoDestroy() {
        if (lua_svr_ != null) {
            lua_svr_.Destroy();
        }
    }
}
