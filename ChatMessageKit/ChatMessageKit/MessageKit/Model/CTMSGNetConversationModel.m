//
//  CTMSGNetConversationModel.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGNetConversationModel.h"
#import "CTMSGConversationModel.h"

@implementation CTMSGNetConversationModel

+ (NSDictionary *) modelCustomPropertyMapper {
    return @{
             @"targetId"    : @"toUserid",
             @"msgType"     : @"type",
             @"avatar"      : @"HeadPic",
             };
}

- (id)copy {
    CTMSGConversationModel * model = [[CTMSGConversationModel alloc] init];
    model.targetId = _targetId;
    model.conversationType = ConversationType_PRIVATE;
    model.conversationTitle = _content;
    model.unreadMessageCount = _unread;
//    model.sentTime = _time;
    model.isTop = _isVip;
    model.isLock = _isLock;
//    model.objectName = _msgType;
    //    model.objectName = _nickname;
    //    model.objectName = _avatar;
    return model;
}

@end
