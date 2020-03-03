//
//  CTMSGCommandMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

//#define CTMSGCommandMessageTypeIdentifier @"CTMSG:CmdMsg"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CTMSGCommandMessageTypeIdentifier;
/*!
 命令消息类
 
 @discussion 命令消息类，此消息不存储不计入未读消息数。
 与RCCommandNotificationMessage的区别是，此消息不存储，也不会在界面上显示。
 */
@interface CTMSGCommandMessage : CTMSGMessageContent <NSCoding>

@property(nonatomic, strong) NSString *module;
/*!
 命令的名称
 */
@property(nonatomic, strong) NSString *name;

/*!
 命令的扩展数据
 
 @discussion 命令的扩展数据，可以为任意字符串，如存放您定义的json数据。
 */
@property(nonatomic, strong) NSDictionary *data;

/*!
 初始化命令消息
 
 @param name    命令的名称
 @param data    命令的扩展数据
 @return        命令消息对象
 */
+ (instancetype)messageWithName:(NSString *)name data:(NSDictionary *)data module:(NSString *)module;

@end

NS_ASSUME_NONNULL_END
