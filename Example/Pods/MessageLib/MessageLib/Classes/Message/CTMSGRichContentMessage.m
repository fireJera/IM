//
//  CTMSGRichContentMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGRichContentMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"

NSString * const CTMSGRichContentMessageTypeIdentifier =  @"CTMSG:RchCTTMsg";

@implementation CTMSGRichContentMessage

+ (instancetype)messageWithTitle:(NSString *)title digest:(NSString *)digest imageURL:(NSString *)imageURL extra:(NSString *)extra {
    return [self messageWithTitle:title digest:digest imageURL:imageURL url:nil extra:extra];
}

+ (instancetype)messageWithTitle:(NSString *)title digest:(NSString *)digest imageURL:(NSString *)imageURL url:(NSString *)url extra:(NSString *)extra {
    CTMSGRichContentMessage * message = [[CTMSGRichContentMessage alloc] init];
    if (title) {
        message.title = title;
    }
    if (digest) {
        message.digest = digest;
    }
    if (imageURL) {
        message.imageURL = imageURL;
    }
    if (url) {
        message.url = url;
    }
    if (extra) {
        message.extra = extra;
    }
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

#pragma mark - CTMSGMessageCoding

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.title) {
        [dataDict setObject:self.title forKey:@"title"];
    }
    if (self.digest) {
        [dataDict setObject:self.digest forKey:@"digest"];
    }
    if (self.url) {
        [dataDict setObject:self.title forKey:@"url"];
    }
    if (self.title) {
        [dataDict setObject:self.title forKey:@"title"];
    }
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    if (self.senderUserInfo) {
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [userInfoDic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [userInfoDic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"portrait"];
        }
        if (self.senderUserInfo.userId) {
            [userInfoDic setObject:self.senderUserInfo.userId forKeyedSubscript:@"userid"];
        }
        [dataDict setObject:userInfoDic forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            self.title = dictionary[@"title"];
            self.digest = dictionary[@"digest"];
            self.url = dictionary[@"url"];
            self.imageURL = dictionary[@"imageURL"];
            self.extra = dictionary[@"extra"];
            //            NSDictionary *userinfoDic = dictionary[@"user"];
            //            [self decodeUserInfo:userinfoDic];
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGRichContentMessageTypeIdentifier;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

#pragma mark - CTMSGMessagePersistentCompatible

+ (CTMSGMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED;
}

#pragma mark - CTMSGMessageContentView

- (NSString *)conversationDigest {
    return self.title;
}
@end
