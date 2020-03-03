//
//  CTMSGImageMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGImageMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"
#import "NSString+CTMSG_Str.h"
#import "NSData+CTMSG_Data.h"

NSString * const CTMSGImageMessageTypeIdentifier =  @"CTMSG:ImgMsg";

@implementation CTMSGImageMessage

+ (instancetype)messageWithImage:(UIImage *)image {
    if (!image) return nil;
    CTMSGImageMessage * message = [[CTMSGImageMessage alloc] init];
    if (image) {
        message.originalImage = image;
        message.thumbnailImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.2)];
    }
    return message;
}

//TODO: - get image from local path 
+ (instancetype)messageWithImageURI:(NSString *)imageURI {
    if (!imageURI) return nil;
    NSData * data = [NSData dataWithContentsOfFile:imageURI];
    UIImage * image = [UIImage imageWithData:data];
    return [self messageWithImage:image];
}

+ (instancetype)messageWithImageData:(NSData *)imageData {
    if (!imageData) return nil;
    return [self messageWithImage:[UIImage imageWithData:imageData]];
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
    if (self.imageUrl) {
        [dataDict setObject:self.imageUrl forKey:@"imageUrl"];
    }
    if (self.thumbnailImage) {
        NSData * data = UIImageJPEGRepresentation(_thumbnailImage, 1);
//        NSString * imageStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString * imageStr = [data base64String];
//        NSString *imageStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        imageStr = [imageStr base64String];
        [dataDict setObject:imageStr forKey:@"thumb"];
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
            self.imageUrl = dictionary[@"imageUrl"];
            NSString * imageStr = dictionary[@"thumb"];
            NSData * data = [[NSData alloc] initWithBase64EncodedString:imageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            self.thumbnailImage = [UIImage imageWithData:data];
            //            NSDictionary *userinfoDic = dictionary[@"user"];
            //            [self decodeUserInfo:userinfoDic];
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGImageMessageTypeIdentifier;
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
    return @"[图片]";
}

#pragma mark - getter

- (NSData *)originalImageData {
    return UIImagePNGRepresentation(_originalImage);
}

@end
