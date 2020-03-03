//
//  CTMSGLocationMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGLocationMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"
#import "UIImage+CTMSG_String.h"
#import "NSString+CTMSG_Temp.h"

NSString * const CTMSGLocationMessageTypeIdentifier =  @"CTMSG:LBSMsg";

@implementation CTMSGLocationMessage

+ (instancetype)messageWithLocationImage:(UIImage *)image
                                location:(CLLocationCoordinate2D)location
                            locationName:(NSString *)locationName {
    CTMSGLocationMessage * message = [[CTMSGLocationMessage alloc] init];
    if (image) {
        message.thumbnailImage = image;
    }
    if (CLLocationCoordinate2DIsValid(location)) {
        message.location = location;
    }
    if (locationName) {
        message.locationName = locationName;
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
    if (self.thumbnailImage) {
        [dataDict setObject:[self.thumbnailImage ctmsg_imageBase64String] forKey:@"content"];
    }
    if (CLLocationCoordinate2DIsValid(self.location)) {
        CLLocationCoordinate2D temp = self.location;
        NSValue * value = [NSValue valueWithBytes:&temp objCType:@encode(CLLocationCoordinate2D)];
        [dataDict setObject:value forKey:@"location"];
    }
    if (self.locationName) {
        [dataDict setObject:self.locationName forKey:@"locationName"];
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
            NSString * imageStr = dictionary[@"content"];
            self.thumbnailImage = [imageStr ctmsg_convertToUIImage];
            NSValue * value = dictionary[@"location"];
            CLLocationCoordinate2D location;
            [value getValue:&location];
            self.location = location;
            self.extra = dictionary[@"extra"];
            //            NSDictionary *userinfoDic = dictionary[@"user"];
            //            [self decodeUserInfo:userinfoDic];
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGLocationMessageTypeIdentifier;
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
    return @"[定位]";
}
@end
