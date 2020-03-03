//
//  CTMSGUserInfoManager.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageLib/CTMSGUserInfo.h>
//#import "CTMSGDUserInfo.h"

//@class CTMSGUserInfo;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGUserInfoManager : NSObject

+ (instancetype)shareInstance;

//通过用户Id获取用户信息
- (void)getUserInfo:(NSString *)userId completion:(void (^)(CTMSGUserInfo *))completion;

//通过好友Id从数据库中获取好友的用户信息
- (CTMSGUserInfo *)getUserInfoFromDB:(NSString *)userId NS_UNAVAILABLE;

//如有好友备注，则显示备注
- (NSArray *)getConversationList:(NSArray *)conversationList NS_UNAVAILABLE;

//通过userId设置默认的用户信息
+ (CTMSGUserInfo *)generateDefaultUserInfo:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
