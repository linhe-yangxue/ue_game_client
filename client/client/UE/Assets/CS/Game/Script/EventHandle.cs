using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Text;
using System.Collections.Generic;
using JSON;
using quicksdk;

public class EventHandle
{

    private static EventHandle _instance;

    public static EventHandle getInstance() {
        if( null == _instance ) {
            _instance = new EventHandle();
        }
        return _instance;
    }
	//public GameObject mExitDialogCanvas;
	void showLog(string title, string message)
	{
		Debug.Log ("title: " + title + ", message: " + message);
	}
	// Use this for initialization

	public void Start () {
		Debug.Log ("lyy  start " );
//		mExitDialogCanvas = GameObject.Find ("ExitDialog");
//		if (mExitDialogCanvas != null) {
//			mExitDialogCanvas.SetActive (false);
//		}

	}

	public void test()
    {
        JsonObject json = new JsonObject();
        json.SetString("gameRoleID", "9090");
        json.SetString("gameRoleLevel", "111");
        json.SetString("gameRoleName", "看似回复");
        SDK.CallLuaTest("sdkquick", json.ToString());
    }

	public void Init()
	{
		Debug.Log("进入QuickSDK初始化Init--==============");
	}
	public void onLogin()
	{
		Debug.Log("完成QuickSDK登陆onLogin--==============");
	}

	public void onLogout()
	{
		QuickSDK.getInstance ().logout ();

	}


	public void onPay(string recharge_id,string recharge_count,string count)
	{
	    Debug.Log("支付成功====" + recharge_id + "333==" + recharge_count + "444===" + count);
		OrderInfo orderInfo = new OrderInfo();
		GameRoleInfo gameRoleInfo = new GameRoleInfo();
		int counts = 0;
		int.TryParse(count, out counts);
		double recharge = 0;
		double.TryParse(recharge_count, out recharge);

        Debug.Log("支付=======" + counts + "ffff" + recharge);
		orderInfo.goodsID = recharge_id;
		orderInfo.goodsName = "钻石";
		orderInfo.goodsDesc = "";
		orderInfo.quantifier = "个";
		orderInfo.extrasParams = "extparma";
		orderInfo.count = counts;
		orderInfo.amount = recharge;
		orderInfo.price = recharge;
		orderInfo.callbackUrl = "";
		orderInfo.cpOrderID = "";
		
		gameRoleInfo.gameRoleBalance = "";
		gameRoleInfo.gameRoleID = "";
		gameRoleInfo.gameRoleLevel = "";
		gameRoleInfo.gameRoleName = "";
		gameRoleInfo.partyName = "";
		gameRoleInfo.serverID = "";
		gameRoleInfo.serverName = "";
		gameRoleInfo.vipLevel = "";
		gameRoleInfo.roleCreateTime = "";
		QuickSDK.getInstance ().pay (orderInfo, gameRoleInfo);
	}
	public void onEnterYunKeFuCenter()
	{
		GameRoleInfo gameRoleInfo = new GameRoleInfo();
		gameRoleInfo.gameRoleBalance = "0";
		gameRoleInfo.gameRoleID = "11111";
		gameRoleInfo.gameRoleLevel = "1";
		gameRoleInfo.gameRoleName = "钱多多";
		gameRoleInfo.partyName = "同济会";
		gameRoleInfo.serverID = "1";
		gameRoleInfo.serverName = "火星服务器";
		gameRoleInfo.vipLevel = "1";
		gameRoleInfo.roleCreateTime = "roleCreateTime";
		QuickSDK.getInstance ().enterYunKeFuCenter (gameRoleInfo);
	}

		public void onCallSDKShare()
	{
		ShareInfo shareInfo = new ShareInfo();
		shareInfo.title = "这是标题";
		shareInfo.content = "这是描述";
		shareInfo.imgPath = "https://www.baidu.com/";
		shareInfo.imgUrl = "https://www.baidu.com/";
		shareInfo.url = "https://www.baidu.com/";
		shareInfo.type = "url_link";
		shareInfo.shareTo = "0";
		shareInfo.extenal = "extenal";
		QuickSDK.getInstance ().callSDKShare (shareInfo);
	}
	
