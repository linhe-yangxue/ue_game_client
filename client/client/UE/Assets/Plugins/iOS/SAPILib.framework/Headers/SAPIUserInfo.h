//
//  SAPIUserInfo.h
//  SAPILib
//
//  Created by jiangzhenjie on 15/11/12.
//  Copyright © 2015年 passport. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  SAPI 用户信息
 */
@interface SAPIUserInfo : NSObject

/**
 *  @brief 用户Id
 *
 *  @note 如果有转换成整型需求，请务必使用long long类型。
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nonnull) NSString *userId;

/**
 *  @brief 显示用户名
 *
 *  @discussion 该字段用作显示用途，当用户设置了用户名时，为设置的用户名；否则为打码后的手机或邮箱。
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nonnull) NSString *displayname;

/**
 *  @brief 用户自行设置的用户名
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nullable) NSString *username;

/**
 *  @brief 打码后的密保邮箱
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nullable) NSString *secureEmail;

/**
 *  @brief 打码后的密保手机
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nullable) NSString *secureMobile;

/**
 *  @brief 用户头像地址
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, strong, nonnull) NSString *portraitURLString;

/**
 *  @brief 用户是否设置了头像
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL isPortraitSetted;

/**
 *  @brief 用户是否半帐号
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL isIncompleteUser;

/**
 *  @brief 用户是否设置了密码
 *
 *  @available SAPI 7.0.0 and later
 */
@property (nonatomic, assign) BOOL havePwd;

/**
 *  @brief 根据字典生成实例
 *
 *  @param info 字典
 *
 *  @return SAPIUserInfo实例
 *
 *  @available SAPI 7.0.0 and later
 */
- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)info;

/**
 *  @brief 将实例转化为字典
 *
 *  @return 字典
 *
 *  @available SAPI 7.0.0 and later
 */
- (nonnull NSDictionary *)toDictionary;

@end
