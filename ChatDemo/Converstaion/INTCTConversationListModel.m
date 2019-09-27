//
//  INTCTConversationModel.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTConversationListModel.h"
#import <MMessageKit/MMessageKit.h>

@implementation INTCTChatListModel

+ (NSDictionary *) modelCustomPropertyMapper {
    return @{
             @"targetId"    : @"toUserid",
             @"msgType"     : @"type",
             @"avatar"      : @"HeadPic",
             };
}

- (id)copy {
    CTMSGMessageContent * content;
    if ([_msgType isEqualToString:CTMSGTextMessageNetTypeIdentifier]) {
        content = [CTMSGTextMessage messageWithContent:_content];
    }
    else if ([_msgType isEqualToString:CTMSGVoiceMessageNetTypeIdentifier]) {
        content = [CTMSGVoiceMessage new];
    }
    else if ([_msgType isEqualToString:CTMSGImageMessageNetTypeIdentifier]) {
        content = [CTMSGImageMessage new];
    }
    else if ([_msgType isEqualToString:CTMSGVideoMessageNetTypeIdentifier]) {
        content = [CTMSGVideoMessage new];
    } else if ([_msgType isEqualToString:@"10000"]) {
        content = [CTMSGTextMessage messageWithContent:_content];
    } else {
        content = [CTMSGUnknownMessage messageWithContent:@"未知消息类型"];
        NSLog(@"unkonw message-----");
    }
    CTMSGUserInfo * user = [[CTMSGUserInfo alloc] initWithUserId:_targetId name:_nickname portrait:_avatar isVip:NO];
//    CTMSGUserInfo * user = [[CTMSGUserInfo alloc] initWithUserId:_targetId name:_nickname portrait:_avatar isVip:_isVip];
    content.senderUserInfo = user;
    
    CTMSGConversation * consersation = [[CTMSGConversation alloc] init];
    consersation.targetId = _targetId;
    consersation.conversationType = ConversationType_PRIVATE;
    consersation.conversationTitle = _content;
    consersation.unreadMessageCount = (int)_unread;
//    consersation.isTop = _isVip;
    consersation.isTop = NO;
    consersation.lastestMessage = content;
    return consersation;
}

@end

@implementation INTCTConversationListModel

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{
//             @"targetId"    : @"toUserid",
//             @"msgType"     : @"type",
//             @"avatar"      : @"HeadPic",
//             };
//}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"list": @"INTCTChatListModel"};
}

@end
