//
//  CTMSGUser.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGUserInfo : NSObject

/*!
 用户ID
 */
@property(nonatomic, strong) NSString *userId;

/*!
 用户名称
 */
@property(nonatomic, strong) NSString *name;

/*!
 用户头像的URL
 */
@property(nonatomic, strong) NSString *portraitUri;

/*!
 当前用户是否为VIP
 */
@property(nonatomic, assign) BOOL isVip;

/*!
 用户信息的初始化方法 默认非VIP
 
 @param userId      用户ID
 @param username    用户名称
 @param portrait    用户头像的URL
 @return            用户信息对象
 */
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait;

/*!
 用户信息的初始化方法
 
 @param userId      用户ID
 @param username    用户名称
 @param portrait    用户头像的URL
 @param isVip       是否为VIP
 @return            用户信息对象
 */
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait isVip:(BOOL)isVip;

@end

NS_ASSUME_NONNULL_END
