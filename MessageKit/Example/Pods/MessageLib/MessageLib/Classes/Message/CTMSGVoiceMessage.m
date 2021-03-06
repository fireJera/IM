//
//  CTMSGVoiceMessage.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGVoiceMessage.h"

#import <objc/runtime.h>
#import "CTMSGUserInfo.h"
#import "NSData+CTMSG_Base64.h"

NSString * const CTMSGVoiceMessageTypeIdentifier =  @"CTMSG:VICMsg";
NSString * const CTMSGVoiceMessageNetTypeIdentifier = @"voice";

@implementation CTMSGVoiceMessage

+ (instancetype)messageWithAudio:(NSData *)audioData duration:(long)duration localURL:(nonnull NSString *)localURL {
    NSParameterAssert(audioData && duration);
    CTMSGVoiceMessage * message = [[CTMSGVoiceMessage alloc] init];
    if (audioData) {
        message.wavAudioData = audioData;
    }
    if (duration) {
        message.duration = duration;
    }
    if (localURL) {
        message.localURL = localURL;
    }
    return message;
}

+ (instancetype)messageWithAudioURL:(NSString *)audioURL duration:(long)duration {
//    NSParameterAssert(audioURL && duration);
    CTMSGVoiceMessage * message = [[CTMSGVoiceMessage alloc] init];
    if (audioURL) {
        message.wavURL = audioURL;
    }
    if (duration) {
        message.duration = duration;
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
//    if (self.wavAudioData) {
////        NSString * str = [[NSString alloc] initWithData:_wavAudioData encoding:NSUTF8StringEncoding];
//        NSString * base64 = [_wavAudioData ctmsg_base64String];
////        NSString * base64 = [self.wavAudioData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        if (base64) {
//            [dataDict setObject:base64 forKey:@"content"];
//        }
//    }
    if (self.duration) {
        [dataDict setObject:[NSNumber numberWithLong:self.duration] forKey:@"voiceDuration"];
    }
    if (self.wavURL) {
        [dataDict setObject:self.wavURL forKey:@"voiceURL"];
    }
    if (self.localURL) {
        NSString * parent = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString * relativePath = [self.localURL substringWithRange:NSMakeRange(parent.length + 1, self.localURL.length - parent.length - 1)];
        if (relativePath) {
            [dataDict setObject:relativePath forKey:@"localURL"];
        }
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
//            NSString * base64 = dictionary[@"content"];
//            if (base64) {
//                self.wavAudioData = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
//            }
            self.wavURL = dictionary[@"voiceURL"];
            if (!_wavURL) {
                _wavURL = dictionary[@"voiceUrl"];
            }
            NSString * localPath = dictionary[@"localURL"];
            if (localPath) {
                NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//                NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
//                parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
                localPath = [directory stringByAppendingPathComponent:localPath];
                self.localURL = localPath;
            }
//            self.localURL = dictionary[@"localURL"];
            self.duration = [dictionary[@"voiceDuration"] longValue];
            self.extra = dictionary[@"extra"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}

//- (NSDictionary *)netSendParameters {
//    
//}

+ (NSString *)getObjectName {
    return CTMSGVoiceMessageTypeIdentifier;
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
    return @"[语音]";
}
@end
