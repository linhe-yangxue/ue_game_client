//
//  SAPIAccountService.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/25.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SAPIEnums.h"

@class SAPIUserInfo;
@class SAPILoginModel;

/**
 *  SAPI 接口服务
 */
@interface SAPIAccountService : NSObject

/**
 *  @brief  获取用户信息
 *
 *  @param bduss        用户bduss
 *  @param success      成功时回调，返回一个SAPIUserInfo实例
 *  @param bdussExpired bduss失效时回调
 *  @param failure      失败时回调
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)getUserInfoWithBduss:(nonnull NSString *)bduss
                     success:(nonnull void (^)(SAPIUserInfo * _Nonnull userInfo))success
                bdussExpired:(nonnull void (^)())bdussExpired
                     failure:(nonnull void (^)(NSError * _Nullable error))failure;

/**
 *  @brief 重登录
 *
 *  @param uid   用户Uid
 *  @param bduss 用户bduss
 *
 *  @discussion 重登录成功后会回调-[SAPILoginDelegate manager:didLoginSucceedWithLoginModel:loginOptions:]方法，重登录失败后会回调-[SAPILoginDelegate manager:didLoginFailedWithError:]方法。
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)reloginWithUid:(nonnull NSString *)uid bduss:(nonnull NSString *)bduss;

/**
 *  @brief 获取短信登录动态密码
 *
 *  @param mobile  手机号
 *  @param captcha 命中反作弊策略时，需要输入图形验证码
 *  @param success 成功时回调
 *  @param failure 失败时回调。命中反作弊策略时，回传一张图形验证码，产品线需要展示给用户输入，然后再调用该方法获取短信登录动态密码
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)getDpassWithMobile:(nonnull NSString *)mobile
                   captcha:(nullable NSString *)captcha
                   success:(nonnull void(^)(void))success
                   failure:(nonnull void(^)(UIImage * _Nullable graphicsCaptcha, NSError * _Nonnull error))failure;

/**
 *  @brief 刷新图形验证码
 *
 *  @param handler 完成时回调
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)refreshCaptchaWithCompletionHandler:(nonnull void (^)(UIImage * _Nullable captchaImage))handler;

/**
 *  @brief 短信登录
 *
 *  @param mobile 手机号
 *  @param dpass  动态密码
 *
 *  @discussion 登录成功后回调-[SAPILoginDelegate manager:didLoginSucceedWithLoginModel:loginOptions:]方法，登录失败后会回调-[SAPILoginDelegate manager:didLoginFailedWithError:]方法。
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)loginWithMobile:(nonnull NSString *)mobile dpass:(nonnull NSString *)dpass;

/**
 *  @brief 上传头像
 *
 *  @param portraitData  头像Data
 *  @param mimeType      mime类型
 *  @param loginModel    登录模型
 *  @param success       成功时回调
 *  @param failure       失败时回调
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)uploadPortrait:(nonnull NSData *)portraitData
              mimeType:(nonnull NSString *)mimeType
            loginModel:(nonnull SAPILoginModel *)loginModel
               success:(nullable void(^)())success
               failure:(nullable void(^)(NSError * _Nullable error))failure;

/**
 *  @brief 补填用户名
 *
 *  @param username 用户名
 *  @param bduss    用户bduss
 *  @param success  成功时回调
 *  @param failure  失败时回调
 *
 *  @discussion 目前用户名不可修改，只能在用户未设置用户名的情况下进行补填用户名
 *
 *  @available SAPI 7.0.1 and later
 */
- (void)fillUsername:(nonnull NSString *)username
           withBduss:(nonnull NSString *)bduss
             success:(nonnull void(^)())success
             failure:(nonnull void(^)(NSError * _Nonnull error))failure;
@end

/**
 *  @brief Native和H5登录状态同步
 *
 *  @available SAPI 7.0.1 and later
 */
@interface SAPIAccountService (SAPINativeH5SyncAddition)

