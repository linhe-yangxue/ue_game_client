//
//  UIViewController+SAPIActionAddition.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/23.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAPIEnums.h"
#import "SAPIArgument.h"
#import "SAPILoginArgument.h"
#import "SAPIRegisterArgument.h"

/**
 *  SAPI Action Category，产品线可通过这些方法调起页面
 */
@interface UIViewController (SAPIActionAddition)

/**
 *  @brief 以present方式打开登录页面
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)sapi_presentLoginViewController;

/**
 *  @brief 以present方式打开登录页面
 *
 *  @param argument 登录参数
 *
 *  @see SAPILoginArgument
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)sapi_presentLoginViewControllerWithArgument:(nullable SAPILoginArgument *)argument;

/**
 *  @brief 以present方式打开注册页面
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)sapi_presentRegisterViewController;

/**
 *  @brief 以present方式打开注册页面
 *
 *  @param argument 注册参数
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)sapi_presentRegisterViewControllerWithArgument:(nullable SAPIRegisterArgument *)argument;

/**
 *  @brief  以present方式打开一个页面
 *
 *  @param type     操作类型
 *  @param argument 参数
 *
 *  @see SAPIActionType
 *  @see SAPIArgument
 *
 *  @available SAPI 7.0.0 and later
 */
- (void)sapi_presentViewControllerWithType:(SAPIActionType)type
                                  argument:(nullable SAPIArgument *)argument;

@end
