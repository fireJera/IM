//
//  CTMSGVideoMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGVideoMessage.h"
#import <objc/runtime.h>
#import "CTMSGUserInfo.h"
//#import <CodeFrame/CodeFrame.h>
#import "NSData+CTMSG_Base64.h"
#import "UIImage+CTMSG_Cat.h"

NSString * const CTMSGVideoMessageTypeIdentifier =  @"CTMSG:VideoMsg";
NSString * const CTMSGVideoMessageNetTypeIdentifier = @"video";

@implementation CTMSGVideoMessage

+ (instancetype)messageWithLocalPath:(NSString *)localPath image:(UIImage *)thumbnailImage {
    CTMSGVideoMessage * message = [[CTMSGVideoMessage alloc] init];
    if (localPath) {
        message.localaPath = localPath;
    }
    if (thumbnailImage) {
        message.thumbnailImage = thumbnailImage;
    }
    return message;
}

+ (instancetype)messageWithCoverURL:(NSString *)coverURL
                           videoURL:(NSString *)videoURL
                         videoWidth:(CGFloat)videoWidth
                        videoHeight:(CGFloat)videoHeight {
    CTMSGVideoMessage * message = [[CTMSGVideoMessage alloc] init];
    if (coverURL) {
        message.thumbnailURL = coverURL;
    }
    if (videoURL) {
        message.videoURL = videoURL;
    }
    message.imageSize = CGSizeMake(videoWidth, videoHeight);
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
    if (self.localaPath) {
        NSString * parent = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString * relativePath = [self.localaPath substringWithRange:NSMakeRange(parent.length + 1, self.localaPath.length - parent.length - 1)];
        if (relativePath) {
            [dataDict setObject:relativePath forKey:@"localaPath"];
        }
    }
    if (self.videoURL) {
        [dataDict setObject:self.videoURL forKey:@"videoUrl"];
    }
    if (self.thumbnailURL) {
        [dataDict setObject:self.thumbnailURL forKey:@"videoCoverUrl"];
    }
//    if (self.thumbnailImage) {
//        NSData * data = UIImageJPEGRepresentation(_thumbnailImage, 1);
//        NSString * imageStr = [data ctmsg_base64String];
//        [dataDict setObject:imageStr forKey:@"thumb"];
//    }
    if (!CGSizeEqualToSize(CGSizeZero, self.imageSize)) {
        [dataDict setValue:@(self.imageSize.width) forKey:@"videoWidth"];
        [dataDict setValue:@(self.imageSize.height) forKey:@"videoHeight"];
    }
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
//    if (self.senderUserInfo) {
//        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
//        if (self.senderUserInfo.name) {
//            [userInfoDic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
//        }
//        if (self.senderUserInfo.portraitUri) {
//            [userInfoDic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"portrait"];
//        }
//        if (self.senderUserInfo.userId) {
//            [userInfoDic setObject:self.senderUserInfo.userId forKeyedSubscript:@"userid"];
//        }
//        [dataDict setObject:userInfoDic forKey:@"user"];
//    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dictionary) {
            NSString * videoURL = dictionary[@"videoUrl"];
            self.videoURL = videoURL;
            NSString * localPath = dictionary[@"localaPath"];
            if (localPath) {
                NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                localPath = [directory stringByAppendingPathComponent:localPath];
                self.localaPath = localPath;
            }
            
            NSString * imageURL = dictionary[@"videoCoverUrl"];
            self.thumbnailURL = imageURL;
            NSString * thumbnail = dictionary[@"thumb"];
            CGFloat height = [dictionary[@"videoHeight"] floatValue];
            CGFloat width = [dictionary[@"videoWidth"] floatValue];
            self.imageSize = CGSizeMake(width, height);
            if (thumbnail) {
                NSData * data = [[NSData alloc] initWithBase64EncodedString:thumbnail options:NSDataBase64DecodingIgnoreUnknownCharacters];
                self.thumbnailImage = [UIImage imageWithData:data];
            } else {
                self.thumbnailImage = [UIImage ctmsg_imageInLocalPath:self.localaPath];
            }
            self.extra = dictionary[@"extra"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}

+ (NSString *)getObjectName {
    return CTMSGVideoMessageTypeIdentifier;
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
    return @"[视频]";
}
@end
