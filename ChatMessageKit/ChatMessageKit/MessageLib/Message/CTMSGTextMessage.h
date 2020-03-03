//
//  CTMSGTextMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 文本消息的类型名
 */
extern NSString * const CTMSGTextMessageTypeIdentifier;
extern NSString * const CTMSGTextMessageNetTypeIdentifier;

/*!
 文本消息类
 
 @discussion 文本消息类，此消息会进行存储并计入未读消息数。
 */
@interface CTMSGTextMessage : CTMSGMessageContent <NSCoding>

/*!
 文本消息的内容
 */
@property(nonatomic, strong) NSString *content;

/*!
 文本消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化文本消息
 
 @param content 文本消息的内容
 @return        文本消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
