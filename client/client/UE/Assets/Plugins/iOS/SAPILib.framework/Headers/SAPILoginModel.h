//
//  SAPILoginModel.h
//  SAPILib
//
//  Created by jiangzhenjie on 16/1/13.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAPIEnums.h"

/**
 *  SAPI 登录模型
 */
@interface SAPILoginModel : NSObject

/**
 *  @brief 用户Id
 *
 *  @note 如果有转换成整型需求，请务必使用long long类型。
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nonnull) NSString *uid;

/**
 *  @brief 用户登录态
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nonnull) NSString *bduss;

/**
 *  @brief 显示用户名
 *
 *  @discussion 该字段用作显示用途，当用户设置了用户名时，为设置的用户名；否则为打码后的手机或邮箱。
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nonnull) NSString *displayname;

/**
 *  @brief 用户自行设置的用户名
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nullable) NSString *uname;

/**
 *  @brief  帐号登录来源，一般为App名称
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, readonly, nonnull) NSString *sourceApp;

/**
 *  @brief  第三方登录端类型
 *
 *  @see SAPIThirdLoginType
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) SAPIThirdLoginType thirdType;

/**
 *  @brief  第三方登录用户头像地址
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, copy, nullable) NSString *thirdPortraitURLString;

/**
 *  @brief  根据uid，bduss，displayname生成实例
 *
 *  @discussion 若uid，bduss，displayname中存在任一为空，则返回nil
 *
 *  @param uid         用户uid
 *  @param bduss       用户bduss
 *  @param displayname 显示用户名
 *
 *  @return SAPILoginModel实例
 *
 *  @available SAPI 7.0.0 and later
 */
- (nullable instancetype)initWithUid:(nonnull NSString *)uid bduss:(nonnull NSString *)bduss displayname:(nonnull NSString *)displayname;

/**
 *  @brief  根据键值对生成实例
 *
 *  @param dictionary 键值对
 *
 *  @return SAPILoginModel实例
 *
 *  @available SAPI 7.0.0 and later
 */
- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;

/**
 *  @brief  将实例对象转成键值对
 *
 *  @return 键值对
 *
 *  @available SAPI 7.0.0 and later
 */
- (nonnull NSDictionary *)toDictionary;

@end
