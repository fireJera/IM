
//
//  CTMSGConversation.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGConversationModel.h"
#import "CTMSGConversation.h"
#import "CTMSGMessage.h"
#import "CTMSGMessageContent.h"

@implementation CTMSGConversationModel

- (instancetype)initWithConversation:(CTMSGConversation *)conversation extend:(id)extend {
    self = [super init];
    if (!self) return nil;
//    _conversationModelType = conversation.co
    _conversationType = conversation.conversationType;
    _targetId = conversation.targetId;
    _conversationTitle = conversation.conversationTitle;
    _unreadMessageCount = conversation.unreadMessageCount;
    _isTop = conversation.isTop;
//    _topCellBackgroundColor = conversation.t
//    _cellBackgroundColor = conversation.ce
    _receivedStatus = conversation.receivedStatus;
    _sentStatus = conversation.sentStatus;
    _receivedTime = conversation.receivedTime;
    _sentTime = conversation.sentTime;
    _objectName = conversation.objectName;
    _senderUserId = conversation.senderUserId;
    _lastestMessageId = conversation.lastestMessageId;
    _lastestMessage = conversation.lastestMessage;
    _lastestMessageDirection = conversation.lastestMessageDirection;
    _jsonDict = conversation.jsonDict;
    _extend = extend;
    return self;
}

- (void)updateWithMessage:(CTMSGMessage *)message {
    _conversationType = message.conversationType;
    _targetId = message.targetId;
    if (message.receivedStatus == ReceivedStatus_UNREAD) {
        _unreadMessageCount += 1;
    }
    _receivedStatus = message.receivedStatus;
    _sentStatus = message.sentStatus;
    _receivedTime = message.receivedTime;
    _sentTime = message.sentTime;
    _objectName = message.objectName;
    _senderUserId = message.senderUserId;
    _lastestMessageId = message.messageId;
    _lastestMessage = message.content;
    _lastestMessageDirection = message.messageDirection;
//    _jsonDict = message.;
}

@end
