//
//  CTMSGIMClient.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGIMClient.h"
#import "CTMSGAMRDataConverter.h"
#import "CTMSGDataBaseManager.h"
#import "CTMSGNetManager.h"
#import "CTMSGAudioRecordTool.h"
#import "CTMSGNetManager.h"
#import "CTMSGMessage.h"
#import "CTMSGMessageContent.h"
#import "CTMSGTextMessage.h"
#import "CTMSGUserInfo.h"
#import "CTMSGVoiceMessage.h"
#import "CTMSGImageMessage.h"
#import "CTMSGVideoMessage.h"
#import "CTMSGUnknownMessage.h"
#import "CTMSGInformationNotificationMessage.h"

#if __has_include (<MQTTClient/MQTTClient.h>)
#import <MQTTClient/MQTTClient.h>
#else
#import "MQTTClient.h"
#endif

@interface CTMSGIMClient () <MQTTSessionManagerDelegate>

@property (nonatomic, assign, readwrite) CTMSGConnectionStatus connectStatus;
@property (nonatomic, assign, readwrite) CTMSGNetworkStatus networkStatus;
@property(nonatomic, assign, readwrite) CTMSGRunningMode sdkRunningMode;
@property (nonatomic, strong) MQTTSessionManager * sessionManager;

@property (nonatomic, assign, readwrite) NSString * userName;
/**
 当前支持的消息类型集合
 */
@property (nonatomic, strong) NSMutableSet * supportMsgSet;

@end

@implementation CTMSGIMClient

#pragma mark - singleton

+ (instancetype)sharedCTMSGIMClient {
    static CTMSGIMClient * _client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _client = [[super allocWithZone:NULL] init];
        [_client p_ctmsg_commonInit];
    });
    return _client;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedCTMSGIMClient];
}

- (id)copy {
    return [[self class] sharedCTMSGIMClient];
}

- (id)mutableCopy {
    return [[self class] sharedCTMSGIMClient];
}

