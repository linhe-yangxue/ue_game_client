//
//  SAPIArgument.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/12/28.
//  Copyright © 2015年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  SAPI 基础参数
 */
@interface SAPIArgument : NSObject

/**
 *  @brief  参数，以Key:Value形式传入
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nullable) NSDictionary *argumentInfo;

/**
 *  @brief 检查argument是否可用
 *
 *  @return 当非空参数为空时，返回NO，其他情况返回YES。
 *
 *  @available SAPI 7.0.0 and later
 */
- (BOOL)checkAvailability;

@end
