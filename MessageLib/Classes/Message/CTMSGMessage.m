//
//  CTMSGMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessage.h"
#import <objc/runtime.h>
#import "CTMSGMessageContent.h"

@implementation CTMSGMessage

- (instancetype)initWithType:(CTMSGConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(CTMSGMessageDirection)messageDirection
                   messageId:(long)messageId
                     content:(CTMSGMessageContent *)content {
    self = [super init];
    if (!self) return nil;
    _conversationType = conversationType;
    _targetId = targetId;
    _messageDirection = messageDirection;
    _messageId = messageId;
    _content = content;
    _objectName = [[_content class] getObjectName];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CTMSGMessage * message = [[CTMSGMessage alloc] init];
    message.conversationType = self.conversationType;
    message.targetId = self.targetId;
    message.messageId = self.messageId;
    message.messageDirection = self.messageDirection;
    message.senderUserId = self.senderUserId;
    message.receivedStatus = self.receivedStatus;
    message.sentStatus = self.sentStatus;
    message.receivedTime = self.receivedTime;
    message.sentTime = self.sentTime;
    message.objectName = self.objectName;
    message.content = self.content;
    message.extra = self.extra;
    message.messageUId = self.messageUId;
    return message;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count = 0;
    Ivar * vars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        const char* name = ivar_getName(var);
        NSString * key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar * vars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar var = vars[i];
            const char* name = ivar_getName(var);
            NSString * key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (NSString *)objectName {
    if (_objectName) {
        return _objectName;
    }
    Class cls = [self.content class];
    NSString * str;
    if ([cls respondsToSelector:@selector(getObjectName)]) {
        str = [cls getObjectName];
    }
    return str;
}

@end
