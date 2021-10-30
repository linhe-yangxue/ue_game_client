//
//  GATA.h
//  GATA
//
//  Copyright © 2016年 GAEAMOBILE. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 区域类型 */
typedef enum : NSUInteger {
    GATARegionChina,
    GATARegionJapan,
    GATARegionKorea,
    GATARegionGlobal,
} GATARegion;

/**
 *  GATA类定义了数据SDK基础的配置及初始化方法
 *  @version 3.8.2
 */
@interface GATA : NSObject

/**
 *  游戏大区设置
 *
 *  @param region 区域参数
 */
+ (void)setRegion:(GATARegion)region;

/**
 *  启动并初始化SDK
 *
 *  @code
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
     [GATA startWithAppID:@"APP_ID" channel:@"CHANNEL"];
     // ...
 }
 *  @endcode
 *
 *  @param appId   游戏的id，与GaeaSDK的游戏ID不同，此id是需要由数据平台单独配置的
 *  @param channel 游戏的渠道 默认为 AppStore
 */
+ (void)startWithAppID:(NSString *)appId channel:(NSString *)channel;

/**
 *  设置是否输出调试日志 默认输出
 *
 *  @param value YES 显示, NO 不显示
 */
+ (void)setDebugLogEnabled:(BOOL)value;

/**
 *  设置是否启用崩溃报告收集，需在startWithAppID:channel之前调用，默认 YES 启用
 *
 *  @param value YES 启用, NO 不启用
 */
+ (void)setCrashReportingEnabled:(BOOL)value;

/**
 * 禁用远程推送通知，需在startWithAppID:channel之前调用
 *
 */
+ (void)disableRemoteNotifications;

/**
 *  记录自定义事件
 *
 *  @param eventName 事件标识名
 */
+ (void)logEvent:(NSString *)eventName;

/**
 *  记录自定义事件
 *
 *  @param eventName  事件标识名
 *  @param content    事件内容
 */
+ (void)logEvent:(NSString *)eventName content:(NSString *)content;

/**
 *  记录自定义事件
 *
 *  @param eventName  事件标识名
 *  @param parameters 事件参数字典
 */