- (void)p_ctmsg_commonInit {
    _sessionManager = [[MQTTSessionManager alloc] init];
    _supportMsgSet = [[NSMutableSet alloc] init];
    NSString * document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _fileStoragePath = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"myFile/%@", self.userName]];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL exit =[fm fileExistsAtPath:_fileStoragePath isDirectory:&isDir];
    if (!exit || !isDir) {
        [fm createDirectoryAtPath:_fileStoragePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // app启动或者app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object:nil];
}

/***************************************
 - MQTT
 ****************************************/

#pragma mark - session manager

- (void)bindWithUserName:(NSString *)username
                password:(NSString *)password
                clientId:(NSString *)clientId
            success:(void (^)(NSString * _Nullable string))successBlock {
    NSInteger PortOfMQTTServer = 1883;
    NSString * AddressOfMQTTServer = @"192.168.1.2";
    // if will NO must willtopic nil willMsg nil willQos MQTTQosLevelAtMostOnce willRetainFlag NO
    [self.sessionManager connectTo:AddressOfMQTTServer
                              port:PortOfMQTTServer
                               tls:NO
                         keepalive:10
                             clean:YES
                              auth:YES
                              user:username
                              pass:password
                              will:NO
                         willTopic:nil
                           willMsg:nil
                           willQos:MQTTQosLevelAtMostOnce
                    willRetainFlag:NO
                      withClientId:nil
                    securityPolicy:[self customSecurityPolicy]
                      certificates:nil
                     protocolLevel:4
                    connectHandler:^(NSError *error) {
                        if (error) {
//                            NSLog(error);
                        } else {
                            if (successBlock) {
                                successBlock(nil);
                            }
                        }
                    }];
    self.connectStatus = ConnectionStatus_Connected;
}

#pragma mark ---- 状态
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    switch (newState) {
        case MQTTSessionManagerStateConnected:
            self.connectStatus = ConnectionStatus_Connected;
            NSLog(@"eventCode -- 连接成功");
            break;
        case MQTTSessionManagerStateConnecting:
            self.connectStatus = ConnectionStatus_Connecting;
            NSLog(@"eventCode -- 连接中");
            break;
        case MQTTSessionManagerStateClosed:
            self.connectStatus = ConnectionStatus_Unconnected;
            NSLog(@"eventCode -- 连接被关闭");
            break;
        case MQTTSessionManagerStateError:
            self.connectStatus = ConnectionStatus_VALIDATE_INVALID;
            NSLog(@"eventCode -- 连接错误");
            break;
        case MQTTSessionManagerStateClosing:
            self.connectStatus = ConnectionStatus_DISCONN_EXCEPTION;
            NSLog(@"eventCode -- 关闭中");
            break;
        case MQTTSessionManagerStateStarting:
            self.connectStatus = ConnectionStatus_Connecting;
            NSLog(@"eventCode -- 连接开始");
            break;
        default:
            break;
    }
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID {
    if ([_receiveMessageDelegate respondsToSelector:@selector(message)]) {
        
    }
}

- (void)messageDelivered:(UInt16)msgID {
    
}

- (void)receiveTestMessage:(CTMSGMessage *)message {
    NSData * data = [message.content encode];
    NSDictionary * dic = @{
                           @"targetid":message.targetId,
                           @"direction":@(message.messageDirection),
                           @"data":[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],
                           @"messageType": message.objectName,
                           @"senderUserId": message.senderUserId,
                           };
    NSData * tData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    [self sessionManager:nil didReceiveMessage:tData onTopic:nil retained:YES];
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString * targetId = dic[@"targetid"];
    NSString * senderUserId = dic[@"senderUserId"];
    NSString * messageType = dic[@"messageType"];
    CTMSGMessageDirection direction = (NSInteger)([dic[@"direction"] intValue]);
    NSString * contentStr = dic[@"data"];
    NSData * mData = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    CTMSGMessageContent * content;
    if ([messageType isEqualToString:CTMSGTextMessageTypeIdentifier]) {
        content = [[CTMSGTextMessage alloc] init];
        [(CTMSGTextMessage *)content decodeWithData:mData];
    }
    CTMSGMessage * message = [[CTMSGMessage alloc] initWithType:ConversationType_PRIVATE
                                                       targetId:targetId
                                                      direction:direction
                                                      messageId:0
                                                        content:content];
    message.senderUserId = senderUserId;
    message.receivedTime = [[NSDate date] timeIntervalSince1970] * 1000;
    message.sentTime = message.receivedTime;
    message.sentStatus = SentStatus_SENT;
    message.receivedStatus = ReceivedStatus_UNREAD;
    long messageId = [[CTMSGDataBaseManager shareInstance] insertMessageToDB:message conversationType:ConversationType_PRIVATE hasRead:NO];
    message.messageId = messageId;
    if ([_receiveMessageDelegate respondsToSelector:@selector(onReceived:left:object:)]) {
        [_receiveMessageDelegate onReceived:message left:0 object:nil];
    }
}

//- (void)sendDataToTopic:(NSString *)topic dict:(NSDictionary *)dict {
//    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
//    [self.sessionManager sendData:data topic:topic qos:MQTTQosLevelExactlyOnce retain:NO];
////    [self.mqttSession publishData:nil onTopic:@"" retain:NO qos:MQTTQosLevelAtMostOnce publishHandler:^(NSError *error) {
////
////    }];
//}

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
//    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //    [_mqttDataDic setDictionary:dic];
    //    if (_mqttDataDic.count != 0) {
    if ([topic rangeOfString:@"status"].location != NSNotFound) {
        //        [self screenCarDic:_chooseCodeCarStr];
    }
    else if ([topic rangeOfString:@"motor_control"].location != NSNotFound) {
        //        [self mqttMotorControl:_chooseCodeCarStr];
    }
    else if ([topic rangeOfString:@"bms_info_1"].location != NSNotFound) {
        //        [self buffInfo_1:_chooseCodeCarStr];
    }
    else if ([topic rangeOfString:@"bms_info_2"].location != NSNotFound) {
        //        [self buffInfo_2:_chooseCodeCarStr];
    }
    else if ([topic rangeOfString:@"charging_info"].location != NSNotFound) {
        //        [self getMQTTChargingData:_chooseCodeCarStr];
    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(MQTTClientModel_handleMessage:onTopic:retained:)]) {
//        [self.delegate MQTTClientModel_handleMessage:data onTopic:topic retained:retained];
//    }
}

#pragma mark - connection

