//
//  CTMSGIM.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/11.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGIM.h"
#import "CTMSGIMClient.h"
#import "CTMSGDataBaseManager.h"
#import "CTMSGUserInfo.h"
#import "CTMSGMessage.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CTMSGUtilities.h"

NSString *const CTMSGKitDispatchMessageNotification = @"CTMSGKitDispatchMessageNotification";
NSString *const CTMSGKitDispatchMessageNotificationLeftKey = @"left";
//NSString *const CTMSGKitDispatchMessageNotificationValueKey = @"value";
NSString *const CTMSGKitDispatchRecallMessageNotification = @"CTMSGKitDispatchRecallMessageNotification";
NSString *const CTMSGKitDispatchConnectionStatusChangedNotification = @"CTMSGKitDispatchConnectionStatusChangedNotification";
NSString *const CTMSGKitDispatchMessageReceiptResponseNotification = @"CTMSGKitDispatchMessageReceiptResponseNotification";
NSString *const CTMSGKitDispatchMessageReceiptRequestNotification = @"CTMSGKitDispatchMessageReceiptRequestNotification";

@interface CTMSGIM () <CTMSGIMClientReceiveMessageDelegate, CTMSGConnectionStatusChangeDelegate>

@end

@implementation CTMSGIM

#pragma mark - singleton

+ (instancetype)sharedCTMSGIM {
    static CTMSGIM * _im = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _im = [[super allocWithZone:NULL] init];
        [_im p_ctmsg_Init];
    });
    return _im;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedCTMSGIM];
}

- (id)copy {
    return [[self class] sharedCTMSGIM];
}

- (id)mutableCopy {
    return [[self class] sharedCTMSGIM];
}

- (void)p_ctmsg_Init {
    if ([CTMSGIMClient sharedCTMSGIMClient].receiveMessageDelegate == nil) {
        [CTMSGIMClient sharedCTMSGIMClient].receiveMessageDelegate = self;
    }
    if ([CTMSGIMClient sharedCTMSGIMClient].connectDelegate == nil) {
        [CTMSGIMClient sharedCTMSGIMClient].connectDelegate = self;
    }
    _disableMessageAlertSound = NO;
    _disableMessageNotificaiton = NO;
    _showUnkownMessage = NO;
    _showUnkownMessageNotificaiton = NO;
    _maxVoiceDuration = 60;
    _isExclusiveSoundPlayer = NO;
    _enablePersistentUserInfoCache = YES;
}

#pragma mark - conncet

- (void)connectWithUserId:(NSString *)userId
                 password:(NSString *)password
                  success:(void (^)(NSString * _Nullable string))successBlock
                    error:(void (^)(CTMSGConnectErrorCode status, NSError * _Nullable error))errorBlock
           tokenIncorrect:(void (^)(void))tokenIncorrectBlock {
    [[CTMSGIMClient sharedCTMSGIMClient] connectWithUserId:userId
                                                  password:password
                                                   success:successBlock
                                                     error:errorBlock
                                            tokenIncorrect:tokenIncorrectBlock];
}

- (void)disconnect {
    [[CTMSGIMClient sharedCTMSGIMClient] disconnect];
}

- (void)logout {
    [[CTMSGIMClient sharedCTMSGIMClient] logout];
}

#pragma mark - send message

- (void)registerMessageType:(Class)messageClass {
    [[CTMSGIMClient sharedCTMSGIMClient] registerMessageType:messageClass];
}

- (CTMSGMessage *)sendMessage:(CTMSGConversationType)conversationType
                     targetId:(NSString *)targetId
                      content:(CTMSGMessageContent *)content
                  pushContent:(NSString *)pushContent
                     pushData:(NSString *)pushData
                      success:(void (^)(long))successBlock
                        error:(void (^)(CTMSGErrorCode, long))errorBlock {
    return [[CTMSGIMClient sharedCTMSGIMClient] sendMessage:conversationType
                                                   targetId:targetId
                                                    content:content
                                                pushContent:pushContent
                                                   pushData:pushData
                                                    success:successBlock
                                                      error:errorBlock];
}

- (CTMSGMessage *)sendMediaMessage:(CTMSGConversationType)conversationType
                          targetId:(NSString *)targetId
                           content:(CTMSGMessageContent *)content
                       pushContent:(NSString *)pushContent
                          pushData:(NSString *)pushData
                          progress:(void (^)(int, long))progressBlock
                           success:(void (^)(long))successBlock
                             error:(void (^)(CTMSGErrorCode, long))errorBlock
                            cancel:(void (^)(long))cancelBlock {
    return [[CTMSGIMClient sharedCTMSGIMClient] sendMediaMessage:conversationType
                                                        targetId:targetId
                                                         content:content
                                                     pushContent:pushContent
                                                        pushData:pushData
                                                        progress:progressBlock
                                                         success:successBlock
                                                           error:errorBlock
                                                          cancel:cancelBlock];
}

