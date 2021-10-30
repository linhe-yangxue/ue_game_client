//
//  SAPIManager.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/24.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAPIAccountService.h"

@class SAPIConfiguration;
@class SAPILoginModel;

/**
 *  SAPI 主类
 */
@interface SAPIManager : NSObject

/**
 *  @brief  全局配置项
 *
 *  @see SAPIConfiguration
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) SAPIConfiguration *configuration;

/**
 *  @brief  接口服务
 *
 *  @see SAPIAccountService
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) SAPIAccountService *accountService;

/**
 *  @brief 当前登录模型
 *
 *  @see SAPILoginModel
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nullable) SAPILoginModel *currentLoginModel;

/**
 *  @brief 当前登录帐号列表
 *
 *  @see SAPILoginModel;
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nullable) NSArray<SAPILoginModel *> *localLoginModels;

/**
 *  @brief SAPICUID
 *
 *  @discussion 使用此字段时请务必保证开启了Keychain Sharing并添加com.baidu.shareLoginAccount，否则固定返回123456789
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) NSString *SAPICUID;

/**
 *  @brief SAPI版本号
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, readonly, nonnull) NSString *version;

/**
 *  @brief  单例
 *
 *  @available SAPI 7.0.0 and later
 */
+ (nonnull instancetype)sharedInstance;

/**
 *  @brief  设置全局配置项。在使用SAPI之前必须调用此方法设置配置
 *
 *  @param configuration 配置
 *
 *  @see SAPIConfiguration
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)setupConfiguration:(nonnull SAPIConfiguration *)configuration;

/**
 *  @brief  使用现有登录模型进行登录
 *
 *  @param loginModel 登录模型
 *
 *  @see SAPILoginModel
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)loginWithLoginModel:(nonnull SAPILoginModel *)loginModel;

/**
 *  @brief  退出登录
 *
 *  @param loginModel 登录模型
 *
 *  @see SAPILoginModel
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)logoutWithLoginModel:(nonnull SAPILoginModel *)loginModel;

/**
 *  @brief 重置静默登录
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)resetSilenctLogin;

/**
 *  @brief  微信SSO授权完成后，处理微信和百度帐号绑定登录
 *
 *  @param code SSO授权后从微信SDK拿到的code
 *
 *  @see -[SAPILoginArgument startWeiXinSSOLogin]
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)handleWeiXinLoginWithCode:(nonnull NSString *)code;

/**
 *  @brief  QQ SSO授权完成后，处理QQ和百度帐号绑定登录
 *
 *  @param accessToken SSO授权后从QQ SDK拿到的accessToken
 *  @param openId      SSO授权后从QQ SDK拿到的openId
 *  @param appId       QQ AppId
 *
 *  @see -[SAPILoginArgument startQQSSOLogin]
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)handleQQLoginWithAccessToken:(nonnull NSString *)accessToken openId:(nonnull NSString *)openId qqAppId:(nonnull NSString *)appId;

@end
