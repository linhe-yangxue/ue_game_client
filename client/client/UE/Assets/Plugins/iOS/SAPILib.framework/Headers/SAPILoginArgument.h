//
//  SAPILoginArgument.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/28.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAPIEnums.h"
#import "SAPIArgument.h"

/**
 *  SAPI 登录相关参数
 */
@interface SAPILoginArgument : SAPIArgument

/**
 *  @brief  第三方登录选项，默认为0。
 *
 *  @see SAPIThirdLoginOptions
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) SAPIThirdLoginOptions thirdLoginOptions;

/**
 *  @brief  短信登录预设手机号，默认为空。
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nullable) NSString *placeholderPhoneNumberForSMSLogin;

/**
 *  @brief  QQ第三方登录是否使用Oauth方式，默认为NO。
 *
 *  @discussion 建议接入QQ第三方登录时，首先判断是否能用SSO登录，不能时设置此字段为YES，使用OAuth方式登录。
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL enableQQOAuthLogin;

/**
 *  @brief 登录页面点击微信登录时回调。
 *
 *  @discussion 产品线应在此回调中调起微信App进行授权，授权完成拿到微信code后通过-[SAPIManager handleWeiXinLoginWithCode:]方法与百度帐号绑定
 *
 *  @see -[SAPIManager handleWeiXinLoginWithCode:]
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nullable) void (^startWeiXinSSOLogin)();

/**
 *  @brief 登录页面点击QQ登录时回调。
 *
 *  @discussion 产品线应在此回调中调起QQ App进行授权，授权完成拿到QQ accessToken，openId后通过-[SAPIManager handleQQLoginWithAccessToken:openId:qqAppId:]方法与百度帐号绑定
 *
 *  @see -[SAPIManager handleQQLoginWithAccessToken:openId:qqAppId:]
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nullable) void (^startQQSSOLogin)();

@end
