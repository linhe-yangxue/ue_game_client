//
//  SAPIBindWidgetArgument.h
//  SAPILib
//
//  Created by jiangzhenjie on 16/1/22.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import "SAPIArgument.h"
#import "SAPIEnums.h"

/**
 *  SAPI 绑定控件相关参数
 */
@interface SAPIBindWidgetArgument : SAPIArgument

/**
 *  @brief 绑定控件类型
 *
 *  @see SAPIBindWidgetType
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) SAPIBindWidgetType type;

/**
 *  @brief 用户登录态
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nonnull) NSString *bduss;

/**
 *  @brief 是否处理绑定手机号冲突，默认为YES
 *
 *  @discussion 绑定冲突是指在绑定或者换绑时，用户输入的手机号已被其他帐号绑定，此时弹出提示，用户可以选择用手机号登录或者继续绑定（在原帐号可解绑手机的情况下）或者换其他手机号（在原帐号不能解绑手机的情况下）。
 *
 *  @see mobileCollisionHandler
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL handleBindMobileConflict;

/**
 *  @brief 操作成功回调
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nonnull) void (^successHandler)();

/**
 *  @brief 手机号冲突回调
 *
 *  @discussion 当handleBindMobileConflict为YES时，必须实现该回调以处理绑定冲突
 *
 *  @see handleBindMobileConflict
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nonnull) void (^mobileCollisionHandler)(NSString * _Nonnull mobile);

/**
 *  @brief 操作失败回调
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nullable) void (^failureHandler)(NSError * _Nullable error);

/**
 *  @brief 简便的初始化函数
 *
 *  @param type           绑定控件类型
 *  @param bduss          用户Bduss
 *  @param successHandler 成功时回调
 *
 *  @return SAPIBindWidgetArgument实例
 *
 *  @available SAPI 7.0.0 and later
 */
+ (nonnull instancetype)argumentWithType:(SAPIBindWidgetType)type
                                   bduss:(nonnull NSString *)bduss
                          successHandler:(nonnull void(^)())successHandler;

@end
