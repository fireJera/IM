//
//  CTMSGUnknownMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

NS_ASSUME_NONNULL_BEGIN
/*!
 未知消息的类型名
 */

extern NSString * const CTMSGUnknownMessageTypeIdentifier;

/*!
 未知消息类
 
 @discussion 所有未注册的消息类型，在MessageKit中都会作为此类消息处理和显示。
 */

@interface CTMSGUnknownMessage : CTMSGMessageContent <NSCoding>



@end

NS_ASSUME_NONNULL_END
