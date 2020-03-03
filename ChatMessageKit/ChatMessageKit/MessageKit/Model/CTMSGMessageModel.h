//
//  CTMSGMessageModel.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTMSGEnumDefine.h"

@class CTMSGMessage, CTMSGUserInfo, CTMSGMessageContent;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGMessageModel : NSObject

/*!
 是否显示时间
 */
@property(nonatomic, assign) BOOL isDisplayMessageTime;

/*!
 用户信息
 */
@property(nonatomic, strong) CTMSGUserInfo *userInfo;

/*!
 会话类型
 */
@property(nonatomic, assign) CTMSGConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 消息ID
 */
@property(nonatomic, assign) long messageId;

/*!
 消息方向
 */
@property(nonatomic, assign) CTMSGMessageDirection messageDirection;

/*!
 发送者的用户ID
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
 消息展示时的Cell高度
 
 @discussion 用于大量消息的显示优化
 */
@property(nonatomic) CGSize cellSize;
/*!
 全局唯一ID
 
 @discussion 服务器消息唯一ID（在同一个Appkey下全局唯一）
 */
@property(nonatomic, strong) NSString *messageUId;


/*!
 初始化消息Cell的数据模型
 
 @param message   消息实体
 @return            消息Cell的数据模型对象
 */
+ (instancetype)modelWithMessage:(CTMSGMessage *)message;

/*!
 初始化消息Cell的数据模型
 
 @param message   消息实体
 @return            消息Cell的数据模型对象
 */
- (instancetype)initWithMessage:(CTMSGMessage *)message;

#pragma mark - NS_UNAVAILBLE

/*!
 是否显示用户名
 */
@property(nonatomic, assign) BOOL isDisplayNickname NS_UNAVAILABLE;

///*!
// 阅读回执状态
// */
//@property(nonatomic, strong) RCReadReceiptInfo *readReceiptInfo NS_UNAVAILABLE;

/*!
 消息是否可以发送请求回执
 
 */
@property(nonatomic, assign) BOOL isCanSendReadReceipt NS_UNAVAILABLE;

/*!
 已读人数
 
 */
@property(nonatomic, assign) NSInteger readReceiptCount NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