+ (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

/**
 *  记录开始事件
 *  用于统计时间事件，beginEvent 和 endEvent 需要成对调用
 *  @param identifier  事件标识名
 */
+ (void)beginEvent:(NSString *)identifier;

/**
 *  记录结束事件
 *  用于统计时间事件，beginEvent 和 endEvent 需要成对调用
 *
 *  @param identifier  事件标识名
 *  @param parameters 事件内容
 */
+ (void)endEvent:(NSString *)identifier parameters:(NSDictionary *)parameters;

/**
 *  记录错误日志信息
 *
 *  @param error 错误信息
 */
+ (void)logError:(NSString *)error;

/**
 *  记录设备经纬度信息
 *
 *  @param latitude  纬度
 *  @param longitude 经度
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude;

/**
 *  @return SDK 版本号
 */
+ (NSString *)sdkVersion;

@end


/** 用户性别 */
typedef enum : NSUInteger {
    GATAGenderMale,
    GATAGenderFemale,
} GATAGender;

/**
 *  数据SDK用户角色注册、登录等相关接口
 */
@interface GATA (GATAUserRole)

/**
 *  GAEA平台登录
 *
 *  @param userId    用户ID
 */
+ (void)gaeaLoginWithUserId:(NSString *)userId;

/**
 *  游戏角色创建
 *
 *  @param roleId     角色ID
 *  @param serverId   分服ID
 */
+ (void)roleCreateWithRoleId:(NSString *)roleId serverId:(NSString *)serverId;

/**
 *  游戏角色登录
 *
 *  @param roleId    角色ID
 *  @param serverId  分服ID
 *  @param level     游戏角色等级
 */
+ (void)roleLoginWithRoleId:(NSString *)roleId serverId:(NSString *)serverId level:(int)level;

/**
 *  角色登出
 */
+ (void)roleLogout;

/**
 *  设置角色等级
 *
 *  @param level 等级
 */
+ (void)setLevel:(int)level;

@end






/** 任务类型 */
typedef enum {
    GATATaskTypeGuideLine,  // 新手任务
    GATATaskTypeMainLine,   // 主线任务
    GATATaskTypeBranchLine, // 分支任务
    GATATaskTypeDaily,      // 日常任务
    GATATaskTypeActivity,   // 活动任务
    GATATaskTypeOther       // 其他任务
} GATATaskType DEPRECATED_ATTRIBUTE;


@interface GATA (GATADeprecated)

/**
 *  GAEA平台登录
 *
 *  @param gaeaId    平台ID
 *  @param loginType 登录类型
 */
+ (void)gaeaLoginWithGaeaId:(NSString *)gaeaId loginType:(NSString *)loginType DEPRECATED_MSG_ATTRIBUTE("Please use gaeaLoginWithUserId: instead");

/**
 *  GAEA平台登录
 *
 *  @param gaeaId    平台ID
 */
+ (void)gaeaLoginWithGaeaId:(NSString *)gaeaId DEPRECATED_MSG_ATTRIBUTE("Please use gaeaLoginWithUserId: instead");

/**
 *  游戏角色创建
 *
 *  @param accountId  角色ID
 *  @param serverId   分服ID
 */
+ (void)roleCreateWithAccountId:(NSString *)accountId serverId:(NSString *)serverId DEPRECATED_MSG_ATTRIBUTE("Please use roleCreateWithRoleId: serverId: instead");

/**
 *  游戏角色登录
 *
 *  @param accountId 角色ID
 *  @param serverId  分服ID
 *  @param levelId   游戏角色等级
 */
+ (void)roleLoginWithAccountId:(NSString *)accountId serverId:(NSString *)serverId levelId:(int)levelId DEPRECATED_MSG_ATTRIBUTE("Please use roleLoginWithRoleId: serverId: level: instead");

/**
 *  注册远程推送通知，在 3.0.1 后的 SDK 初始化时默认已调用此方法，如需要自定义注册远程推送通知代码，请在startWithAppID:channel之前调用disableRemoteNotifications方法来禁用自动注册代码
 */
+ (void)registerForRemoteNotification DEPRECATED_ATTRIBUTE;

/**
 *  请求定位权限并获取当前地理位置
 *
 *  @param handler 定位完成回调 用来确定定位是否成功，成功的话返回经纬度
 */
+ (void)requestLocationWithCompletionHandler:(void (^)(BOOL success, double latitude, double longitude))handler DEPRECATED_ATTRIBUTE;

/**
 *  游戏充值接口
 *
 *  @param transactionId  交易序列号
 *  @param currencyAmount 充值金额
 *  @param currencyType   货币类型
 *  @param payChannel     支付渠道
 *  @param goodsId        商品ID
 *  @param success        交易状态 YES 成功, NO 失败
 */
+ (void)rechargeWithTransactionId:(NSString *)transactionId currencyAmount:(NSString *)currencyAmount currencyType:(NSString *)currencyType payChannel:(NSString *)payChannel goodsId:(NSString *)goodsId success:(BOOL)success DEPRECATED_MSG_ATTRIBUTE("Please use the server API ");

/**
 *  开始任务
 *
 *  @param taskId   任务标识
 *  @param taskType 任务类型
 */
+ (void)beginTask:(NSString *)taskId taskType:(GATATaskType)taskType DEPRECATED_ATTRIBUTE;

/**
 *  结束任务
 *
 *  @param taskId      任务标识
 *  @param success     结果 YES 成功, NO 失败
 *  @param description 描述信息
 */
+ (void)endTask:(NSString *)taskId success:(BOOL)success description:(NSString *)description DEPRECATED_ATTRIBUTE;

/**
 *  失去虚拟币（注意，通过购买物品造成的金币减少，此接口不适用）
 *
 *  @param coinNumber      失去虚拟币数量
 *  @param coinType        虚拟币类型
 *  @param reason          失去原因
 *  @param remainingNumber 剩余虚拟币总量
 */
+ (void)lostCoin:(NSInteger)coinNumber coinType:(NSString *)coinType reason:(NSString *)reason remaining:(NSInteger)remainingNumber DEPRECATED_ATTRIBUTE;

/**
 *  获得虚拟币
 *
 *  @param coinNumber      获得虚拟币数量
 *  @param coinType        虚拟币类型
 *  @param reason          获得原因
 *  @param remainingNumber 剩余虚拟币总量
 */
+ (void)gainCoin:(NSInteger)coinNumber coinType:(NSString *)coinType reason:(NSString *)reason remaining:(NSInteger)remainingNumber DEPRECATED_ATTRIBUTE;

/**
 *  道具购买
 *
 *  @param itemId          道具标识，需要保证该值在游戏中的唯一性，非空，最大32个字符
 *  @param itemType        道具类型，最大32个字符
 *  @param itemCount       道具数量
 *  @param virtualCurrency 购买的道具虚拟价值
 *  @param currencyType    货币类型
 *  @param consumePoint    付费点，用于有目的性的购买某个道具，比如为通过某一关卡，在关卡内购买道具，该参数可以为空
 *  @param levelId         角色等级标识
 */
+ (void)purchaseItem:(NSString *)itemId itemType:(NSString *)itemType itemCount:(int)itemCount virtualCurrency:(NSString *)virtualCurrency currencyType:(NSString *)currencyType consumePoint:(NSString *)consumePoint levelId:(int)levelId DEPRECATED_ATTRIBUTE;

/**
 *  消耗道具
 *
 *  @param itemId    道具标识，需要保证该值在游戏中的唯一性，非空，最大32个字符
 *  @param itemType  道具类型，最大32个字符
 *  @param itemCount 消耗道具数量
 *  @param reason    消耗道具的原因
 *  @param levelId   角色等级标识
 */
+ (void)consumeItem:(NSString *)itemId itemType:(NSString *)itemType itemCount:(int)itemCount reason:(NSString *)reason levelId:(int)levelId DEPRECATED_ATTRIBUTE;

/**
 *  获得道具
 *
 *  @param itemId    道具id或者名称，需要保证该值在游戏中的唯一性，非空，最大32个字符
 *  @param itemType  道具类型，最大32个字符
 *  @param itemCount 获得道具数量
 *  @param reason    获得道具的原因
 *  @param levelId   角色等级标识
 */
+ (void)getItem:(NSString *)itemId itemType:(NSString *)itemType itemCount:(int)itemCount reason:(NSString *)reason levelId:(int)levelId DEPRECATED_ATTRIBUTE;

@end
