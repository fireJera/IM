//
//  CTMSGConversation.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageLib/CTMSGEnumDefine.h>

@class CTMSGConversation, CTMSGMessage, CTMSGMessageContent;
NS_ASSUME_NONNULL_BEGIN

/*!
 会话Cell数据模型的显示类型
 */
typedef NS_ENUM(NSUInteger, CTMSGConversationModelType) {
    /*!
     默认显示
     */
    CTMSG_CONVERSATION_MODEL_TYPE_NORMAL = 1,
    /*!
     聚合显示
     */
    CTMSG_CONVERSATION_MODEL_TYPE_COLLECTION = 2,
    /*!
     用户自定义的会话显示
     */
    CTMSG_CONVERSATION_MODEL_TYPE_CUSTOMIZATION = 3,
    /*!
     公众服务的会话显示
     */
    CTMSG_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE = 4
};

@interface CTMSGConversationModel : NSObject

/*!
 会话Cell数据模型的显示类型
 */
@property(nonatomic, assign) CTMSGConversationModelType conversationModelType;

/*!
 用户自定义的扩展数据
 */
@property(nonatomic, strong) id extend;

/*!
 会话类型
 */
@property(nonatomic, assign) CTMSGConversationType conversationType;

/*!
 目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 会话的标题
 */
@property(nonatomic, copy) NSString *conversationTitle;

/*!
 会话中的未读消息数
 */
@property(nonatomic, assign) NSInteger unreadMessageCount;

/*!
当前会话是否被锁
*/
@property(nonatomic, assign) BOOL isLock;
/*!
 当前会话是否置顶
 */
@property(nonatomic, assign) BOOL isTop;

/*!
 置顶Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *topCellBackgroundColor;

/*!
 非置顶的Cell的背景颜色
 */
@property(nonatomic, strong) UIColor *cellBackgroundColor;

/*!
 会话中最后一条消息的接收状态
 */
@property(nonatomic, assign) CTMSGReceivedStatus receivedStatus;

/*!
 会话中最后一条消息的发送状态
 */
@property(nonatomic, assign) CTMSGSentStatus sentStatus;

/*!
 会话中最后一条消息的接收时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long receivedTime;

/*!
 会话中最后一条消息的发送时间（Unix时间戳、毫秒）
 */
@property(nonatomic, assign) long long sentTime;

/*!
 会话中最后一条消息的类型名
 */
@property(nonatomic, strong) NSString *objectName;

/*!
 会话中最后一条消息的发送者用户ID
 */
@property(nonatomic, strong) NSString *senderUserId;

/*!
 会话中最后一条消息的消息ID
 */
@property(nonatomic, assign) long lastestMessageId;

/*!
 会话中最后一条消息的内容
 */
@property(nonatomic, strong) CTMSGMessageContent *lastestMessage;

/*!
 会话中最后一条消息的方向
 */
@property(nonatomic, assign) CTMSGMessageDirection lastestMessageDirection;

/*!
 会话中最后一条消息的json Dictionary
 */
@property(nonatomic, strong) NSDictionary *jsonDict;

/*!
 初始化会话显示数据模型
 
 @param conversation          会话
 @param extend                用户自定义的扩展数据
 @return 会话Cell的数据模型对象
 */
- (instancetype)initWithConversation:(CTMSGConversation *)conversation extend:(_Nullable id)extend;

/*!
 更新数据模型中的消息
 
 @param message 此会话中最新的消息
 */
- (void)updateWithMessage:(CTMSGMessage *)message;

#pragma mark - NS_UNAVAILABLE

/*!
 会话中有被提及的消息（有@你的消息）
 */
@property(nonatomic, assign) BOOL hasUnreadMentioned NS_UNAVAILABLE;

/*!
 会话和数据模型是否匹配
 
 @param conversationType 会话类型
 @param targetId         目标会话ID
 @return 会话和数据模型是否匹配
 */
- (BOOL)isMatching:(CTMSGConversationType)conversationType targetId:(NSString *)targetId NS_UNAVAILABLE;

/*!
 会话中最后一条消息的类型名
 */
@property(nonatomic, strong) NSString *showTime;

@end

NS_ASSUME_NONNULL_END
