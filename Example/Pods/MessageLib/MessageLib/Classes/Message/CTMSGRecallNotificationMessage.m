//
//  CTMSGRecallNotificationMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGRecallNotificationMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"

NSString * const CTMSGRecallNotificationMessageIdentifier =  @"CTMSG:RcNtf";

@implementation CTMSGRecallNotificationMessage

+ (instancetype)messageWithUserid:(NSString *)selfUid time:(long long)recallTime messageName:(NSString *)messageName {
    CTMSGRecallNotificationMessage * message = [[CTMSGRecallNotificationMessage alloc] init];
    if (selfUid) {
        message.operatorId = selfUid;
    }
    if (recallTime) {
        message.recallTime = recallTime;
    }
    if (messageName) {
        message.originalObjectName = messageName;
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
    if (self.operatorId) {
        [dataDict setObject:self.operatorId forKey:@"operatorId"];
    }
    if (self.recallTime) {
        [dataDict setObject:[NSNumber numberWithLongLong:self.recallTime] forKey:@"recallTime"];
    }
    if (self.originalObjectName) {
        [dataDict setObject:self.originalObjectName forKey:@"originalObjectName"];
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
            self.operatorId = dictionary[@"operatorId"];
            self.recallTime = [dictionary[@"recallTime"] recallTime];
            self.originalObjectName = dictionary[@"originalObjectName"];
            //            NSDictionary *userinfoDic = dictionary[@"user"];
            //            [self decodeUserInfo:userinfoDic];
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGRecallNotificationMessageIdentifier;
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
    return @"[对方撤回了一条消息]";
}

@end
