//
//  CTMSGDHttpTool.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/11.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTMSGUserInfo, CTMSGDUserInfo;

#define CTMSGGHTTPTOOL [CTMSGDHttpTool shareInstance]

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGDHttpTool : NSObject

//@property(nonatomic, strong) NSMutableArray *allFriends;
//@property(nonatomic, strong) NSMutableArray *allChatHsitoryUsers;

+ (instancetype)shareInstance;

/**
 //根据userId获取用户信息 先从本地数据库获取 如果没有再从网络中获取

 @param userID 要获取用户的id
 @param completion 完成之后的回调
 */
- (void)getUserInfoByUserID:(NSString *)userID completion:(void (^)(CTMSGUserInfo *user))completion;

/**
 从网络获取用户信息

 @param userID 要获取用户的id
 @param completion 完成之后的回调
 */
- (void)getNewestUserInfoByUserID:(NSString *)userID completion:(void (^)(CTMSGUserInfo *user))completion;

//加入黑名单
- (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL result))result;

//从黑名单中移除
- (void)removeToBlacklist:(NSString *)userId complete:(void (^)(BOOL result))result;

//获取黑名单列表
- (void)getBlacklistcomplete:(void (^)(NSMutableArray *))blacklist NS_UNAVAILABLE;

//从demo server 获取用户的信息，更新本地数据库
- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(CTMSGDUserInfo *user))success
               failure:(void (^)(NSError *err))failure;

//获取到数据后直接更新本地数据库
- (void)updateUserInfo:(CTMSGUserInfo *)userInfo;

//获取版本信息
- (void)getVersioncomplete:(void (^)(NSDictionary *))versionInfo NS_UNAVAILABLE;

//获取用户详细资料 从网络获取
- (void)getUserDetailWithId:(NSString *)userId
                    success:(void (^)(CTMSGDUserInfo *user))success
                    failure:(void (^)(NSError *err))failure;

@end

NS_ASSUME_NONNULL_END
