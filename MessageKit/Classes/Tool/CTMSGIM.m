//
//  CTMSGIM.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/11.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGIM.h"
//#import "CTMSGIMClient.h"
//#import "CTMSGDataBaseManager.h"
//#import "CTMSGUserInfo.h"
//#import "CTMSGMessage.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CTMSGUtilities.h"
#import "CTMSGAudioRecordTool.h"
#import "CTMSGMessageBaseCell.h"
#import <objc/message.h>
#import <MessageLib/MessageLib.h>
#import "CTMSGLocalPushHelper.h"

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
//    [CTMSGIMClient sharedCTMSGIMClient].voiceAmrPath = [CTMSGAudioRecordTool shareRecorder].audioRecordCompressPath;
//    [CTMSGIMClient sharedCTMSGIMClient].voiceWavPath = [CTMSGAudioRecordTool shareRecorder].audioRecordPath;
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
                     host:(NSString *)host
                     port:(NSUInteger)port
                  success:(void (^)(NSString * _Nullable string))successBlock
                    error:(void (^)(CTMSGConnectErrorCode status, NSError * _Nullable error))errorBlock
           tokenIncorrect:(void (^)(void))tokenIncorrectBlock {
    [[CTMSGIMClient sharedCTMSGIMClient] connectWithUserId:userId
                                                  password:password
                                                      host:host
                                                      port:port
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
                        error:(nonnull void (^)(CTMSGErrorCode, long, NSError * _Nullable))errorBlock {
    CTMSGMessage * message = [[CTMSGIMClient sharedCTMSGIMClient] sendMessage:conversationType
                                                                     targetId:targetId
                                                                      content:content
                                                                  pushContent:pushContent
                                                                     pushData:pushData
                                                                      success:^(long messageId) {
                                                                          NSDictionary * dic = @{@"messageId": @(messageId),
                                                                                                 @"status": @(SentStatus_SENT)
                                                                                                 };
                                                                          [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
                                                                          if (successBlock) {
                                                                              successBlock(messageId);
                                                                          }
                                                                      } error:^(CTMSGErrorCode nErrorCode, long messageId, NSError * error) {
                                                                          NSDictionary * dic = @{@"messageId": @(messageId),
                                                                                                 @"status": @(SentStatus_FAILED)
                                                                                                 };
                                                                          [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
                                                                          if (errorBlock) {
                                                                              errorBlock(nErrorCode, messageId, error);
                                                                          }
                                                                      }];
    ((void(*)(id, SEL, CTMSGMessage *))(void *)objc_msgSend)(NSClassFromString(@"CTMSGConversationViewController"), NSSelectorFromString(@"updateForMessageSendOut:"), message);
    return message;
}

- (CTMSGMessage *)sendMediaMessage:(CTMSGConversationType)conversationType
                          targetId:(NSString *)targetId
                           content:(CTMSGMessageContent *)content
                       pushContent:(NSString *)pushContent
                          pushData:(NSString *)pushData
                      uploadConfig:(NSDictionary *)uploadConfig
                          progress:(void (^)(int, long))progressBlock
                           success:(void (^)(long))successBlock
                             error:(nonnull void (^)(CTMSGErrorCode, long, NSError * _Nullable))errorBlock
                            cancel:(void (^)(long))cancelBlock {
    CTMSGMessage * message = [[CTMSGIMClient sharedCTMSGIMClient] sendMediaMessage:conversationType
                                                                          targetId:targetId
                                                                           content:content
                                                                       pushContent:pushContent
                                                                          pushData:pushData
                                                                      uploadConfig:uploadConfig
                                                                          progress:^(int progress, long messageId) {
                                                                              NSDictionary * dic = @{
                                                                                                     @"messageId": @(messageId),
                                                                                                     @"status": @(SentStatus_SENDING),
                                                                                                     @"progress": @(progress),
                                                                                                     };
                                                                              [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
                                                                              if (progressBlock) {
                                                                                  progressBlock(progress, messageId);
                                                                              }
                                                                          } success:^(long messageId) {
                                                                               NSDictionary * dic = @{
                                                                                                      @"messageId": @(messageId),
                                                                                                      @"status": @(SentStatus_SENT)
                                                                                                      };
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
                                                                               if (successBlock) {
                                                                                   successBlock(messageId);
                                                                               }
                                                                           } error:^(CTMSGErrorCode errorCode, long messageId, NSError * error) {
                                                                               NSDictionary * dic = @{@"messageId": @(messageId),
                                                                                                      @"status": @(SentStatus_FAILED)
                                                                                                      };
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
                                                                               if (errorBlock) {
                                                                                   errorBlock(errorCode, messageId, error);
                                                                               }
                                                                           } cancel:^(long messageId) {
                                                                               NSDictionary * dic = @{@"messageId": @(messageId),
                                                                                                      @"status": @(SentStatus_CANCELED)
                                                                                                      };
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus object:dic];
                                                                               if (cancelBlock) {
                                                                                   cancelBlock(messageId);
                                                                               }
                                                                           }];
    
    ((void(*)(id, SEL, CTMSGMessage *))(void *)objc_msgSend)(NSClassFromString(@"CTMSGConversationViewController"), NSSelectorFromString(@"updateForMessageSendOut:"), message);
    return message;
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
    if ([message.content isKindOfClass:[CTMSGCommandMessage class]]) {
        if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMReceiveMessage:left:)]) {
            [_receiveMessageDelegate onCTMSGIMReceiveMessage:message left:nLeft];
        }
        return;
    }
    if ([message.content isKindOfClass:[CTMSGInformationNotificationMessage class]]) {
        if ([message.extra isEqualToString:@"follow"] ||
            [message.extra isEqualToString:@"visit"]) {
            if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMReceiveMessage:left:)]) {
                [_receiveMessageDelegate onCTMSGIMReceiveMessage:message left:nLeft];
            }
            return;
        }
    }
    CTMSGRunningMode runningMode = [CTMSGIMClient sharedCTMSGIMClient].sdkRunningMode;
    if (message.messageDirection == CTMSGMessageDirectionReceive) {
        if (runningMode == CTMSGRunningMode_Foreground) {
            if (!_disableMessageAlertSound) {
                BOOL voice = YES;
                if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMCustomAlertSound:)]) {
                    voice = [_receiveMessageDelegate onCTMSGIMCustomAlertSound:message];
                }
                if (voice) {
                    //TODO: - play alert sound
                    // 获取音频文件路径
                    NSURL *url = [CTMSGUtilities voiceUrlForName:@"ctmsg_sms_receive.caf"];
                    // 加载音效文件并创建 SoundID
                    SystemSoundID soundID = 0;
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
                    //                // 设置播放完成回调
                    //                AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
                    // 带有震动
//                    AudioServicesPlayAlertSound(soundID);
                    // 无振动
                    AudioServicesPlaySystemSound(soundID);
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
//                            [CTMSGLocalPushHelper ctmsg_sendLocalPushTitle:@"new message" userInfo:nil];
                        }
                    }];
                } else {
//                    [CTMSGLocalPushHelper ctmsg_sendLocalPushTitle:@"new message" userInfo:nil];
                }
            }
        }
    }
    NSDictionary * dic = @{
                           CTMSGKitDispatchMessageNotificationLeftKey : @(nLeft)
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:CTMSGKitDispatchMessageNotification object:message userInfo:dic];
    if ([_receiveMessageDelegate respondsToSelector:@selector(onCTMSGIMReceiveMessage:left:)]) {
        [_receiveMessageDelegate onCTMSGIMReceiveMessage:message left:nLeft];
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

- (void)requireNewNetToken {
    if ([_connectionStatusDelegate respondsToSelector:@selector(requireNewNetToken)]) {
        [_connectionStatusDelegate requireNewNetToken];
    }
}

#pragma mark - public

- (void)refreshUserInfoCache:(CTMSGUserInfo *)userInfo {
    if ([userInfo.userId isEqualToString:[CTMSGIMClient sharedCTMSGIMClient].currentUserInfo.userId]) {
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
    _UUIDStr = UUIDStr;
    [CTMSGIMClient sharedCTMSGIMClient].UUIDStr = UUIDStr;
}

- (void)setNetToken:(NSString *)netToken {
    _netToken = netToken;
    [CTMSGIMClient sharedCTMSGIMClient].netToken = netToken;
}

- (void)setUserAgent:(NSString *)userAgent {
    _userAgent = userAgent;
    [CTMSGIMClient sharedCTMSGIMClient].userAgent = userAgent;
}

- (void)setNetUA:(NSString *)netUA {
    _netUA = netUA;
    [CTMSGIMClient sharedCTMSGIMClient].netUA = netUA;
}

#pragma mark - getter

- (CTMSGUserInfo *)currentUserInfo {
    return [CTMSGIMClient sharedCTMSGIMClient].currentUserInfo;
}

- (CTMSGConnectionStatus)connectionStatus {
    return [[CTMSGIMClient sharedCTMSGIMClient] connectStatus];
}

@end
