//
//  SAPIEnums.h
//  SAPILib
//
//  Created by jiangzhenjie on 16/1/22.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#ifndef SAPIEnums_h
#define SAPIEnums_h

/**
 *  @brief SAPI环境类型
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_ENUM(NSUInteger, SAPIEnvironmentType) {
    /**
     *  线上环境
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIEnvironmentTypeOnline,
    /**
     *  RD测试环境
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIEnvironmentTypeRD,
    /**
     *  QA测试环境
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIEnvironmentTypeQA,
};

/**
 *  @brief 第三方帐号与百度帐号绑定类型
 *
 *  @discussion
 *  <ul>
 *  <li>暗绑：第三方帐号登录成功后，后台生成一个百度帐号，将此百度帐号与第三方登录帐号进行自动绑定，对用户透明。</li>
 *  <li>明绑 - 第三方帐号登录成功后，出现绑定页面，让用户将第三方帐号与已有百度帐号进行绑定。</li>
 *  <li>选择绑定 - 第三方帐号登录成功后，出现绑定页面，让用户将第三方帐号与百度帐号进行绑定。可以绑定已有百度帐号或者自动绑定一个新的百度帐号。</li>
 *  <li>明绑且只能通过手机号登录 - 与明绑类似，但登录帐号只能是手机号。</li>
 *  </ul>
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_ENUM(NSUInteger, SAPIThirdBindType) {
    /**
     *  暗绑
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdBindTypeImplicit = 1,
    /**
     *  明绑
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdBindTypeExplicit,
    /**
     *  选择绑定
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdBindTypeOptional,
    /**
     *  明绑且只能通过手机号登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdBindTypeSMS,
};

/**
 *  @brief 第三方登录选项
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_OPTIONS(NSUInteger, SAPIThirdLoginOptions) {
    /**
     *  QQ登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginOptionQQ = 1 << 0,
    /**
     *  微信登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginOptionWeiXin = 1 << 1,
    /**
     *  新浪微博登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginOptionSina = 1 << 2,
};

/**
 *  @brief 第三方登录类型
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_ENUM(NSUInteger, SAPIThirdLoginType) {
    /**
     *  无
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginTypeNone = 0,
    /**
     *  QQ登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginTypeQQ = 15,
    /**
     *  微信登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginTypeWeiXin = 42,
    /**
     *  新浪微博登录
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIThirdLoginTypeSina = 2,
};

/**
 *  @brief 帐号互通方式（云端控制，本地仅为辅助作用）
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_ENUM(NSUInteger, SAPILoginShareType) {
    /**
     *  静默互通
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPILoginShareTypeSilence = 2,
    /**
     *  选择互通
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPILoginShareTypeChoice,
};

/**
 *  SAPI入口操作类型
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_ENUM(NSUInteger, SAPIActionType) {
    /**
     *  绑定控件
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIActionTypeBindWidget,
};

/**
 *  @brief 绑定控件类型
 *
 *  @available SAPI 7.0.0 and later
 */
typedef NS_ENUM(NSUInteger, SAPIBindWidgetType) {
    /**
     *  绑定手机
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIBindWidgetTypeBindMobile,
    /**
     *  换绑手机
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIBindWidgetTypeRebindMobile,
    /**
     *  解绑手机
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIBindWidgetTypeUnbindMobile,
    /**
     *  绑定邮箱
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIBindWidgetTypeBindEmail,
    /**
     *  换绑邮箱
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIBindWidgetTypeRebindEmail,
    /**
     *  解绑邮箱
     *
     *  @available SAPI 7.0.0 and later
     */
    SAPIBindWidgetTypeUnbindEmail,
};

/**
 *  @brief 扫码登录状态
 *
 *  @available SAPI 7.0.1 and later
 */
typedef NS_ENUM(NSUInteger, SAPIQRCodeLoginStatus) {
    /**
     *  Notice状态
     *
     *  @available SAPI 7.0.1 and later
     */
    SAPIQRCodeLoginStatusNotice,
    /**
     *  Cancel状态
     *
     *  @available SAPI 7.0.1 and later
     */
    SAPIQRCodeLoginStatusCancel,
};

#endif /* SAPIEnums_h */