/**
 *  @brief H5向Native同步登录态
 *
 *  @discussion 该方法会自动读取百度域下的Bduss Cookie，然后将登录态同步到Native。同步成功后会回调登录成功-[SAPILoginDelegate manager:didLoginSucceedWithLoginModel:loginOptions:]，同步失败后会回调登录失败-[SAPILoginDelegate manager:didLoginFailedWithError:]。当百度域下的Cookie中不含有Bduss时，也会回调登录失败。同时，该方法需要请求网络。
 *
 *  @available SAPI 7.0.1 and later
 */
- (void)webToNativeLogin;

/**
 *  @brief 将Bduss写入Cookie中
 *
 *  @param bduss 用户bduss
 *
 *  @discussion Bduss将写入PASS授权域名中，目前授权域名包括.baidu.com, .nuomi.com, .hao123.com。
 *
 *  @available SAPI 7.0.1 and later
 */
- (void)setBdussToCookie:(nonnull NSString *)bduss;

/**
 *  @brief 获取百度域下Cookie的Bduss
 *
 *  @return 百度域下的Bduss
 *
 *  @available SAPI 7.0.1 and later
 */
- (nullable NSString *)getBdussFromCookie;

@end

/**
 *  @brief 扫码登录
 *
 *  @available SAPI 7.0.1 and later
 */
@interface SAPIAccountService (SAPIQRCodeLoginAddition)

/**
 *  @brief App到PC扫码登录状态同步
 *
 *  @param status  同步的状态
 *  @param text    扫描二维码后获取的文本
 *  @param success 成功时回调
 *  @param failure 失败时回调
 *
 *  @discussion 状态包括SAPIQRCodeLoginStatusNotice和SAPIQRCodeLoginStatusCancel两种，两种状态同步的调用时机如下：在扫码完成后，调用该方法同步SAPIQRCodeLoginStatusNotice状态，此时PC端的二维码界面变成扫码完成。当用户取消登录时，调用该方法同步SAPIQRCodeLoginStatusCancel状态。当用户确认登录时，调用qrCodeLoginFromAppToPCWithBduss:qrCodeText:success:failure:
 *
 *  @available SAPI 7.0.1 and later
 */
- (void)qrCodeLoginSyncStatusFromAppToPCWithStatus:(SAPIQRCodeLoginStatus)status
                                        qrCodeText:(nonnull NSString *)text
                                           success:(nonnull void(^)(NSDictionary * _Nonnull responseInfo))success
                                           failure:(nonnull void(^)(NSError * _Nonnull error))failure;
/**
 *  @brief App到PC扫码登录，将App的登录状态同步到PC端
 *
 *  @param bduss   用户bduss
 *  @param text    扫描二维码后获取的文本
 *  @param success 成功时回调
 *  @param failure 失败时回调
 *
 *  @discussion App到PC的扫码登录过程需要同步状态，详见qrCodeLoginSyncStatusFromAppToPCWithStatus:qrCodeText:success:failure:
 *
 *  @available SAPI 7.0.1 and later
 */
- (void)qrCodeLoginFromAppToPCWithBduss:(nonnull NSString *)bduss
                             qrCodeText:(nonnull NSString *)text
                                success:(nonnull void(^)(NSDictionary * _Nonnull responseInfo))success
                                failure:(nonnull void(^)(NSError * _Nonnull error))failure;

/**
 *  @brief PC到App扫码登录，将PC端的登录状态同步到App
 *
 *  @param text 扫描二维码后获取的文本
 *
 *  @discussion 扫码登录成功后回调-[SAPILoginDelegate manager:didLoginSucceedWithLoginModel:loginOptions:]方法，登录失败后回调-[SAPILoginDelegate manager:didLoginFailedWithError:]方法。
 *
 *  @available SAPI 7.0.1 and later
 */
- (void)qrCodeLoginFromPCToAppWithQRCodeText:(nonnull NSString *)text;

@end