- (void)connectWithUserId:(NSString *)userId
                 password:(NSString *)password
                  success:(void (^)(NSString * _Nullable string))successBlock
                    error:(void (^)(CTMSGConnectErrorCode status, NSError * _Nullable))errorBlock
           tokenIncorrect:(void (^)(void))tokenIncorrectBlock {
    NSParameterAssert(userId && password);
//    NSParameterAssert(_deviceToken);
//    if (self.networkStatus == CTMSGNetworkStatusNotReachable) {
//        if (errorBlock) {
//            errorBlock(CTMSG_NET_UNAVAILABLE, nil);
//        }
//        return;
//    }
    if (_sessionManager.state == MQTTSessionManagerStateConnected) {
        if (errorBlock) {
            errorBlock(CTMSG_CONNECTION_EXIST, nil);
        }
        return;
    }
#if DEBUG
    
#endif
    _userName = userId;
    NSString * clientid = [NSString stringWithFormat:@"client_%@_iphone", userId];
    [self bindWithUserName:userId password:password clientId:clientid success:successBlock];
}

- (void)disconnect {
    __weak typeof(self) weakSelf = self;
    [self.sessionManager disconnectWithDisconnectHandler:^(NSError *error) {
        if (!error) {
            weakSelf.connectStatus = ConnectionStatus_Unconnected;
//            [weakSelf.sessionManager setDelegate:nil];
//            weakSelf.sessionManager = nil;
        } else {
            NSLog(@"断开连接  error = %@",[error description]);
        }
    }];
}

- (void)disconnect:(BOOL)isReceivePush {
    
}

- (void)logout {
    [self disconnect];
}

//- (void)reConnect {
//    if (_sessionManager && _sessionManager.port) {
//        self.sessionManager.delegate = self;
//        _connectStatus = ConnectionStatus_Unconnected;
//        [self.sessionManager connectToLast:^(NSError *error) {
//            NSLog(@"重新连接  error = %@",[error description]);
//        }];
//    }
//    else {
//#if DEBUG
//        NSString * username = @"10003165";
//        NSString * password = @"iJyM5tuDtEOJQY73ncDdNnRFpMHcvpxu";
//#endif
//        NSString * clientId = _deviceToken ? _deviceToken : nil;
//        self.sessionManager = [[MQTTSessionManager alloc] init];
//        self.sessionManager.delegate = self;
//        [self bindWithUserName:username password:password clientId:clientId];
//    }
//}

#pragma mark - sende message

- (void)registerMessageType:(Class)messageClass {
    if (messageClass) {
        [_supportMsgSet addObject:NSStringFromClass(messageClass)];
    }
}

- (CTMSGMessage *)sendMessage:(CTMSGConversationType)conversationType
                     targetId:(NSString *)targetId
                      content:(CTMSGMessageContent *)content
                  pushContent:(NSString *)pushContent
                     pushData:(NSString *)pushData
                      success:(void (^)(long))successBlock
                        error:(void (^)(CTMSGErrorCode, long))errorBlock {
    CTMSGMessage * sendMessage = [[CTMSGMessage alloc] initWithType:conversationType
                                                           targetId:targetId
                                                          direction:CTMSGMessageDirectionSend
                                                          messageId:0
                                                            content:content];
    sendMessage.senderUserId = _currentUserInfo.userId;
    sendMessage.sentTime = [[NSDate date] timeIntervalSince1970] * 1000;
    sendMessage.receivedTime = sendMessage.sentTime;
    sendMessage.sentStatus = SentStatus_SENT;
    sendMessage.receivedStatus = ReceivedStatus_UNREAD;
    long messageId =  [[CTMSGDataBaseManager shareInstance] insertMessageToDB:sendMessage conversationType:conversationType hasRead:YES];
    sendMessage.messageId = messageId;
    if ([_receiveMessageDelegate respondsToSelector:@selector(onReceived:left:object:)]) {
        [_receiveMessageDelegate onReceived:sendMessage left:0 object:nil];
    }
//    NSData * data = [content encode];
//    NSDictionary * dic = @{
//                           @"content": data,
//                           };
    //TODO: - send message through CTMSGNetManager
    
//    [self sendDataToTopic:@"" dict:dic];
    return sendMessage;
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
    return [self sendMediaMessage:conversationType
                         targetId:targetId
                          content:content
                      pushContent:pushContent
                         pushData:pushData
                    uploadPrepare:nil
                         progress:progressBlock
                          success:successBlock
                            error:errorBlock
                           cancel:cancelBlock];
}

