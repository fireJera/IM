//
//  CTMSGTextMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGTextMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"

NSString * const CTMSGTextMessageTypeIdentifier = @"CTMSG:TxtMsg";
NSString * const CTMSGTextMessageNetTypeIdentifier = @"txt";

@implementation CTMSGTextMessage

+ (instancetype)messageWithContent:(NSString *)content {
    CTMSGTextMessage * message = [[CTMSGTextMessage alloc] init];
    if (content) {
        message.content = content;
    }
    return message;
}

#pragma mark - NSCoding
///// NSCoding
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super init];
//    if (self) {
//        self.content = [aDecoder decodeObjectForKey:@"content"];
//        self.extra = [aDecoder decodeObjectForKey:@"extra"];
//    }
//    return self;
//}
//
///// NSCoding
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.content forKey:@"content"];
//    [aCoder encodeObject:self.extra forKey:@"extra"];
//}

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
    if (self.content) {
        [dataDict setObject:self.content forKey:@"content"];
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

- (NSDictionary *)netSendParameters {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.content) {
        [dataDict setObject:self.content forKey:@"content"];
        if (self.extraPara) {
            [dataDict setValuesForKeysWithDictionary:self.extraPara];
        }
    }
    return dataDict;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            NSString * content = dictionary[@"txt"];
            if (!content) {
                content = dictionary[@"content"];
            }
            self.content = content;
            self.extra = dictionary[@"extra"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            if (userinfoDic && userinfoDic.allKeys.count > 0) {
                [self decodeUserInfo:userinfoDic];
            }
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGTextMessageTypeIdentifier;
}

+ (NSString *)getNetObjectName {
    return CTMSGTextMessageNetTypeIdentifier;
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
    return self.content;
}

@end
