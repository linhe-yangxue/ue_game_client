//
//  SAPIConfiguration.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/24.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAPILib.h"

@protocol SAPILoginDelegate;

/**
 *  SAPI 配置项
 */
@interface SAPIConfiguration : NSObject

#pragma mark - 必选配置
/**
 *  @brief  产品线标识
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) NSString *tpl;

/**
 *  @brief  appKey
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) NSString *appKey;

/**
 *  @brief  appId
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) NSString *appId;

/**
 *  @brief  环境类型
 *
 *  @see SAPIEnvironmentType
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign, readonly) SAPIEnvironmentType environmentType;

/**
 *  @brief  登录委托
 *
 *  @see SAPILoginDelegate
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, weak, readonly) id<SAPILoginDelegate> loginDelegate;

#pragma mark - 可选配置
/**
 *  @brief  帐号互通方式，默认为静默互通（云端控制，本地只作辅助）
 *
 *  @see SAPILoginShareType
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) SAPILoginShareType loginShareType;

/**
 *  @brief  产品线App升级时是否重新开启一次静默互通，默认为YES
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL silentShareOnUpgrade;

/**
 *  @brief  是否支持海外手机号登录和注册，默认为NO
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL supportForeignMobile;

/**
 *  @brief  短信登录是否支持语音验证码，默认为NO
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL supportVoiceVerifyOnSMSLogin;

/**
 *  @brief 是否使用HTTPS，默认为YES
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL useHTTPS;

/**
 *  @brief 是否支持快推登录注册，默认为NO
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL supportQuickUser;

/**
 *  @brief  第三方帐号与百度帐号绑定类型，默认为暗绑。
 *
 *  @see SAPIThirdBindType
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) SAPIThirdBindType thirdBindType;

/**
 *  @brief  微信AppId，当接入微信第三方登录时需要设置此字段
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nullable) NSString *weixinAppId;

#pragma mark - Initial
/**
 *  @brief  根据必选配置生成实例
 *
 *  @param tpl             产品线标识
 *  @param appKey          appKey
 *  @param appId           appId
 *  @param environmentType 环境类型
 *  @param loginDelegate   登录委托
 *
 *  @return SAPIConfiguration实例
 *
 *  @available SAPI 7.0.0 and later
 */
- (nonnull instancetype)initWithTPL:(nonnull NSString *)tpl
                             appKey:(nonnull NSString *)appKey
                              appId:(nonnull NSString *)appId
                    environmentType:(SAPIEnvironmentType)environmentType
                      loginDelegate:(nonnull id<SAPILoginDelegate>)loginDelegate;

/**
 *  @brief  根据必选配置生成实例
 *
 *  @param tpl             产品线标识
 *  @param appKey          appKey
 *  @param appId           appId
 *  @param environmentType 环境类型
 *  @param loginDelegate   登录委托
 *
 *  @return SAPIConfiguration实例
 *
 *  @available SAPI 7.0.0 and later
 */
+ (nonnull instancetype)configurationWithTPL:(nonnull NSString *)tpl
                                      appKey:(nonnull NSString *)appKey
                                       appId:(nonnull NSString *)appId
                             environmentType:(SAPIEnvironmentType)environmentType
                               loginDelegate:(nonnull id<SAPILoginDelegate>)loginDelegate;

@end
