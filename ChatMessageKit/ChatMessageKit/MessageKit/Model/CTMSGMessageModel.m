//
//  CTMSGMessageModel.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageModel.h"
#import "CTMSGMessage.h"
#import "CTMSGMessageModel.h"
#import "CTMSGMessageContent.h"

@implementation CTMSGMessageModel

+ (instancetype)modelWithMessage:(CTMSGMessage *)message {
    return [[self alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(CTMSGMessage *)message {
    self = [super init];
    if (!self) return nil;
    _content = message.content;
    _conversationType = message.conversationType;
    _targetId = message.targetId;
    _messageId = message.messageId;
    _messageDirection = message.messageDirection;
    _senderUserId = message.senderUserId;
    _receivedStatus = message.receivedStatus;
    _sentStatus = message.sentStatus;
    _receivedTime = message.receivedTime;
    _objectName = message.objectName;
    if (!_objectName) {
        _objectName = [[message.content class] getObjectName];
    }
    _extra = message.extra;
    _messageUId = message.messageUId;
    _userInfo = message.content.senderUserInfo;
    return self;
}

@end
