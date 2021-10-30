package com.wpxgame.sdk;
import com.gata.android.gatasdkbase.GATAAgent;
import com.gata.android.gatasdkbase.GATAConstant;
import com.gata.android.gatasdkbase.util.system.GATADevice;
import com.haojiesdk.wrapper.HJConstant;
import com.haojiesdk.wrapper.HJCurrency;
import com.haojiesdk.wrapper.bean.HJInitInfo;
import com.haojiesdk.wrapper.bean.HJOrderInfo;
import com.haojiesdk.wrapper.bean.HJPayInfo;
import com.haojiesdk.wrapper.bean.HJUserInfo;
import com.haojiesdk.wrapper.imp.HJWrapper;
import com.haojiesdk.wrapper.listener.HJResultDispatchListener;
import com.haojiesdk.wrapper.util.HJInitUtil;
import com.unity3d.player.*;
import android.app.Activity;
import android.content.ClipData;
import android.content.ClipDescription;
import android.content.ClipboardManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.os.Vibrator;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class MainActivity extends Activity
{
    // -----------------------------------------------------------
    // unity
    // -----------------------------------------------------------
    protected UnityPlayer mUnityPlayer; // don't change the name of this variable; referenced from native code

    // Setup activity layout
    @Override protected void onCreate (Bundle savedInstanceState)
    {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);

        getWindow().setFormat(PixelFormat.RGBX_8888); // <--- This makes xperia play happy

        mUnityPlayer = new UnityPlayer(this);
        setContentView(mUnityPlayer);
        mUnityPlayer.requestFocus();
    }

    @Override protected void onNewIntent(Intent intent)
    {
        // To support deep linking, we need to make sure that the client can get access to
        // the last sent intent. The clients access this through a JNI api that allows them
        // to get the intent set on launch. To update that after launch we have to manually
        // replace the intent with the one caught here.
        setIntent(intent);
        HJWrapper.getInstance().onNewIntent(intent);
    }

    // Quit Unity
    @Override protected void onDestroy ()
    {
        HJWrapper.getInstance().onDestroy (this);
        mUnityPlayer.quit();
        super.onDestroy();
    }

    // Pause Unity
    @Override protected void onPause()
    {
        super.onPause();
        mUnityPlayer.pause();
        HJWrapper.getInstance().onPause (this);
    }

    // Resume Unity
    @Override protected void onResume()
    {
        super.onResume();
        mUnityPlayer.resume();
        HJWrapper.getInstance().onResume (this);
    }

    // Low Memory Unity
    @Override public void onLowMemory()
    {
        super.onLowMemory();
        mUnityPlayer.lowMemory();
    }

    // Trim Memory Unity
    @Override public void onTrimMemory(int level)
    {
        super.onTrimMemory(level);
        if (level == TRIM_MEMORY_RUNNING_CRITICAL)
        {
            mUnityPlayer.lowMemory();
        }
    }

    // This ensures the layout will be correct.
    @Override public void onConfigurationChanged(Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
        mUnityPlayer.configurationChanged(newConfig);
        HJWrapper.getInstance().onConfigurationChanged(this);
    }

    // Notify Unity of the focus change.
    @Override public void onWindowFocusChanged(boolean hasFocus)
    {
        super.onWindowFocusChanged(hasFocus);
        mUnityPlayer.windowFocusChanged(hasFocus);
    }

    // For some reason the multiple keyevent type is not supported by the ndk.
    // Force event injection by overriding dispatchKeyEvent().
    @Override public boolean dispatchKeyEvent(KeyEvent event)
    {
        if (event.getAction() == KeyEvent.ACTION_MULTIPLE)
            return mUnityPlayer.injectEvent(event);
        return super.dispatchKeyEvent(event);
    }

    // Pass any events not handled by (unfocused) views straight to UnityPlayer
    @Override public boolean onKeyUp(int keyCode, KeyEvent event)     { return mUnityPlayer.injectEvent(event); }
    @Override public boolean onKeyDown(int keyCode, KeyEvent event)   { return mUnityPlayer.injectEvent(event); }
    @Override public boolean onTouchEvent(MotionEvent event)          { return mUnityPlayer.injectEvent(event); }
    /*API12*/ public boolean onGenericMotionEvent(MotionEvent event)  { return mUnityPlayer.injectEvent(event); }


    // -----------------------------------------------------------
    // addition event
    // -----------------------------------------------------------
    @Override public void onStart() {
        super.onStart();
        mUnityPlayer.resume();
        HJWrapper.getInstance().onStart(this);
    }
    @Override public void onStop() {
        super.onStop();
        mUnityPlayer.pause();
        HJWrapper.getInstance().onStop (this);
    }

    @Override protected void onRestart() {
        super.onRestart();
        mUnityPlayer.resume();
        HJWrapper.getInstance().onRestart (this);
    }

    @Override public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        HJWrapper.getInstance().onActivityResult(this, requestCode, resultCode, data);
    }

    @Override protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        HJWrapper.getInstance().onSaveInstanceState(outState);
    }

    // -----------------------------------------------------------
    // base
    // -----------------------------------------------------------

    public static void CallLua(String func_name, JSONObject param) {
        try{
            JSONObject json = new JSONObject();
            json.put("func_name", func_name);
            json.put("param", param);
            UnityPlayer.UnitySendMessage("GameEntry", "CallLua", json.toString());
        } catch (JSONException e) {
            CatchError("CallLua", e);
        }
    }

    public static void CatchError(String type, Exception err) {
        try{
            err.printStackTrace();
            JSONObject json = new JSONObject();
            json.put("type", type);
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            err.printStackTrace(pw);
            json.put("err", sw.toString());
            sw.close();
            pw.close();
            UnityPlayer.UnitySendMessage("GameEntry", "CatchError", json.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static HashMap<String, String> JsonToStringHashMap(JSONObject object) throws JSONException {
        HashMap<String, String> map = new HashMap<String, String>();

        Iterator<String> keysItr = object.keys();
        while(keysItr.hasNext()) {
            String key = keysItr.next();
            String value = object.getString(key);
            map.put(key, value);
        }
        return map;
    }

    public static Map<String, Object> jsonToMap(JSONObject json) throws JSONException {
        Map<String, Object> retMap = new HashMap<String, Object>();

        if(json != JSONObject.NULL) {
            retMap = toMap(json);
        }
        return retMap;
    }

    public static Map<String, Object> toMap(JSONObject object) throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();

        Iterator<String> keysItr = object.keys();
        while(keysItr.hasNext()) {
            String key = keysItr.next();
            Object value = object.get(key);

            if(value instanceof JSONArray) {
                value = toList((JSONArray) value);
            }

            else if(value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            map.put(key, value);
        }
        return map;
    }

    public static List<Object> toList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();
        for(int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if(value instanceof JSONArray) {
                value = toList((JSONArray) value);
            }

            else if(value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            list.add(value);
        }
        return list;
    }
    // -----------------------------------------------------------
    // util
    // -----------------------------------------------------------
    public String EchoTest(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            return json.toString();
        } catch(Exception e) {
            CatchError("SetClipboardResult", e);
            return "";
        }
    }

    // 设置粘贴板
    public void SetClipboard(String json_str){
        try{
            JSONObject json = new JSONObject(json_str);
            String str = json.getString("str");
            ClipboardManager clipboard = (ClipboardManager) this.getSystemService(Activity.CLIPBOARD_SERVICE);
            ClipData textCd = ClipData.newPlainText("data", str);
            clipboard.setPrimaryClip(textCd);
        } catch (Exception e) {
            CatchError("SetClipboardResult", e);
        }
    }

    public String GetClipboard(String json_str) {
        try {
            ClipboardManager clipboard = (ClipboardManager) this.getSystemService(Activity.CLIPBOARD_SERVICE);
            String str = "";
            if (clipboard != null && clipboard.hasPrimaryClip()
                    && clipboard.getPrimaryClipDescription().hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN)) {
                ClipData cdText = clipboard.getPrimaryClip();
                ClipData.Item item = cdText.getItemAt(0);
                str = item.getText().toString();
            }
            JSONObject json = new JSONObject();
            json.put("str", str);
            return json.toString();
        } catch(Exception e){
            CatchError("GetClipboard", e);
            return "";
        }
    }

    public String GetBatteryState(String json_str) {
        try {
            JSONObject json = new JSONObject();
            IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
            Intent intent = registerReceiver(null, ifilter);
            json.put("level", intent.getIntExtra("level", 0)); // 获得当前电量
            json.put("scale", intent.getIntExtra("scale", 0)); //获得总电量
            json.put("status", intent.getIntExtra("status", 0)); //电池充电状态
            json.put("health", intent.getIntExtra("health", 0)); //电池健康状况
            json.put("batteryV", intent.getIntExtra("voltage", 0)); //电池电压(mv)
            json.put("temperature", intent.getIntExtra("temperature", 0)); //电池温度(数值)
            return json.toString();
        } catch (Exception e) {
            CatchError("GetBatteryState", e);
            return "";
        }
    }
    

    // -----------------------------------------------------------
    // gaea
    // -----------------------------------------------------------
    private HJResultDispatchListener<HJUserInfo> mHjResultDispatchListener = new HJResultDispatchListener<HJUserInfo>() {
        @Override
        public void dispatchResult(int code, String message, HJUserInfo hjUserInfo) {
            try{
                JSONObject json = new JSONObject();
                json.put("code", code);
                json.put("message", message);
                if (code == HJConstant.LOGIN_SUCCESS || code == HJConstant.SWITCHLOGIN_SUCCESS) {
                    json.put("userId", hjUserInfo.getUserId());
                    json.put("channel", hjUserInfo.getChannel());
                    json.put("token", hjUserInfo.getToken());
                    json.put("appId", hjUserInfo.getAppId());
                    json.put("ext", hjUserInfo.getExt());
                }
                CallLua("GaeaResult", json);
            } catch (Exception e) {
                CatchError("GaeaResult", e);
            }
        }
    };

    public void GaeaInit(String json_str){
        try{
            HJWrapper.getInstance().init(this, mHjResultDispatchListener);
        } catch (Exception e) {
            CatchError("GaeaInit", e);
        }
    }

    public void GaeaLogin(String json_str){
        try {
            HJWrapper.getInstance().login();
        } catch (Exception e) {
            CatchError("GaeaLogin", e);
        }
    }

    public void GaeaSwitchAccount(String json_str) {
        try {
            HJWrapper.getInstance().switchAccount();
        } catch (Exception e) {
            CatchError("GaeaSwitchAccount", e);
        }
    }

    public void GaeaLogout(String json_str) {
        try {
            HJWrapper.getInstance().logout();
        } catch (Exception e) {
            CatchError("GaeaLogout", e);
        }
    }

    public void GaeaExitGame(String json_str) {
        try {
            HJWrapper.getInstance().exitGame();
        } catch (Exception e) {
            CatchError("GaeaExitGame", e);
        }
    }

    public String GaeaIsShowUserCenter(String json_str) {
        try {
            JSONObject json = new JSONObject();
            json.put("is_show", HJWrapper.getInstance().isShowUserCenter());
            return json.toString();
        } catch(Exception e){
            CatchError("GaeaIsShowUserCenter", e);
            return "";
        }
    }

    public void GaeaUserCenter(String json_str) {
        try {
            HJWrapper.getInstance().enterUserCenter(this, new HJResultDispatchListener<String>() {
                @Override
                public void dispatchResult(int paramInt, String paramString, String paramT) {
                    try{
                        JSONObject json = new JSONObject();
                        json.put("paramInt", paramInt);
                        json.put("paramString", paramString);
                        json.put("paramT", paramT);
                        CallLua("GetClipboardResult", json);
                    } catch (Exception e) {
                        CatchError("GetClipboardResult", e);
                    }
                }
            });
        } catch (Exception e) {
            CatchError("GaeaUserCenter", e);
        }
    }

    public void GaeaSubmitExtendData(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            HJWrapper.getInstance().gaeaSubmitExtendData(this, json.getString("type"), json.getJSONObject("data"));
        } catch (Exception e) {
            CatchError("GaeaSubmitExtendData", e);
        }
    }

    public void GaeaPay(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            HJPayInfo pInfo = new HJPayInfo();
            pInfo.setMoneyAmount(new BigDecimal(json.getDouble("moneyAmount"))); // 单位元
            pInfo.setProductId(json.getString("productId"));
            pInfo.setProductName(json.getString("productName"));
            pInfo.setAppName(json.getString("appName"));
            pInfo.setCpInfo(json.getString("cpInfo"));
            pInfo.setAppUserId(json.getString("appUserId"));
            pInfo.setAppUserName(json.getString("appUserName"));
            pInfo.setAppUserLevel(json.getString("appUserLevel"));
            pInfo.setServerId(json.getString("serverId"));
            // 可选
            if (json.has("currency")) {
                pInfo.setCurrency(HJCurrency.valueOf(json.getString("currency")));
            }
            if (json.has("payExt")) {
                pInfo.setPayExt(json.getString("payExt"));
            }
            HJWrapper.getInstance().pay(this, pInfo, new HJResultDispatchListener<HJOrderInfo>() {
                @Override
                public void dispatchResult(int code, String message, HJOrderInfo orderInfo) {
                    try{
                        JSONObject json = new JSONObject();
                        json.put("code", code);
                        json.put("message", message);
                        if (code == HJConstant.PAY_SUCCESS) {
                            json.put("orderId", orderInfo.getOrderId());
                            json.put("orderAmount", orderInfo.getOrderAmount());
                            json.put("payWay", orderInfo.getPayWay());
                            json.put("payWayName", orderInfo.getPayWayName());
                        }
                        CallLua("GaeaPayResult", json);
                    } catch (Exception e) {
                        CatchError("GaeaPayResult", e);
                    }
                }
            });
        } catch (Exception e) {
            CatchError("GaeaPay", e);
        }
    }

    // -----------------------------------------------------------
    // gata
    // -----------------------------------------------------------
    public void GataSetCollectDeviceInfo(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setCollectDeviceInfo(json.getBoolean("isGet"));
        } catch (Exception e) {
            CatchError("GataSetCollectDeviceInfo", e);
        }
    }

    public void GataSetCollectAndroidID(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setCollectAndroidID(json.getBoolean("isGet"));
        } catch (Exception e) {
            CatchError("GataSetCollectAndroidID", e);
        }
    }

    public void GataSetCanLocation(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setCanLocation(json.getBoolean("canLocation"));
        } catch (Exception e) {
            CatchError("GataSetCanLocation", e);
        }
    }

    public void GataInitGATA(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAConstant.GATACountry country = GATAConstant.GATACountry.valueOf(json.getString("country"));
            GATAAgent.initGATA(this, country);
        } catch (Exception e) {
            CatchError("GataInitGATA", e);
        }
    }

    public void GataGaeaLogin(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.gaeaLogin(json.getString("userId"));
        } catch (Exception e) {
            CatchError("GataGaeaLogin", e);
        }
    }

    public void GataRoleCreate(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.roleCreate(json.getString("roleId"), json.getString("serverId"));
        } catch (Exception e) {
            CatchError("GataRoleCreate", e);
        }
    }
    public void GataRoleLogin(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.roleLogin(json.getString("roleId"), json.getString("serverId"), json.getInt("level"));
        } catch (Exception e) {
            CatchError("GataRoleLogin", e);
        }
    }
    public void GataRoleLogout(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.roleLogout();
        } catch (Exception e) {
            CatchError("GataRoleLogout", e);
        }
    }
    public void GataSetLevel(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setLevel(json.getInt("level"));
        } catch (Exception e) {
            CatchError("GataSetLevel", e);
        }
    }
    public void GataRegistDeviceToken(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.registDeviceToken(json.getString("deviceToken"));
        } catch (Exception e) {
            CatchError("GataRegistDeviceToken", e);
        }
    }
    public void GataSetEvent1(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setEvent(json.getString("eventName"));
        } catch (Exception e) {
            CatchError("GataSetEvent1", e);
        }
    }
    public void GataSetEvent2(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setEvent(json.getString("eventName"), json.getString("value"));
        } catch (Exception e) {
            CatchError("GataSetEvent2", e);
        }
    }
    public void GataSetEvent3(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setEvent(json.getString("eventName"), JsonToStringHashMap(json));
        } catch (Exception e) {
            CatchError("GataSetEvent3", e);
        }
    }
    public void GataBeginEvent(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.beginEvent(json.getString("eventName"));
        } catch (Exception e) {
            CatchError("GataBeginEvent", e);
        }
    }
    public void GataEndEvent(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.endEvent(json.getString("eventName"), JsonToStringHashMap(json));
        } catch (Exception e) {
            CatchError("GataEndEvent", e);
        }
    }
    public void GataSetError(String json_str) {
        try {
            JSONObject json = new JSONObject(json_str);
            GATAAgent.setError(json.getString("errorLog"));
        } catch (Exception e) {
            CatchError("GataSetError", e);
        }
    }
    public String GataGetVersionName(String json_str) {
        try {
            JSONObject json = new JSONObject();
            json.put("result", GATAAgent.getVersionName());
            return json.toString();
        } catch (Exception e) {
            CatchError("GataGetVersionName", e);
            return "";
        }
    }
    public String GataGetChannel(String json_str) {
        try {
            JSONObject json = new JSONObject();
            json.put("result", GATAAgent.getChannel());
            return json.toString();
        } catch (Exception e) {
            CatchError("GataGetChannel", e);
            return "";
        }
    }
    public String GataGetAppId(String json_str) {
        try {
            JSONObject json = new JSONObject();
            json.put("result", GATAAgent.getAppId());
            return json.toString();
        } catch (Exception e) {
            CatchError("GataGetAppId", e);
            return "";
        }
    }
    public String GataIsInitialized(String json_str) {
        try {
            JSONObject json = new JSONObject();
            json.put("result", GATAAgent.isInitialized());
            return json.toString();
        } catch (Exception e) {
            CatchError("GataIsInitialized", e);
            return "";
        }
    }
    public String GataGetDeviceInfo(String json_str) {
        try {
            JSONObject json = new JSONObject();
            json.put("deviceId", GATADevice.getDeviceId(this));
            if ((new JSONObject(json_str)).getString("country") == GATAConstant.GATACountry.GATA_CHINA.toString()) {
                json.put("deviceId1", GATADevice.getMac(this));
            } else {
                json.put("deviceId1", GATADevice.getDeviceId(this));
            }
            json.put("deviceId2", GATADevice.adId);
            return json.toString();
        } catch (Exception e) {
            CatchError("GataGetDeviceInfo", e);
            return "";
        }
    }
}