- (CTMSGMessage *)sendMediaMessage:(CTMSGConversationType)conversationType
                          targetId:(NSString *)targetId
                           content:(CTMSGMessageContent *)content
                       pushContent:(NSString *)pushContent
                          pushData:(NSString *)pushData
                     uploadPrepare:(void (^)(CTMSGUploadMediaStatusListener * _Nonnull))uploadPrepareBlock
                          progress:(void (^)(int, long))progressBlock success:(void (^)(long))successBlock
                             error:(void (^)(CTMSGErrorCode, long))errorBlock
                            cancel:(void (^)(long))cancelBlock {
    
    //TODO: - upload media
    //TODO: - get url after media 重新组装content
    if ([content isKindOfClass:[CTMSGVoiceMessage class]]) {
        
    }
    
    return [self sendMessage:conversationType
                    targetId:targetId
                     content:content
                 pushContent:pushContent
                    pushData:pushData
                     success:successBlock
                       error:errorBlock];
}

- (BOOL)cancelSendMediaMessage:(long)messageId {
    //TODO: - 应该是模仿sdwebimage中operation控制文件的上传 如果取消上传 则取消当前queue的opeartion
    return YES;
}

- (CTMSGMessage *)insertOutgoingMessage:(CTMSGConversationType)conversationType targetId:(NSString *)targetId sentStatus:(CTMSGSentStatus)sentStatus content:(CTMSGMessageContent *)content {
    return nil;
}

- (CTMSGMessage *)insertOutgoingMessage:(CTMSGConversationType)conversationType targetId:(NSString *)targetId sentStatus:(CTMSGSentStatus)sentStatus content:(CTMSGMessageContent *)content sentTime:(long long)sentTime {
    return nil;
}

- (CTMSGMessage *)insertIncomingMessage:(CTMSGConversationType)conversationType targetId:(NSString *)targetId senderUserId:(NSString *)senderUserId receivedStatus:(CTMSGReceivedStatus)receivedStatus content:(CTMSGMessageContent *)content {
    return nil;
}

- (CTMSGMessage *)insertIncomingMessage:(CTMSGConversationType)conversationType targetId:(NSString *)targetId senderUserId:(NSString *)senderUserId receivedStatus:(CTMSGReceivedStatus)receivedStatus content:(CTMSGMessageContent *)content sentTime:(long long)sentTime {
    return nil;
}

- (void)downloadMediaMessage:(long)messageId progress:(void (^)(int))progressBlock success:(void (^)(NSString * _Nonnull))successBlock error:(void (^)(CTMSGErrorCode))errorBlock cancel:(void (^)(void))cancelBlock {
    // 下载
}

- (void)downloadMediaFile:(CTMSGConversationType)conversationType targetId:(NSString *)targetId mediaType:(CTMSGMediaType)mediaType mediaUrl:(NSString *)mediaUrl progress:(void (^)(int))progressBlock success:(void (^)(NSString * _Nonnull))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    
}

- (BOOL)cancelDownloadMediaMessage:(long)messageId {
    return YES;
}

#pragma mark - search conversation & message ..
- (NSArray<CTMSGMessage *> *)getLatestMessages:(CTMSGConversationType)conversationType targetId:(NSString *)targetId count:(int)count {
    return [[CTMSGDataBaseManager shareInstance] searchLatestMessagesByTargetId:targetId count:count];
}

- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                oldestMessageId:(long)oldestMessageId
                                          count:(int)count {
    return [[CTMSGDataBaseManager shareInstance] searchLatestMessagesByTargetId:targetId oldestMessageId:oldestMessageId count:count];
}

- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                       sentTime:(long long)sentTime
                                    beforeCount:(int)beforeCount
                                     afterCount:(int)afterCount {
    
    return nil;
}

- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                     objectName:(NSString *)objectName
                                oldestMessageId:(long)oldestMessageId
                                          count:(int)count {
    return nil;
}

- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                     objectName:(NSString *)objectName
                                  baseMessageId:(long)baseMessageId
                                      isForward:(BOOL)isForward
                                          count:(int)count {
    return nil;
}

- (void)getRemoteHistoryMessages:(CTMSGConversationType)conversationType targetId:(NSString *)targetId recordTime:(long long)recordTime count:(int)count success:(void (^)(NSArray * _Nonnull))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    [CTMSGNetManager getConversationDetail:targetId lastId:nil success:^(id  _Nonnull response) {
        
    } failure:^(NSError * _Nonnull err) {
        
    }];
    
