//
//  CTMSGRecallNotificationMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

//#define CTMSGRecallNotificationMessageIdentifier @"CTMSG:RcNtf"

NS_ASSUME_NONNULL_BEGIN

/*!
 撤回通知消息的类型名
 */
extern NSString * const CTMSGRecallNotificationMessageIdentifier;

/*!
 撤回通知消息类
 */
@interface CTMSGRecallNotificationMessage : CTMSGMessageContent <NSCoding>

/*!
 发起撤回操作的用户ID
 */
@property(nonatomic, strong) NSString *operatorId;

/*!
 撤回的时间（毫秒）
 */
@property(nonatomic, assign) long long recallTime;

/*!
 原消息的消息类型名
 */
@property(nonatomic, strong) NSString *originalObjectName;

+ (instancetype)messageWithUserid:(NSString *)selfUid
                             time:(long long)recallTime
                      messageName:(NSString *)messageName;

@end

NS_ASSUME_NONNULL_END
