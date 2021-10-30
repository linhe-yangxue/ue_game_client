//
//  SAPILoginDelegate.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/24.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAPIManager;
@class SAPILoginModel;

/**
 *  SAPI 登录委托
 */
@protocol SAPILoginDelegate <NSObject>

@required
/**
 *  @brief  登录成功回调
 *
 *  @param manager      SAPIManager对象
 *  @param loginModel   登录模型
 *  @param loginOptions 其他登录信息
 * 
 *  @see SAPIManager
 *  @see SAPILoginModel
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)manager:(nonnull SAPIManager *)manager didLoginSucceedWithLoginModel:(nonnull SAPILoginModel *)loginModel loginOptions:(nullable NSDictionary *)loginOptions;

/**
 *  @brief  登录失败回调
 *
 *  @param manager SAPIManager对象
 *  @param error   NSError对象
 *
 *  @see SAPIManager
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)manager:(nonnull SAPIManager *)manager didLoginFailedWithError:(nonnull NSError *)error;

/**
 *  @brief  退出登录成功回调
 *
 *  @param manager    SAPIManager对象
 *  @param loginModel 登录模型
 *  
 *  @see SAPIManager
 *  @see SAPILoginModel
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)manager:(nonnull SAPIManager *)manager didLogout:(nonnull SAPILoginModel *)loginModel;

@optional

/**
 *  @brief  静默互通登录成功回调
 *
 *  @param manager SAPIManager对象
 *  @param options 其他登录信息
 *
 *  @see SAPIManager
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)manager:(nonnull SAPIManager *)manager didSilenceLoginSucceedWithOptions:(nullable NSDictionary *)options;

/**
 *  @brief  登录成功前回调
 *
 *  @param manager    SAPIManager对象
 *  @param freshModel 将要登录成功的模型
 *
 *  @see SAPIManager
 *  @see SAPILoginModel
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)manager:(nonnull SAPIManager *)manager beforeLoginSucceed:(nonnull SAPILoginModel *)freshModel;

@end
