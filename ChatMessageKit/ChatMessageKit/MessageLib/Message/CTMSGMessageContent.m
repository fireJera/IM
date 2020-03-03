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
    CTMSGUserInfo * user = [[CTMSGUserInfo alloc] initWithUserId:dictionary[@"userid"]
                                                            name:dictionary[@"name"]
                                                        portrait:dictionary[@"portrait"]
                                                           isVip:NO];
    self.senderUserInfo = user;
}

#pragma mark - CTMSGMessageCoding

- (NSData *)encode {
    return nil;
}

- (void)decodeWithData:(NSData *)data {
    
}

+ (NSString *)getObjectName {
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
