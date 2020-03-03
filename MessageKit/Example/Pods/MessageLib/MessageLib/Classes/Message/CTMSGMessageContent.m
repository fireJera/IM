//
//  CTMSGMessageContent.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"
#import "CTMSGUserInfo.h"

@implementation CTMSGMessageContent

- (void)decodeUserInfo:(NSDictionary *)dictionary {
    if (!dictionary) return;
    CTMSGUserInfo * user = [[CTMSGUserInfo alloc] initWithUserId:dictionary[@"userid"]
                                                            name:dictionary[@"name"]
                                                        portrait:dictionary[@"portrait"]
                                                           isVip:[dictionary[@"isVip"] intValue]];
    self.senderUserInfo = user;
}

#pragma mark - CTMSGMessageCoding

- (NSData *)encode {
    return nil;
}

- (NSDictionary *)netSendParameters {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    
}

+ (NSString *)getObjectName {
    return nil;
}

+ (NSString *)getNetObjectName {
    return nil;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

#pragma mark - CTMSGMessagePersistentCompatible

+ (CTMSGMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

#pragma mark - CTMSGMessageContentView

- (NSString *)conversationDigest {
    return nil;
}

@end
