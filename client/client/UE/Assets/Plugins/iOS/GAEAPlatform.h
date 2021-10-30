//
//  GAEASDK.h
//  GAEASDK
//
//  Created by GAEA on 2016/11/15.
//  Copyright © 2016年 GAEAMOBILE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/* SDK Version 4.0.1 */
@interface GAEAPlatform : NSObject

/*!
 @abstract
 SDK初始化接口
 
 @param gameId            游戏平台Id
 @param completion        初始化结果回调
 */
+ (void)initWithGameId:(NSString *)gameId completionHandler:(void(^)(BOOL success,NSString *message))completion;

/*!
 @abstract
 SDK登陆系统
 
 @param completion        登录结果回调
 */
+ (void)showLoginSystemWithCompletionHandler:(void(^)(NSDictionary *userInfo))completion;

/*!
 @abstract
 IAP支付接口
 
 @param productId         苹果商品Id
 @param serverId          充值服务器的Id
 @param payExt            透传参数，加钻石接口会将此参数原样回传给游戏服
 @param completion        充值结果回调
 */
+ (void)purchaseWithProductId:(NSString *)productId
                     serverId:(NSString *)serverId
                       payExt:(NSString *)payExt
            completionHandler:(void(^)(BOOL success, NSString *message))completion;


/*!
 @abstract
 显示用户中心
 
 @param serverId 服务器Id
 @param roleId   角色Id
 */
+ (void)showGaeaUserCenterWithServerId:(NSString *)serverId roleId:(NSString *)roleId;

/*!
 @abstract
 显示论坛系统
 
 @param roleId    角色标识
 @param roleName  角色名称
 */
+ (void)showGaeaForumWithRoleId:(NSString *)roleId roleName:(NSString *)roleName;

/*!
 @abstract
 显示客服系统
 
 @param serverId  服务器Id
 @param roleId    角色Id
 @param roleName  角色名称
 */
+ (void)showGaeaCustomerServiceWithServerId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName;

/*!
 @abstract
 SDK获取游戏从其他应用程序打开接口
 
 @discussion
 1.一般用作第三方登陆和分享的回调，跳出程序并回到应用时需要在应用的如下函数中调用
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;//iOS8及以下
 - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;//iOS9及上
 */
+ (BOOL)handleOpenUrl:(NSURL *)url application:(UIApplication *)application sourceApplication:(NSString *)sourceApplication;

/**
 *  @return SDK 版本号
 */
+ (NSString *)sdkVersion;

@end
NS_ASSUME_NONNULL_END