- (BOOL)cancelSendMediaMessage:(long)messageId {
    return [[CTMSGIMClient sharedCTMSGIMClient] cancelSendMediaMessage:messageId];
}

- (void)downloadMediaMessage:(long)messageId
                    progress:(void (^)(int))progressBlock
                     success:(void (^)(NSString * _Nonnull))successBlock
                       error:(void (^)(CTMSGErrorCode))errorBlock
                      cancel:(void (^)(void))cancelBlock {
    [[CTMSGIMClient sharedCTMSGIMClient] downloadMediaMessage:messageId
                                                     progress:progressBlock
                                                      success:successBlock
                                                        error:errorBlock
                                                       cancel:cancelBlock];
}

- (BOOL)cancelDownloadMediaMessage:(long)messageId {
    return [[CTMSGIMClient sharedCTMSGIMClient] cancelDownloadMediaMessage:messageId];
}

#pragma mark - CTMSGIMClientReceiveMessageDelegate

- (void)onReceived:(CTMSGMessage *)message left:(int)nLeft object:(id)object {
    if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMReceiveMessage:left:)]) {
        [_receiveMessageDelegate onCTMSGIMReceiveMessage:message left:nLeft];
    }
    NSDictionary * dic = @{
                           CTMSGKitDispatchMessageNotificationLeftKey : @(nLeft)
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:CTMSGKitDispatchMessageNotification object:message userInfo:dic];
    
    if ([CTMSGIMClient sharedCTMSGIMClient].sdkRunningMode == CTMSGRunningMode_Foreground) {
        if (_disableMessageAlertSound) {
            BOOL voice = YES;
            if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMCustomAlertSound:)]) {
                voice = [_receiveMessageDelegate onCTMSGIMCustomAlertSound:message];
            }
            if (voice) {
                //TODO: - play alert sound
            }
        }
    } else {
        if (_disableMessageNotificaiton) {
            //TODO: - 获取消息类型 判断是否支持
            if (_showUnkownMessageNotificaiton) {
                
            }
            if ([_userInfoDataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
                [_userInfoDataSource getUserInfoWithUserId:message.targetId completion:^(CTMSGUserInfo * _Nonnull userInfo) {
                    BOOL show = YES;
                    if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMCustomLocalNotification:withSenderName:)]) {
                        show = [_receiveMessageDelegate onCTMSGIMCustomLocalNotification:message withSenderName:userInfo.name];
                    }
                    if (show) {
                        //TODO: - local notification
                    }
                }];
            } else {
                //TODO: - local notification
            }
        }
    }
}

- (void)onMessageRecalled:(long)messageId {
    if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMMessageRecalled:)]) {
        [_receiveMessageDelegate onCTMSGIMMessageRecalled:messageId];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CTMSGKitDispatchRecallMessageNotification object:@(messageId)];
}

#pragma mark - CTMSGConnectionStatusChangeDelegate

- (void)onConnectionStatusChanged:(CTMSGConnectionStatus)status {
    if ([_connectionStatusDelegate respondsToSelector:@selector(onCTMSGIMConnectionStatusChanged:)]) {
        [_connectionStatusDelegate onCTMSGIMConnectionStatusChanged:status];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CTMSGKitDispatchConnectionStatusChangedNotification object:@(status)];
}

#pragma mark - public

- (void)refreshUserInfoCache:(CTMSGUserInfo *)userInfo withUserId:(NSString *)userId {
    if ([userId isEqualToString:[CTMSGIMClient sharedCTMSGIMClient].currentUserInfo.userId]) {
        [CTMSGIMClient sharedCTMSGIMClient].currentUserInfo = userInfo;
    }
    if (_enablePersistentUserInfoCache) {
        [[CTMSGDataBaseManager shareInstance] insertUserToDB:userInfo];
    } else {
        
    }
}

- (CTMSGUserInfo *)getUserInfoCache:(NSString *)userId {
    return [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userId];
}

- (void)clearUserInfoCache {
    [[CTMSGDataBaseManager shareInstance] clearUserDB];
}

#pragma mark - private

- (void)p_ctmsg_playSmsVoice {
    NSURL *url = [CTMSGUtilities voiceUrlForName:@"ctmsg_sms_receive"];
    static SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
}

#pragma mark - setter

- (void)setCurrentUserInfo:(CTMSGUserInfo *)currentUserInfo {
    [CTMSGIMClient sharedCTMSGIMClient].currentUserInfo = currentUserInfo;
}

- (void)setUUIDStr:(NSString *)UUIDStr {
    [CTMSGIMClient sharedCTMSGIMClient].UUIDStr = UUIDStr;
}

#pragma mark - getter

- (CTMSGUserInfo *)currentUserInfo {
    return [CTMSGIMClient sharedCTMSGIMClient].currentUserInfo;
}

- (CTMSGConnectionStatus)connectionStatus {
    return [[CTMSGIMClient sharedCTMSGIMClient] connectStatus];
}

@end
