//
//  UINavigationController+SAPIActionAddition.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/23.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAPIEnums.h"
#import "SAPIArgument.h"

/**
 *  SAPI Action Category，产品线可通过这些方法调起页面
 */
@interface UINavigationController (SAPIActionAddition)

/**
*  @brief  以push方式打开一个页面
*
*  @param type     操作类型
*  @param argument 参数
*
*  @see SAPIActionType
*  @see SAPIArgument
*
*  @available SAPI 7.0.0 and later
*/
- (void)sapi_pushViewControllerWithType:(SAPIActionType)type
                               argument:(nullable SAPIArgument *)argument;

@end