//    [CTMSGNetManager ctmsg_get:@"" withParameters:@{} success:^(id  _Nullable result) {
//        NSMutableArray *array;
//        if (successBlock) {
//            successBlock(array);
//        }
//    } failed:^(NSString * _Nullable msg, id  _Nullable result) {
//        if (errorBlock) {
//            errorBlock(ERROCTMSGODE_UNKNOWN);
//        }
//    }];
}

- (void)getRemoteHistoryMessagesAndOtherInfo:(CTMSGConversationType)conversationType
                                    targetId:(NSString *)targetId
                                  recordTime:(long long)recordTime
                                       count:(int)count
                                     success:(void (^)(NSArray *messages, id otherInfo))successBlock
                                       error:(void (^)(CTMSGErrorCode status))errorBlock {
    
}

- (long long)getMessageSendTime:(long)messageId {
    return [[CTMSGDataBaseManager shareInstance] searchMessagesSendTimeByMessageId:@(messageId).stringValue];
}

- (CTMSGMessage *)getMessage:(long)messageId {
    NSString *idStr = [NSString stringWithFormat:@"%ld", messageId];
    return [[CTMSGDataBaseManager shareInstance] searchMessagesByMessageId:idStr];
}

- (CTMSGMessage *)getMessageByUId:(NSString *)messageUId {
    return [[CTMSGDataBaseManager shareInstance] searchMessagesByMessageId:messageUId];
}

- (BOOL)deleteMessages:(NSArray<NSString *> *)messageIds {
    if ([messageIds isKindOfClass:[NSArray class]]) {
        if (messageIds.count > 0) {
            if ([messageIds.firstObject isKindOfClass:[NSString class]]) {
                return [[CTMSGDataBaseManager shareInstance] removeMessageWithIds:messageIds];
            }
        }
    }
    return NO;
}

- (void)deleteMessages:(CTMSGConversationType)conversationType targetId:(NSString *)targetId success:(void (^)(void))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    BOOL isSuccess = [[CTMSGDataBaseManager shareInstance] removeAllMessagewithTargetId:targetId];
    if (isSuccess) {
        isSuccess = [[CTMSGDataBaseManager shareInstance] compressMessageDB];
    }
    if (isSuccess) {
        if (successBlock) {
            successBlock();
        }
    } else {
        if (errorBlock) {
            errorBlock(ERROCTMSGODE_UNKNOWN);
        }
    }
}

- (BOOL)clearMessages:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return [[CTMSGDataBaseManager shareInstance] removeAllMessagewithTargetId:targetId];
}

- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value {
    return YES;
}

- (BOOL)setMessageReceivedStatus:(CTMSGReceivedStatus)receivedStatus messageId:(long)messageId {
    return [[CTMSGDataBaseManager shareInstance] updateMessageReadStatusWithTargetId:@(messageId).stringValue];
}

- (BOOL)setMessageSentStatus:(CTMSGSentStatus)sentStatus messageId:(long)messageId {
    return [[CTMSGDataBaseManager shareInstance] updateMessageReadStatusWithTargetId:@(messageId).stringValue];
}

- (NSArray<CTMSGConversation *> *)getConversationList {
    return [[CTMSGDataBaseManager shareInstance] searchConverstationList];
}

- (NSArray<CTMSGConversation *> *)getConversationList:(NSArray *)conversationTypeList {
    return [[CTMSGDataBaseManager shareInstance] searchConverstationListForCount:20];
}

- (NSArray<CTMSGConversation *> *)getConversationList:(NSArray *)conversationTypeList count:(int)count startTime:(long long)startTime {
    return [[CTMSGDataBaseManager shareInstance] searchConverstationListForCount:count time:startTime];
}

- (CTMSGConversation *)getConversation:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return nil;
}

- (int)getMessageCount:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return (int)[[CTMSGDataBaseManager shareInstance] searchMessageCountWithTargetId:targetId];
}

- (BOOL)clearConversations:(NSArray *)conversationTypeList {
    return [[CTMSGDataBaseManager shareInstance] clearConversationDB];
}

- (BOOL)removeConversation:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return [[CTMSGDataBaseManager shareInstance] removeConversationFromDB:targetId];
}

- (BOOL)setConversationToTop:(CTMSGConversationType)conversationType targetId:(NSString *)targetId isTop:(BOOL)isTop {
    return [[CTMSGDataBaseManager shareInstance] updateConversationTop:isTop to:targetId];
}