	public void onCreatRole(string urs,string role_name,string role_id){
		//注：GameRoleInfo的字段，如果游戏有的参数必须传，没有则不用传
		Debug.Log("创建角色前的信息=======" + urs + "666" + role_name + "777" + role_id);
		GameRoleInfo gameRoleInfo = new GameRoleInfo();

		gameRoleInfo.gameRoleBalance = "";
		gameRoleInfo.gameRoleID = role_id;
		gameRoleInfo.gameRoleLevel = "";
		gameRoleInfo.gameRoleName = role_name;
		gameRoleInfo.partyName = "";
		gameRoleInfo.serverID = "";
		gameRoleInfo.serverName = "";
		gameRoleInfo.vipLevel = "";
		gameRoleInfo.roleCreateTime = "";//UC与1881渠道必传，值为10位数时间戳

		gameRoleInfo.gameRoleGender = "";//360渠道参数
		gameRoleInfo.gameRolePower="";//360渠道参数，设置角色战力，必须为整型字符串
		gameRoleInfo.partyId="";//360渠道参数，设置帮派id，必须为整型字符串

		gameRoleInfo.professionId = "";//360渠道参数，设置角色职业id，必须为整型字符串
		gameRoleInfo.profession = "";//360渠道参数，设置角色职业名称
		gameRoleInfo.partyRoleId = "";//360渠道参数，设置角色在帮派中的id
		gameRoleInfo.partyRoleName = ""; //360渠道参数，设置角色在帮派中的名称
		gameRoleInfo.friendlist = "";//360渠道参数，设置好友关系列表，格式请参考：http://open.quicksdk.net/help/detail/aid/190


		QuickSDK.getInstance ().createRole(gameRoleInfo);//创建角色
	}
	
	public void onEnterGame(string role_id,string role_level,string role_name,string party_name,string server_id,string server_name,string vip_level, string role_create_time){
	    Debug.Log("进入游戏======" + role_id + "111==" + role_level + "222==" + role_name + "333==" + party_name + "444==" + server_id + "555==" + server_name + "555==" + vip_level  + "666==" + role_create_time);
		QuickSDK.getInstance().callFunction(FuncType.QUICK_SDK_FUNC_TYPE_REAL_NAME_REGISTER);
		//注：GameRoleInfo的字段，如果游戏有的参数必须传，没有则不用传
		GameRoleInfo gameRoleInfo = new GameRoleInfo();
		
		gameRoleInfo.gameRoleBalance = "";
		gameRoleInfo.gameRoleID = role_id;
		gameRoleInfo.gameRoleLevel = role_level;
		gameRoleInfo.gameRoleName = role_name;
		gameRoleInfo.partyName = party_name;
		gameRoleInfo.serverID = server_id;
		gameRoleInfo.serverName = server_name;
		gameRoleInfo.vipLevel = vip_level;
		gameRoleInfo.roleCreateTime = role_create_time;//UC与1881渠道必传，值为10位数时间戳
		
		gameRoleInfo.gameRoleGender = "";//360渠道参数
		gameRoleInfo.gameRolePower="";//360渠道参数，设置角色战力，必须为整型字符串
		gameRoleInfo.partyId="";//360渠道参数，设置帮派id，必须为整型字符串
		
		gameRoleInfo.professionId = "";//360渠道参数，设置角色职业id，必须为整型字符串
		gameRoleInfo.profession = "";//360渠道参数，设置角色职业名称
		gameRoleInfo.partyRoleId = "";//360渠道参数，设置角色在帮派中的id
		gameRoleInfo.partyRoleName = ""; //360渠道参数，设置角色在帮派中的名称
		gameRoleInfo.friendlist = "";//360渠道参数，设置好友关系列表，格式请参考：http://open.quicksdk.net/help/detail/aid/190

		
		QuickSDK.getInstance ().enterGame (gameRoleInfo);//开始游戏
		//Application.LoadLevel("scene4");
	}
	
