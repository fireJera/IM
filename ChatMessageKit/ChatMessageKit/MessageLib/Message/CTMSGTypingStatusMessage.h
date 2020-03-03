//
//  CTMSGTypingStatusMessage.j
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const CTMSGTypeStatusMessageTypeIdentifier;

@interface CTMSGTypingStatusMessage : CTMSGMessageContent

@property (nonatomic, copy) NSString * data;

/**
 输入类型，传消息的objectName ，比如正在输入文字，传"CTMSG:TxtMsg"
 */
@property (nonatomic, copy) NSString * typingContentType;

+ (instancetype)messageWithType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
