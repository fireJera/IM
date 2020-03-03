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
#import "NSString+CTMSG_Temp.h"
#import "NSData+CTMSG_Base64.h"

NSString * const CTMSGImageMessageTypeIdentifier =  @"CTMSG:ImgMsg";
NSString * const CTMSGImageMessageNetTypeIdentifier = @"img";

@implementation CTMSGImageMessage

+ (instancetype)messageWithImage:(UIImage *)image imageURI:(nonnull NSString *)imageURI {
    if (!image) return nil;
    CTMSGImageMessage * message = [[CTMSGImageMessage alloc] init];
    if (image) {
        message.originalImage = image;
        message.thumbnailImage = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.2)];
    }
    if (imageURI) {
        message.localPath = imageURI;
    }
    return message;
}

+ (instancetype)messageWithImageURI:(NSString *)imageURI {
    if (!imageURI) return nil;
    NSData * data = [NSData dataWithContentsOfFile:imageURI];
    UIImage * image = [UIImage imageWithData:data];
    return [self messageWithImage:image imageURI:imageURI];
}

//+ (instancetype)messageWithImageData:(NSData *)imageData {
//    if (!imageData) return nil;
//    return [self messageWithImage:[UIImage imageWithData:imageData]];
//}

+ (instancetype)messageWithImageURL:(NSString *)imageURL
                           thumbURL:(NSString *)thumbURL
                              width:(CGFloat)width
                             height:(CGFloat)height {
    CTMSGImageMessage * message = [[CTMSGImageMessage alloc] init];
    message.imageURL = imageURL;
    message.thumbnailURL = thumbURL;
    message.imageSize = CGSizeMake(width, height);
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
    if (self.imageURL) {
        [dataDict setObject:self.imageURL forKey:@"imageUrl"];
    }
    if (self.thumbnailURL) {
        [dataDict setObject:self.thumbnailURL forKey:@"thumbnailURL"];
    }
    if (self.localPath) {
        NSString * parent = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString * relativePath = [self.localPath substringWithRange:NSMakeRange(parent.length + 1, self.localPath.length - parent.length - 1)];
        if (relativePath) {
            [dataDict setObject:relativePath forKey:@"localPath"];
        }
    }
    if (!CGSizeEqualToSize(CGSizeZero, self.imageSize)) {
        [dataDict setValue:@(self.imageSize.height) forKey:@"imgHeight"];
        [dataDict setValue:@(self.imageSize.width) forKey:@"imgWidth"];
    }
//    if (self.thumbnailImage) {
//        NSData * data = UIImageJPEGRepresentation(_thumbnailImage, 1);
////        NSString * imageStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//        NSString * imageStr = [data ctmsg_base64String];
////        NSString *imageStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////        imageStr = [imageStr base64String];
//        [dataDict setObject:imageStr forKey:@"thumb"];
//    }
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
            //from net
            NSString * imageURL = dictionary[@"imgBigUrl"];
            if (!imageURL) {
                //from local db
                imageURL = dictionary[@"imageUrl"];
            }
            self.imageURL = imageURL;
            NSString * thumbnailURL = dictionary[@"imgUrl"];
            if (!thumbnailURL) {
                thumbnailURL = dictionary[@"thumbnailURL"];
            }
            self.thumbnailURL = thumbnailURL;
            CGFloat height = [dictionary[@"imgHeight"] floatValue];
            CGFloat width = [dictionary[@"imgWidth"] floatValue];
            self.imageSize = CGSizeMake(width, height);
            
            NSString * localPath = dictionary[@"localPath"];
            if (localPath) {
                NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                localPath = [directory stringByAppendingPathComponent:localPath];
                self.localPath = localPath;
                if ([[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
                    NSData * data = [NSData dataWithContentsOfFile:self.localPath];
                    self.originalImage = [UIImage imageWithData:data];
                    NSData * thumbData = UIImageJPEGRepresentation(self.originalImage, 0.1);
                    self.thumbnailImage = [UIImage imageWithData:thumbData];
                }
            }
            NSString * imageStr = dictionary[@"thumb"];
            if (imageStr) {
                NSData * data = [[NSData alloc] initWithBase64EncodedString:imageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                self.thumbnailImage = [UIImage imageWithData:data];
            }
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
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