	public void onUpdateRoleInfo(string role_id,string role_level,string role_name,string party_name,string server_id,string server_name,string vip_level, string role_create_time)
	{
	    Debug.Log("角色升级等级===" + role_level);
		//注：GameRoleInfo的字段，如果游戏有的参数必须传，没有则不用传
		GameRoleInfo gameRoleInfo = new GameRoleInfo();
		
		gameRoleInfo.gameRoleBalance = "";
		gameRoleInfo.gameRoleID = role_id;
		gameRoleInfo.gameRoleLevel = role_level;
		gameRoleInfo.gameRoleName = role_name;
		gameRoleInfo.partyName = party_name;
		gameRoleInfo.serverID = server_id;
		gameRoleInfo.serverName = server_name;
		gameRoleInfo.vipLevel = vip_level;
		gameRoleInfo.roleCreateTime = role_create_time;//UC与1881渠道必传，值为10位数时间戳
		
		gameRoleInfo.gameRoleGender = "";//360渠道参数
		gameRoleInfo.gameRolePower="";//360渠道参数，设置角色战力，必须为整型字符串
		gameRoleInfo.partyId="";//360渠道参数，设置帮派id，必须为整型字符串
		
		gameRoleInfo.professionId = "";//360渠道参数，设置角色职业id，必须为整型字符串
		gameRoleInfo.profession = "";//360渠道参数，设置角色职业名称
		gameRoleInfo.partyRoleId = "";//360渠道参数，设置角色在帮派中的id
		gameRoleInfo.partyRoleName = ""; //360渠道参数，设置角色在帮派中的名称
		gameRoleInfo.friendlist = "";//360渠道参数，设置好友关系列表，格式请参考：http://open.quicksdk.net/help/detail/aid/190
		
		QuickSDK.getInstance ().updateRole(gameRoleInfo);
	}

	public void onNext(){
		Application.LoadLevel ("scene3");
	}

	public void onExit(){
		if(QuickSDK.getInstance().isChannelHasExitDialog ()){
			QuickSDK.getInstance().exit();
		}else{
			//游戏调用自身的退出对话框，点击确定后，调用QuickSDK的exit()方法
			//mExitDialogCanvas.SetActive(true);
		}
	}
		
	public void onExitCancel(){
	}
	public void onExitConfirm(){
		QuickSDK.getInstance().exit ();
	}

	public void onShowToolbar()
	{
		QuickSDK.getInstance ().showToolBar (ToolbarPlace.QUICK_SDK_TOOLBAR_BOT_LEFT);
	}

	public void onHideToolbar()
	{
		QuickSDK.getInstance ().hideToolBar ();
	}

	public void onEnterUserCenter()
	{
		QuickSDK.getInstance ().callFunction (FuncType.QUICK_SDK_FUNC_TYPE_ENTER_USER_CENTER);
	}

	public void onEnterBBS()
	{
		QuickSDK.getInstance ().callFunction (FuncType.QUICK_SDK_FUNC_TYPE_ENTER_BBS);
	}
	public void onEnterCustomer()
	{
		QuickSDK.getInstance ().callFunction (FuncType.QUICK_SDK_FUNC_TYPE_ENTER_CUSTOMER_CENTER);
	}
    public void onGetGoodsInfos()
    {
        showLog("onGetGoodsInfos", "onGetGoodsInfos 方法已被调用");
        QuickSDK.getInstance().callFunction (FuncType.QUICK_SDK_FUNC_TYPE_QUERY_GOODS_INFO);
    }
    public void onUserId()
	{
		string uid = QuickSDK.getInstance ().userId();
		showLog("userId", uid);
	}
	public void ongetDeviceId()
	{
		string deviceId = QuickSDK.getInstance().getDeviceId();
		showLog("deviceId", deviceId);
	}
	public void onChannelType()
	{
		int type = QuickSDK.getInstance ().channelType ();
		showLog("channelType", ""+type);
	}
	public void onFuctionSupport(int type)
	{
		bool supported = QuickSDK.getInstance ().isFunctionSupported ((FuncType)type);
		showLog("fuctionSupport", supported?"yes":"no");
	}
	public void onGetConfigValue(string key)
	{
		string value = QuickSDK.getInstance ().getConfigValue (key);
		showLog("onGetConfigValue", key + ": "+value);
	}

	public void onPauseGame()
	{
		Time.timeScale = 0;
		QuickSDK.getInstance ().callFunction (FuncType.QUICK_SDK_FUNC_TYPE_PAUSED_GAME);
	}

	public void onResumeGame()
	{
		Time.timeScale = 1;
	}
}