- (NSArray<CTMSGConversation *> *)getTopConversationList:(NSArray *)conversationTypeList {
    return nil;
}

- (NSString *)getTextMessageDraft:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return [[CTMSGDataBaseManager shareInstance] searchConverstationDraft:targetId];
}

- (BOOL)saveTextMessageDraft:(CTMSGConversationType)conversationType targetId:(NSString *)targetId content:(NSString *)content {
    return [[CTMSGDataBaseManager shareInstance] updateConversationDraft:content to:targetId];
}

- (BOOL)clearTextMessageDraft:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return [[CTMSGDataBaseManager shareInstance] updateConversationDraft:nil to:targetId];
}

#pragma mark - unread count

- (int)getTotalUnreadCount {
    return [[CTMSGDataBaseManager shareInstance] searchTotalUnreadCount];
}

- (int)getUnreadCount:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return [[CTMSGDataBaseManager shareInstance] searchUnreadCountWithTargetId:targetId];
}

- (int)getTotalUnreadCount:(NSArray<CTMSGConversation *> *)conversations {
    return 1;
}

- (int)getUnreadCount:(NSArray *)conversationTypes {
    //TODO: - get total unread count;
    return 1;
}

- (BOOL)clearMessagesUnreadStatus:(CTMSGConversationType)conversationType targetId:(NSString *)targetId {
    return [[CTMSGDataBaseManager shareInstance] updateMessageReadStatusWithTargetId:targetId];
}

- (BOOL)clearMessagesUnreadStatus:(CTMSGConversationType)conversationType targetId:(NSString *)targetId time:(long long)timestamp {
    return YES;
}

#pragma mark - notification


- (void)setConversationNotificationStatus:(CTMSGConversationType)conversationType targetId:(NSString *)targetId isBlocked:(BOOL)isBlocked success:(void (^)(CTMSGConversationNotificationStatus))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    
}

- (void)getConversationNotificationStatus:(CTMSGConversationType)conversationType targetId:(NSString *)targetId success:(void (^)(CTMSGConversationNotificationStatus))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    
}

- (NSArray<CTMSGConversation *> *)getBlockedConversationList:(NSArray *)conversationTypeList {
    return nil;
}

- (void)applicationBecomeActive:(NSNotification *)notificaion {
    //TODO: - qiantai
    _sdkRunningMode = CTMSGRunningMode_Foreground;
}

- (void)applicationEnterBackground:(NSNotification *)notificaion {
    //TODO: - houtai
    _sdkRunningMode = CTMSGRunningMode_Background;
}

#pragma mark - black list

- (void)addToBlacklist:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    [CTMSGNetManager addToBlacklist:userId success:^(id  _Nonnull response) {
//        BOOL success =
        [[CTMSGDataBaseManager shareInstance] insertBlackTargetId:userId];
        if (successBlock) {
            successBlock();
        }
    } failure:^(NSError * _Nonnull err) {
        if (errorBlock) {
            errorBlock(ERROCTMSGODE_UNKNOWN);
        }
    }];
}

- (void)removeFromBlacklist:(NSString *)userId success:(void (^)(void))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    [CTMSGNetManager removeToBlacklist:userId success:^(id  _Nonnull response) {
//        BOOL success =
        [[CTMSGDataBaseManager shareInstance] removeBlackTargetId:userId];
        if (successBlock) {
            successBlock();
        }
    } failure:^(NSError * _Nonnull err) {
        if (errorBlock) {
            errorBlock(ERROCTMSGODE_UNKNOWN);
        }
    }];
}

- (void)getBlacklistStatus:(NSString *)userId success:(void (^)(int))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    
    BOOL success = [[CTMSGDataBaseManager shareInstance] isBlackInTable:userId];
    if (successBlock) {
        successBlock(success);
    }
//    if (success) {
//        if (successBlock) {
//            successBlock();
//        }
//    } else {
//        if (errorBlock) {
//            errorBlock(ERROCTMSGODE_UNKNOWN);
//        }
//    }
}

- (void)getBlacklist:(void (^)(NSArray * _Nonnull))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    [CTMSGNetManager getBlacklistsuccess:^(id  _Nonnull response) {
        NSArray * array;
        if (successBlock) {
            successBlock(array);
        }
    } failure:^(NSError * _Nonnull err) {
        if (errorBlock) {
            errorBlock(ERROCTMSGODE_UNKNOWN);
        }
    }];
}

