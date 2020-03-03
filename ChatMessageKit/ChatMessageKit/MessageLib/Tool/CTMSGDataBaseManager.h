//
//  CTMSGDataBaseManager.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMSGEnumDefine.h"

@class CTMSGUserInfo, CTMSGMessage, CTMSGConversation, CTMSGMessageContent;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGDataBaseManager : NSObject

+ (instancetype)shareInstance;

#pragma mark - message

- (long)insertMessageToDB:(CTMSGMessage *)message conversationType:(CTMSGConversationType)conversationType hasRead:(BOOL)hasRead;

/**
 将目标Id的所有信息设为已读

 @param targetId targetid
 @return BOOL
 */
- (BOOL)updateMessageReadStatusWithTargetId:(NSString *)targetId;
- (BOOL)removeMessageWithId:(NSInteger)messageId;
- (BOOL)removeMessageWithIds:(NSArray<NSString *> *)messageIds;
- (BOOL)removeMessagewithUid:(NSString *)messageUid;
- (BOOL)removeAllMessagewithTargetId:(NSString *)targetId;
- (void)updateMessageReadStatusWithId:(NSInteger)messageId NS_UNAVAILABLE;
- (void)updateMessageReadStatusWithUid:(NSInteger)messageUid NS_UNAVAILABLE;

- (long)searchMessagesSendTimeByMessageId:(NSString *)messageId;
- (CTMSGMessage *)searchMessagesByMessageId:(NSString *)messageId;
- (CTMSGMessage *)searchMessagesByMessageUid:(NSString *)messageUid;

/**
 查找关于某人的最新的20条消息

 @param targetId 对方的UID
 @return CTMSGMessage数组
 */
- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId;

/**
 查找关于某人的最新的N条消息

 @param targetId 对方的UID
 @param count 要查找多少条消息
 @return CTMSGMessage数组
 */
- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId count:(NSInteger)count;

/**
 查找关于某人的最新的N条消息
 
 @param targetId 对方的UID
 @param oldestMessageId 某条消息之前 不包括这条消息
 @param count 要查找多少条消息
 @return CTMSGMessage数组
 */
- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId oldestMessageId:(long)oldestMessageId count:(NSInteger)count;

/**
 查找关于某人的最新的N条消息

 @param targetId 对方的UID
 @param count 数量
 @param time 在某个时间之前收到的或者发出的消息
 @return CTMSGMessage数组
 */
- (NSArray<CTMSGMessage *> *)searchLatestMessagesByTargetId:(NSString *)targetId count:(NSInteger)count beforeTime:(NSInteger)time;

- (NSInteger)searchMessageCountWithTargetId:(NSString *)targetId;

- (BOOL)clearMessageDB;
- (BOOL)compressMessageDB;
#pragma mark - conversation

- (void)insertConversationToDB:(CTMSGConversation *)conversation;
- (void)insertConversationWithSendMessage:(CTMSGMessage *)message
                         conversationType:(CTMSGConversationType)conversationType;

- (void)insertConversationWithReceivedMessage:(CTMSGMessage *)message
                             conversationType:(CTMSGConversationType)conversationType
                                  unreadCount:(NSInteger)unreadCount;
- (BOOL)updateConversationToDB:(CTMSGConversation *)conversation NS_UNAVAILABLE;
- (BOOL)updateConversationDraft:(nullable NSString *)draft to:(NSString *)targetId;
- (BOOL)updateConversationTop:(BOOL)isTop to:(NSString *)targetId;
- (BOOL)updateConversationBlockStatus:(NSInteger)blockStatus to:(NSString *)targetId;
- (BOOL)updateConversationWithMessage:(CTMSGMessage *)message;
- (BOOL)updateConversationReadTime:(NSInteger)readTime to:(NSString *)targetId;

- (BOOL)removeConversationFromDB:(NSString *)targetId;

- (NSString *)searchConverstationDraft:(NSString *)targetId;

- (NSArray<CTMSGConversation *> *)searchConverstationList;

- (NSArray<CTMSGConversation *> *)searchDefaultConverstationList;
- (NSArray<CTMSGConversation *> *)searchConverstationListForCount:(int)count;
- (NSArray<CTMSGConversation *> *)searchConverstationListForCount:(int)count time:(long long)time;

//- (NSArray<CTMSGConversation *> *)searchConverstationListForCount:(int)count time:(long)time;

- (BOOL)clearConversationDB;
#pragma mark - user
//存储用户信息
- (void)insertUserToDB:(CTMSGUserInfo *)user;
- (void)updateUserToDBWithID:(CTMSGUserInfo *)user NS_UNAVAILABLE;
- (void)removeUserFromDB:(NSString *)userid;
- (CTMSGUserInfo *)searchUserInfoWithID:(NSString *)userid;

- (BOOL)clearUserDB;

#pragma mark - black

//- (BOOL)insertBlack:(CTMSGUserInfo *)user;
- (BOOL)insertBlackTargetId:(NSString *)targetId;
- (BOOL)removeBlackTargetId:(NSString *)targetId;
- (BOOL)isBlackInTable:(NSString *)targetId;

- (BOOL)clearBlackDB;

#pragma mark - sync
- (void)insertSycnWithUserid:(NSString *)userid syncTime:(NSInteger)syncTime sendTime:(NSInteger)sendTime NS_UNAVAILABLE;
- (BOOL)clearSyncDB NS_UNAVAILABLE;

#pragma mark - version
- (void)updateVersion:(NSString *)version kitVersion:(NSString *)kitVersion creatTime:(NSInteger)creatTime;
- (BOOL)clearVersionDB NS_UNAVAILABLE;

- (BOOL)clearAllDB;

#pragma mark - unread

- (int)searchUnreadCountWithTargetId:(NSString *)targetId;
- (int)searchTotalUnreadCount;

@end

NS_ASSUME_NONNULL_END
