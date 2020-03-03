//
//  CTMSGCommadnNotificationMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGCommadnNotificationMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"

NSString * const CTMSGCommandNotificationMessageIdentifier =  @"CTMSG:CmdNtf";

@implementation CTMSGCommadnNotificationMessage

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
    if (self.pageName) {
        [dataDict setObject:self.pageName forKey:@"pageName"];
    }
    if (self.pageData) {
        [dataDict setObject:self.pageData forKey:@"pageData"];
    }
    if (self.showContent) {
        [dataDict setObject:self.showContent forKey:@"content"];
    }
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

///将json解码生成消息内容
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            self.pageName = dictionary[@"pageName"];
            self.pageData = dictionary[@"pageData"];
            self.showContent = dictionary[@"showContent"];
            self.extra = dictionary[@"extra"];
            
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGCommandNotificationMessageIdentifier;
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

#pragma mark - CTMSGMessagePersistentCompatible

+ (CTMSGMessagePersistent)persistentFlag {
    return MessagePersistent_ISPERSISTED;
}

#pragma mark - CTMSGMessageContentView

- (NSString *)conversationDigest {
    return nil;
}

@end
