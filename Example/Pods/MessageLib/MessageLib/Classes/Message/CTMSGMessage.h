//
//  CTMSGMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMSGEnumDefine.h"

@class CTMSGReadReceiptInfo, CTMSGMessageContent;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGMessage : NSObject <NSCopying, NSCoding>

/*!
 会话类型
 */
@property(nonatomic, assign) CTMSGConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 消息的ID
 
 @discussion 本地存储的消息的唯一值（数据库索引唯一值）
 */
@property(nonatomic, assign) long messageId;

/*!
 消息的方向
 */
@property(nonatomic, assign) CTMSGMessageDirection messageDirection;

/*!
 消息的发送者ID
 */
@property(nonatomic, strong) NSString *senderUserId;

/*!
 消息的接收状态
 */
@property(nonatomic, assign) CTMSGReceivedStatus receivedStatus;

/*!
 消息的发送状态
 */
@property(nonatomic, assign) CTMSGSentStatus sentStatus;

/*!
 消息的接收时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long receivedTime;

/*!
 消息的发送时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long sentTime;

/*!
 消息的类型名
 */
@property(nonatomic, strong) NSString *objectName;

/*!
 消息的内容
 */
@property(nonatomic, strong) CTMSGMessageContent *content;

/*!
 消息的附加字段
 */
@property(nonatomic, strong) NSString *extra;

/*!
 全局唯一ID
 
 @discussion 服务器消息唯一ID（在同一个Appkey下全局唯一）
 */
@property(nonatomic, strong) NSString *messageUId;

/*!
 阅读回执状态
 */
@property(nonatomic, strong) CTMSGReadReceiptInfo *readReceiptInfo NS_UNAVAILABLE;

@property (nonatomic, assign) BOOL isLock;
@property (nonatomic, copy) NSString * lockNote;

/*!
 CTMSGMessage初始化方法
 
 @param  conversationType    会话类型
 @param  targetId            目标会话ID
 @param  messageDirection    消息的方向
 @param  messageId           消息的ID
 @param  content             消息的内容
 */
- (instancetype)initWithType:(CTMSGConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(CTMSGMessageDirection)messageDirection
                   messageId:(long)messageId
                     content:(CTMSGMessageContent *)content;
@end

NS_ASSUME_NONNULL_END