#pragma mark - delegate

- (void)syncConversationReadStatus:(CTMSGConversationType)conversationType targetId:(NSString *)targetId time:(long long)timestamp success:(void (^)(void))successBlock error:(void (^)(CTMSGErrorCode))errorBlock {
    
}

- (NSDictionary *)getPushExtraFromLaunchOptions:(NSDictionary *)launchOptions {
    return nil;
}

- (NSDictionary *)getPushExtraFromRemoteNotification:(NSDictionary *)userInfo {
    return nil;
}

- (NSString *)getKITVersion {
    return @"1.0.0";
}

- (long long)getDeltaTime {
    return 1;
}

- (NSData *)decodeAMRToWAVE:(NSData *)data {
    NSString * amr = [CTMSGAudioRecordTool shareRecorder].audioRecordCompressPath;
    NSString * wav = [CTMSGAudioRecordTool shareRecorder].audioRecordPath;
    [[CTMSGAMRDataConverter sharedAMRDataConverter] convertAmrToWav:amr wavSavePath:wav];
    NSData * returnData = [NSData dataWithContentsOfFile:wav];
    return returnData;
//    return [[CTMSGAMRDataConverter sharedAMRDataConverter] decodeAMRToWAVE:data];
}

- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data {
    return nil;
//    return [[CTMSGAMRDataConverter sharedAMRDataConverter] decodeAMRToWAVEWithoutHeader:data];
}

- (NSData *)encodeWAVEToAMR:(NSData *)data channel:(int)nChannels nBitsPerSample:(int)nBitsPerSample {
    NSString * amr = [CTMSGAudioRecordTool shareRecorder].audioRecordCompressPath;
    NSString * wav = [CTMSGAudioRecordTool shareRecorder].audioRecordPath;
    [[CTMSGAMRDataConverter sharedAMRDataConverter] convertAmrToWav:wav wavSavePath:amr];
    NSData * returnData = [NSData dataWithContentsOfFile:amr];
    return returnData;
//    return [[CTMSGAMRDataConverter sharedAMRDataConverter] encodeWAVEToAMR:data channel:nChannels nBitsPerSample:nBitsPerSample];
}

#pragma mark - public


#pragma mark - setter

- (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
}

- (BOOL)setServerInfo:(NSString *)naviServer fileServer:(NSString *)fileServer {
    return YES;
}

- (void)setConnectStatus:(CTMSGConnectionStatus)connectStatus {
    _connectStatus = connectStatus;
    if ([_connectDelegate respondsToSelector:@selector(onConnectionStatusChanged:)]) {
        [_connectDelegate onConnectionStatusChanged:connectStatus];
    }
}

//- (void)setTypingStatusdelegate:(id<CTMSGConnectionStatusChangeDelegate>)typingStatusdelegate {
//
//}

//- (void)setConnectDelegate:(id<CTMSGConnectionStatusChangeDelegate>)connectDelegate {
//
//}

//- (void)setReceiveMessageDelegate:(id<CTMSGIMClientReceiveMessageDelegate>)receiveMessageDelegate {
//
//}
//
//- (void)setLogInfoDelegate:(id<CTMSGLogInfoDelegate>)logInfoDelegate {
//
//}

#pragma mark - getter

- (MQTTSessionManagerState)getSessionStatus {
    return [_sessionManager state];
}

//- (CTMSGNetworkStatus)networkStatus {
//    return _networkStatus;
//}

- (MQTTSSLSecurityPolicy *)customSecurityPolicy {
    return [MQTTSSLSecurityPolicy defaultPolicy];
    //    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    //
    //    securityPolicy.allowInvalidCertificates = YES;
    //    securityPolicy.validatesCertificateChain = YES;
    //    securityPolicy.validatesDomainName = NO;
    //    return securityPolicy;
}

- (CTMSGNetworkStatus)networkStatus {
    if ([CTMSGNetManager netReachable]) {
        if ([CTMSGNetManager wifiReachable]) {
            return CTMSGNetworkStatusReachableViaWiFi;
        } else {
            return CTMSGNetworkStatusReachableViaWWAN;
        }
    } else {
        return CTMSGNetworkStatusNotReachable;
    }
}
//
//- (NSString *)fileStoragePath {
//    return @"";
//}

@end
