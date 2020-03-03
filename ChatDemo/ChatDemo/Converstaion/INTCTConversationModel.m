//
//  INTCTConversationModel.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTConversationModel.h"
#import <MMessageKit/MMessageKit.h>
//#import <MessageLib/CTMSGMessage.h>

@implementation INTCTChatDetailUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"avatar"      : @"headPic",
             @"hasWechat"   : @"hasWeixin",
             @"videoAuth"   : @"isVideoAuth",
             @"isBlack"     : @"isBlackUser",
//             @"isVip"       : @"isVip",
             };
}

@end

@implementation INTCTChatDetailMsg

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"msgTime"     : @"created_at",
             @"msgUid"      : @"msg_id",
             @"sendTime"    : @"time",
             //             @"imgWidth"    : @"videoWidth",
             //             @"imgHeight"   : @"videoHeight",
             @"imgWidth"    : @[@"videoWidth", @"imgWidth"],
             @"imgHeight"   : @[@"videoHeight", @"imgHeight"],
             };
}

- (id)copy {
    CTMSGMessage *message = [CTMSGMessage new];
    message.conversationType = 1;
    message.messageId = 0;
    message.messageUId = _msgUid;
    message.messageDirection = [_sendUserid isEqualToString:_userid] ? CTMSGMessageDirectionSend : CTMSGMessageDirectionReceive;
    message.targetId = message.messageDirection == CTMSGMessageDirectionSend ? _toUserid : _sendUserid;
    message.senderUserId = _sendUserid;
    message.receivedStatus = ReceivedStatus_READ;
    message.sentStatus = SentStatus_SENT;
    message.receivedTime = _sendTime * 1000;
    message.sentTime = _sendTime * 1000;
    CTMSGMessageContent * content;
    if ([_type isEqualToString:CTMSGTextMessageNetTypeIdentifier]) {
        message.objectName = CTMSGTextMessageTypeIdentifier;
        content = [CTMSGTextMessage messageWithContent:_txt];
    }
    else if ([_type isEqualToString:CTMSGVoiceMessageNetTypeIdentifier]) {
        message.objectName = CTMSGVoiceMessageTypeIdentifier;
        content = [CTMSGVoiceMessage messageWithAudioURL:_voiceUrl duration:[_voiceDuration integerValue]];
    }
    else if ([_type isEqualToString:CTMSGImageMessageNetTypeIdentifier]) {
        message.objectName = CTMSGImageMessageTypeIdentifier;
        content = [CTMSGImageMessage messageWithImageURL:_imgBigUrl thumbURL:_imgUrl width:_imgWidth height:_imgHeight];
    }
    else if ([_type isEqualToString:CTMSGVideoMessageNetTypeIdentifier]) {
        message.objectName = CTMSGVideoMessageTypeIdentifier;
        content = [CTMSGVideoMessage messageWithCoverURL:_videoCoverUrl videoURL:_videoUrl videoWidth:_imgWidth videoHeight:_imgHeight];
    }
    else {
        message.objectName = CTMSGUnknownMessageTypeIdentifier;
        content = [CTMSGUnknownMessage messageWithContent:@"当前不支持此消息类型"];
        NSLog(@"unkonw message-----");
    }
    message.content = content;
    return message;
}

@end

@implementation INTCTConversationModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"user"                : @"userInfo",
             @"albums"              : @"userAlbum",
             @"messages"            : @"list",
             @"messageLockNote"     : @"lockMsgTxt",
             @"bottomLockNote"      : @"lockTxt",
             @"lockURL"             : @"lockUrl",
             @"lockParameters"      : @"lockPostData",
             @"videoUnauthNote"     : @"noVideoAuthtips",
             @"quickTexts"          : @"sayTips",
             @"matchNote"           : @"tips",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"user"        : @"INTCTChatDetailUser",
             @"albums"      : @"INTCTAlbum",
             @"messages"    : @"INTCTChatDetailMsg",
             };
}

@end
