//
//  CTMSGIMClient.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTMSGEnumDefine.h"

@class CTMSGMessage, CTMSGUserInfo, CTMSGMessageContent, CTMSGConversation, CTMSGUploadMediaStatusListener, CTMSGDiscussion, CTMSGSearchConversationResult, CTMSGPushProfile;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 消息接收监听器

/*!
 IMlib消息接收的监听器
 
 @discussion
 设置的消息接收监听器请参考CTMSGIMClient的setReceiveMessageDelegate:object:方法。
 
 @warning 如果您使用IMlib，可以设置并实现此Delegate监听消息接收；
 如果您使用MessageKit，请使用RCIM中的CTMSGIMReceiveMessageDelegate监听消息接收，而不要使用此监听器，否则会导致MessageKit中无法自动更新UI！
 */

@protocol CTMSGIMClientReceiveMessageDelegate <NSObject>

/*!
 接收消息的回调方法
 
 @param message     当前接收到的消息
 @param nLeft       还剩余的未接收的消息数，left>=0
 @param object      消息监听设置的key值
 
 @discussion 如果您设置了IMlib消息监听之后，SDK在接收到消息时候会执行此方法。
 其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
 您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
 object为您在设置消息接收监听时的key值。
 */
- (void)onReceived:(CTMSGMessage *)message left:(int)nLeft object:(_Nullable id)object;

@optional
/*!
 消息被撤回的回调方法
 
 @param messageId 被撤回的消息ID
 
 @discussion 被撤回的消息会变更为RCRecallNotificationMessage，App需要在UI上刷新这条消息。
 */
- (void)onMessageRecalled:(long)messageId;

/*!
 请求消息已读回执（收到需要阅读时发送回执的请求，收到此请求后在会话页面已经展示该 messageUId 对应的消息或者调用
 getHistoryMessages 获取消息的时候，包含此 messageUId 的消息，需要调用 sendMessageReadReceiptResponse
 接口发送消息阅读回执）
 
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 */
- (void)onMessageReceiptRequest:(CTMSGConversationType)conversationType
                       targetId:(NSString *)targetId
                     messageUId:(NSString *)messageUId NS_UNAVAILABLE;

/*!
 消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param userIdList 已读userId列表
 */
- (void)onMessageReceiptResponse:(CTMSGConversationType)conversationType
                        targetId:(NSString *)targetId
                      messageUId:(NSString *)messageUId
                      readerList:(NSMutableDictionary *)userIdList NS_UNAVAILABLE;

@end

#pragma mark - 连接状态监听器

/*!
 连接状态的的监听器
 
 @discussion
 设置的连接状态监听器，请参考CTMSGIMClient的setCTMSGConnectionStatusChangeDelegate:方法。
 
 @warning 如果您使用，可以设置并实现此Delegate监听连接状态变化；
 如果您使用MessageKit，请使用RCIM中的RCIMConnectionStatusDelegate监听消息接收，而不要使用此监听器，否则会导致MessageKit中无法自动更新UI！
 */
@protocol CTMSGConnectionStatusChangeDelegate <NSObject>

/*!
 连接状态的的监听器
 
 @param status  SDK与服务器的连接状态
 
 @discussion 如果您设置了消息监听之后，当SDK与服务器的连接状态发生变化时，会回调此方法。
 */
- (void)onConnectionStatusChanged:(CTMSGConnectionStatus)status;

@end

#pragma mark - 聊天室监听器

/*!
 聊天室状态的的监听器
 
 @discussion
 设置的聊天室状态监听器，请参考CTMSGIMClient的setChatRoomStatusDelegate:方法。
 */
//@protocol CTMSGChatRoomStatusDelegate <NSObject>
//
///*!
// 开始加入聊天室的回调
//
// @param chatroomId 聊天室ID
// */
//- (void)onChatRoomJoining:(NSString *)chatroomId;
//
///*!
// 加入聊天室成功的回调
//
// @param chatroomId 聊天室ID
// */
//- (void)onChatRoomJoined:(NSString *)chatroomId;
//
///*!
// 加入聊天室失败的回调
//
// @param chatroomId 聊天室ID
// @param errorCode  加入失败的错误码
//
// @discussion
// 如果错误码是KICKED_FROM_CHATROOM或RC_CHATROOM_NOT_EXIST，则不会自动重新加入聊天室，App需要按照自己的逻辑处理。
// */
//- (void)onChatRoomJoinFailed:(NSString *)chatroomId errorCode:(CTMSGErrorCode)errorCode;
//
///*!
// 退出聊天室成功的回调
//
// @param chatroomId 聊天室ID
// */
//- (void)onChatRoomQuited:(NSString *)chatroomId;
//
//@end

#pragma mark - 输入状态监听器

/*!
 输入状态的的监听器
 
 @discussion 设置的输入状态监听器，请参考CTMSGIMClient的setCTMSGTypingStatusDelegate:方法。
 
 @warning
 如果您使用，可以设置并实现此Delegate监听消息接收；如果您使用MessageKit，请直接设置RCIM中的enableSendComposingStatus，而不要使用此监听器，否则会导致MessageKit中无法自动更新UI！
 */
@protocol CTMSGTypingStatusDelegate <NSObject>

/*!
 用户输入状态变化的回调
 
 @param conversationType        会话类型
 @param targetId                会话目标ID
 @param userTypingStatusList 正在输入的RCUserTypingStatus列表（nil标示当前没有用户正在输入）
 
 @discussion
 当客户端收到用户输入状态的变化时，会回调此接口，通知发生变化的会话以及当前正在输入的RCUserTypingStatus列表。
 
 @warning 目前仅支持单聊。
 */
- (void)onTypingStatusChanged:(CTMSGConversationType)conversationType
                     targetId:(NSString *)targetId
                       status:(NSArray *)userTypingStatusList;

@end

#pragma mark - 日志监听器
/*!
 日志的监听器
 
 @discussion
 设置日志的监听器，请参考CTMSGIMClient的setCTMSGLogInfoDelegate:方法。
 
 @discussion 您可以通过logLevel来控制日志的级别。
 */
@protocol CTMSGLogInfoDelegate <NSObject>

/*!
 日志的回调
 
 @param logInfo 日志信息
 */
- (void)didOccurLog:(NSString *)logInfo;

@end

#pragma mark - 核心类

/*!
 核心类
 
 @discussion 您需要通过sharedCTMSGIMClient方法，获取单例对象。
 */
@interface CTMSGIMClient : NSObject

/*!
 设置deviceToken，用于远程推送 从系统获取到的设备号deviceToken(需要去掉空格和尖括号)
 
 NSString *token = [deviceToken description];
 token = [token stringByReplacingOccurrencesOfString:@"<"
 withString:@""];
 token = [token stringByReplacingOccurrencesOfString:@">"
 withString:@""];
 token = [token stringByReplacingOccurrencesOfString:@" "
 withString:@""];
 [[CTMSGIMClient sharedCTMSGIMClient] setDeviceToken:token];
 */
@property (nonatomic, copy) NSString * deviceToken;
@property (nonatomic, copy) NSString * UUIDStr;

/**
 获取当前连接状态
 */
@property (nonatomic, assign, readonly) CTMSGConnectionStatus connectStatus;

/*!
 获取当前的网络状态
 */
@property (nonatomic, assign, readonly) CTMSGNetworkStatus networkStatus;

/*!
 当前所处的运行状态 前台或后台
 */
@property(nonatomic, assign, readonly) CTMSGRunningMode sdkRunningMode;

/*!
 设置连接状态监听器
 */
@property (nonatomic, weak) id<CTMSGConnectionStatusChangeDelegate> connectDelegate;

/*!
 设置输入状态的的监听器
 */
@property (nonatomic, weak) id<CTMSGTypingStatusDelegate> typingStatusdelegate NS_UNAVAILABLE;

#pragma mark - 日志

/*!
 设置日志级别
 */
@property(nonatomic, assign) CTMSGLogLevel logLevel;

/*!
 设置日志的监听器
 */
@property (nonatomic, weak) id<CTMSGLogInfoDelegate> logInfoDelegate NS_UNAVAILABLE;

#pragma mark 消息接收监听
/*!
 设置的消息接收监听器请参考CTMSGIMClient的setReceiveMessageDelegate:方法。
 */
@property (nonatomic, weak) id<CTMSGIMClientReceiveMessageDelegate> receiveMessageDelegate;

//远程推送相关设置
@property(nonatomic, strong, readonly) CTMSGPushProfile *pushProfile;

/*!
 文件消息下载路径 File Storage
 @discussion 默认值为沙盒下的Documents/MyFile目录。您可以通过修改RCConfig.plist中的RelativePath来修改该路径。
 */
@property(nonatomic, strong, readonly) NSString *fileStoragePath;

/*!
 获取通讯能力库的核心类单例
 
 @return 通讯能力库的核心类单例
 
 @discussion 您可以通过此方法，获取的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedCTMSGIMClient;

#pragma mark - 连接与断开服务器

- (void)connectWithUserId:(NSString *)userId
                 password:(NSString *)password
                  success:(void (^ _Nullable )(NSString * _Nullable string))successBlock
                    error:(void (^ _Nullable )(CTMSGConnectErrorCode status, NSError * _Nullable error))errorBlock
           tokenIncorrect:(void (^ _Nullable )(void))tokenIncorrectBlock;

- (void)reConnect NS_UNAVAILABLE;

/*!
 断开与服务器的连接
 */
- (void)disconnect;
- (void)disconnect:(BOOL)isReceivePush NS_UNAVAILABLE;
- (void)logout;

#pragma mark - 用户信息

/*!
 当前登录用户的用户信息
 
 @discussion 用于与服务器建立连接之后，设置当前用户的用户信息。
 
 @warning 如果传入的用户信息中的用户ID与当前登录的用户ID不匹配，则将会忽略。
 如果您使用，请使用此字段设置当前登录用户的用户信息；
 如果您使用MessageKit，请使用RCIM中的currentUserInfo设置当前登录用户的用户信息，而不要使用此字段。
 */
@property(nonatomic, strong) CTMSGUserInfo *currentUserInfo;

#pragma mark - 消息接收与发送

/*!
 注册自定义的消息类型
 
 @param messageClass    自定义消息的类，该自定义消息需要继承于CTMSGMessageContent
 
 @discussion
 如果您需要自定义消息，必须调用此方法注册该自定义消息的消息类型，否则SDK将无法识别和解析该类型消息。
 
 @warning 如果您使用，请使用此方法注册自定义的消息类型；
 如果您使用MessageKit，请使用RCIM中的同名方法注册自定义的消息类型，而不要使用此方法。
 */
- (void)registerMessageType:(Class)messageClass;

#pragma mark 消息发送

/*!
 发送消息
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode:发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
 
 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用此方法发送。
 
 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个RCFileMessage对象，
 并将RCFileMessage中的fileUrl字段设置为上传成功的URL地址，然后使用此方法发送。
 
 @warning 如果您使用，可以使用此方法发送消息；
 如果您使用MessageKit，请使用RCIM中的同名方法发送消息，否则不会自动更新UI。
 */
- (CTMSGMessage *)sendMessage:(CTMSGConversationType)conversationType
                     targetId:(NSString *)targetId
                      content:(CTMSGMessageContent *)content
                  pushContent:(nullable NSString *)pushContent
                     pushData:(nullable NSString *)pushData
                      success:(void (^ _Nullable )(long messageId))successBlock
                        error:(void (^ _Nullable )(CTMSGErrorCode nErrorCode, long messageId))errorBlock;

/*!
 发送媒体消息（图片消息或文件消息）
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是pushContent，用于显示；二是pushData，用于携带不显示的数据。
 
 SDK内置的消息类型，如果您将pushContent和pushData置为nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置pushContent和pushData来定义推送内容，否则将不会进行远程推送。
 
 如果您需要上传图片到自己的服务器，需要构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用CTMSGIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 如果您需要上传文件到自己的服务器，构建一个RCFileMessage对象，
 并将RCFileMessage中的fileUrl字段设置为上传成功的URL地址，然后使用CTMSGIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 @warning 如果您使用，可以使用此方法发送媒体消息；
 如果您使用MessageKit，请使用RCIM中的同名方法发送媒体消息，否则不会自动更新UI。
 */
- (CTMSGMessage *)sendMediaMessage:(CTMSGConversationType)conversationType
                          targetId:(NSString *)targetId
                           content:(CTMSGMessageContent *)content
                       pushContent:(nullable NSString *)pushContent
                          pushData:(nullable NSString *)pushData
                          progress:(void (^ _Nullable )(int progress, long messageId))progressBlock
                           success:(void (^ _Nullable )(long messageId))successBlock
                             error:(void (^ _Nullable )(CTMSGErrorCode errorCode, long messageId))errorBlock
                            cancel:(void (^ _Nullable )(long messageId))cancelBlock;

/*!
 发送媒体消息(上传图片或文件等媒体信息到指定的服务器)
 
 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的目标会话ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param uploadPrepareBlock  媒体文件上传进度更新的MessageKit监听
 [uploadListener:当前的发送进度监听，SDK通过此监听更新MessageKit UI]
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的ID]
 @return                    发送的消息实体
 
 @discussion 此方法仅用于MessageKit。
 如果您需要上传图片到自己的服务器并使用，构建一个RCImageMessage对象，
 并将RCImageMessage中的imageUrl字段设置为上传成功的URL地址，然后使用CTMSGIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 如果您需要上传文件到自己的服务器并使用，构建一个RCFileMessage对象，
 并将RCFileMessage中的fileUrl字段设置为上传成功的URL地址，然后使用CTMSGIMClient的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 */
- (CTMSGMessage *)sendMediaMessage:(CTMSGConversationType)conversationType
                          targetId:(NSString *)targetId
                           content:(CTMSGMessageContent *)content
                       pushContent:(nullable NSString *)pushContent
                          pushData:(nullable NSString *)pushData
                     uploadPrepare:(void (^ _Nullable )(CTMSGUploadMediaStatusListener *uploadListener))uploadPrepareBlock
                          progress:(void (^ _Nullable )(int progress, long messageId))progressBlock
                           success:(void (^ _Nullable )(long messageId))successBlock
                             error:(void (^ _Nullable )(CTMSGErrorCode errorCode, long messageId))errorBlock
                            cancel:(void (^ _Nullable )(long messageId))cancelBlock;

/*!
 取消发送中的媒体信息
 
 @param messageId           媒体消息的messageId
 
 @return YES表示取消成功，NO表示取消失败，即已经发送成功或者消息不存在。
 */
- (BOOL)cancelSendMediaMessage:(long)messageId;

/*!
 插入向外发送的消息
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @return                    插入的消息实体
 
 @discussion 此方法不支持聊天室的会话类型。
 */
- (CTMSGMessage *)insertOutgoingMessage:(CTMSGConversationType)conversationType
                               targetId:(NSString *)targetId
                             sentStatus:(CTMSGSentStatus)sentStatus
                                content:(CTMSGMessageContent *)content;
/*!
 插入向外发送的、指定时间的消息（此方法如果 sentTime 有问题会影响消息排序，慎用！！）
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @param sentTime            消息发送的Unix时间戳，单位为毫秒（传 0 会按照本地时间插入）
 @return                    插入的消息实体
 
 @discussion 此方法不支持聊天室的会话类型。如果sentTime<=0，则被忽略，会以插入时的时间为准。
 */
- (CTMSGMessage *)insertOutgoingMessage:(CTMSGConversationType)conversationType
                               targetId:(NSString *)targetId
                             sentStatus:(CTMSGSentStatus)sentStatus
                                content:(CTMSGMessageContent *)content
                               sentTime:(long long)sentTime;

/*!
 插入接收的消息
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param senderUserId        发送者ID
 @param receivedStatus      接收状态
 @param content             消息的内容
 @return                    插入的消息实体
 
 @discussion 此方法不支持聊天室的会话类型。
 */
- (CTMSGMessage *)insertIncomingMessage:(CTMSGConversationType)conversationType
                               targetId:(NSString *)targetId
                           senderUserId:(NSString *)senderUserId
                         receivedStatus:(CTMSGReceivedStatus)receivedStatus
                                content:(CTMSGMessageContent *)content NS_UNAVAILABLE;

/*!
 插入接收的消息（此方法如果 sentTime 有问题会影响消息排序，慎用！！）
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param senderUserId        发送者ID
 @param receivedStatus      接收状态
 @param content             消息的内容
 @param sentTime            消息发送的Unix时间戳，单位为毫秒 （传 0 会按照本地时间插入）
 @return                    插入的消息实体
 
 @discussion 此方法不支持聊天室的会话类型。
 */
- (CTMSGMessage *)insertIncomingMessage:(CTMSGConversationType)conversationType
                               targetId:(NSString *)targetId
                           senderUserId:(NSString *)senderUserId
                         receivedStatus:(CTMSGReceivedStatus)receivedStatus
                                content:(CTMSGMessageContent *)content
                               sentTime:(long long)sentTime NS_UNAVAILABLE;

/*!
 下载消息内容中的媒体信息
 
 @param conversationType    消息的会话类型
 @param targetId            消息的目标会话ID
 @param mediaType           消息内容中的多媒体文件类型，目前仅支持图片
 @param mediaUrl            多媒体文件的网络URL
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0
 <= progress <= 100]
 @param successBlock        下载成功的回调
 [mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 */
- (void)downloadMediaFile:(CTMSGConversationType)conversationType
                 targetId:(NSString *)targetId
                mediaType:(CTMSGMediaType)mediaType
                 mediaUrl:(NSString *)mediaUrl
                 progress:(void (^)(int progress))progressBlock
                  success:(void (^)(NSString *mediaPath))successBlock
                    error:(void (^)(CTMSGErrorCode errorCode))errorBlock;

/*!
 下载消息内容中的媒体信息
 
 @param messageId           媒体消息的messageId
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0 <= progress <= 100]
 @param successBlock        下载成功的回调[mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调
 */
- (void)downloadMediaMessage:(long)messageId
                    progress:(void (^)(int progress))progressBlock
                     success:(void (^)(NSString *mediaPath))successBlock
                       error:(void (^)(CTMSGErrorCode errorCode))errorBlock
                      cancel:(void (^)(void))cancelBlock;

/*!
 取消下载中的媒体信息
 
 @param messageId 媒体消息的messageId
 
 @return YES表示取消成功，NO表示取消失败，即已经下载完成或者消息不存在。
 */
- (BOOL)cancelDownloadMediaMessage:(long)messageId;

#pragma mark 消息阅读回执
/*!
 @const 收到已读回执的Notification
 
 @discussion 收到消息已读回执之后，会分发此通知。
 
 Notification的object为nil，userInfo为NSDictionary对象，
 其中key值分别为@"cType"、@"tId"、@"messageTime",
 对应的value为会话类型的NSNumber对象、会话的targetId、已阅读的最后一条消息的sendTime。
 如：
 NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
 NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
 NSString *targetId = [notification.userInfo objectForKey:@"tId"];
 NSString *fromUserId = [notification.userInfo objectForKey:@"fId"];
 
 收到这个消息之后可以更新这个会话中messageTime以前的消息UI为已读（底层数据库消息状态已经改为已读）。
 
 @warning 目前仅支持单聊。
 */
FOUNDATION_EXPORT NSString *const CTMSGLibDispatchReadReceiptNotification NS_UNAVAILABLE;

/*!
 同步会话阅读状态
 
 @param conversationType 会话类型
 @param targetId         会话ID
 @param timestamp        已经阅读的最后一条消息的Unix时间戳(毫秒)
 @param successBlock     同步成功的回调
 @param errorBlock       同步失败的回调[nErrorCode: 失败的错误码]
 */
- (void)syncConversationReadStatus:(CTMSGConversationType)conversationType
                          targetId:(NSString *)targetId
                              time:(long long)timestamp
                           success:(void (^)(void))successBlock
                             error:(void (^)(CTMSGErrorCode nErrorCode))errorBlock NS_UNAVAILABLE;

/*!
 撤回消息
 
 @param message      需要撤回的消息
 @param pushContent 当下发 push 消息时，在通知栏里会显示这个字段。如果不设置该字段，无法接受到 push 推送。
 @param successBlock 撤回成功的回调 [messageId:撤回的消息ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 
 @warning 仅支持单聊、群组和讨论组。
 */
- (void)recallMessage:(CTMSGMessage *)message
          pushContent:(NSString *)pushContent
              success:(void (^)(long messageId))successBlock
                error:(void (^)(CTMSGErrorCode errorcode))errorBlock NS_UNAVAILABLE;

/*!
 撤回消息
 
 @param message      需要撤回的消息
 @param successBlock 撤回成功的回调 [messageId:撤回的消息ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 */
- (void)recallMessage:(CTMSGMessage *)message
              success:(void (^)(long messageId))successBlock
                error:(void (^)(CTMSGErrorCode errorcode))errorBlock NS_UNAVAILABLE;

#pragma mark - 消息操作

/*!
 获取某个会话中指定数量的最新消息实体
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param count               需要获取的消息数量
 @return                    消息实体CTMSGMessage对象列表
 
 @discussion
 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 */
- (NSArray<CTMSGMessage *> *)getLatestMessages:(CTMSGConversationType)conversationType targetId:(NSString *)targetId count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的最新消息实体
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param oldestMessageId     截止的消息ID
 @param count               需要获取的消息数量
 @return                    消息实体CTMSGMessage对象列表
 
 @discussion
 此方法会获取该会话中，oldestMessageId之前的、指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含oldestMessageId对应那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId为10，count为2，会返回messageId为9和8的CTMSGMessage对象列表。
 */
- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                oldestMessageId:(long)oldestMessageId
                                          count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的、指定消息类型的最新消息实体
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param objectName          消息内容的类型名
 @param oldestMessageId     截止的消息ID
 @param count               需要获取的消息数量
 @return                    消息实体CTMSGMessage对象列表
 
 @discussion
 此方法会获取该会话中，oldestMessageId之前的、指定数量和消息类型的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含oldestMessageId对应的那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId为10，count为2，会返回messageId为9和8的CTMSGMessage对象列表。
 */
- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                     objectName:(NSString *)objectName
                                oldestMessageId:(long)oldestMessageId
                                          count:(int)count NS_UNAVAILABLE;

/*!
 获取会话中，从指定消息之前、指定数量的、指定消息类型、可以向前或向后查找的最新消息实体
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param objectName          消息内容的类型名
 @param baseMessageId       当前的消息ID
 @param isForward           查询方向 true为向前，false为向后
 @param count               需要获取的消息数量
 @return                    消息实体CTMSGMessage对象列表
 
 @discussion
 此方法会获取该会话中，baseMessageId之前或之后的、指定数量、消息类型和查询方向的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含baseMessageId对应的那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 */
- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                     objectName:(NSString *)objectName
                                  baseMessageId:(long)baseMessageId
                                      isForward:(BOOL)isForward
                                          count:(int)count NS_UNAVAILABLE;

/*!
 在会话中搜索指定消息的前 beforeCount 数量和后 afterCount
 数量的消息。返回的消息列表中会包含指定的消息。消息列表时间顺序从旧到新。
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param sentTime            消息的发送时间
 @param beforeCount         指定消息的前部分消息数量
 @param afterCount          指定消息的后部分消息数量
 @return                    消息实体CTMSGMessage对象列表
 
 @discussion
 获取该会话的这条消息及这条消息前 beforeCount 条和后 afterCount 条消息,如前后消息不够则返回实际数量的消息。
 */
- (NSArray<CTMSGMessage *> *)getHistoryMessages:(CTMSGConversationType)conversationType
                                       targetId:(NSString *)targetId
                                       sentTime:(long long)sentTime
                                    beforeCount:(int)beforeCount
                                     afterCount:(int)afterCount NS_UNAVAILABLE;

/*!
 从服务器端获取之前的历史消息
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param recordTime          截止的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 20
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]
 
 @discussion
 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime应传入最早的消息的发送时间戳，count传入1~20之间的数值。
 */
- (void)getRemoteHistoryMessages:(CTMSGConversationType)conversationType
                        targetId:(NSString *)targetId
                      recordTime:(long long)recordTime
                           count:(int)count
                         success:(void (^)(NSArray *messages))successBlock
                           error:(void (^)(CTMSGErrorCode status))errorBlock;

- (void)getRemoteHistoryMessagesAndOtherInfo:(CTMSGConversationType)conversationType
                                    targetId:(NSString *)targetId
                                  recordTime:(long long)recordTime
                                       count:(int)count
                                     success:(void (^)(NSArray *messages, id otherInfo))successBlock
                                       error:(void (^)(CTMSGErrorCode status))errorBlock;

/*!
 获取消息的发送时间（Unix时间戳、毫秒）
 
 @param messageId   消息ID
 @return            消息的发送时间（Unix时间戳、毫秒）
 */
- (long long)getMessageSendTime:(long)messageId;

/*!
 通过messageId获取消息实体
 
 @param messageId   消息ID（数据库索引唯一值）
 @return            通过消息ID获取到的消息实体，当获取失败的时候，会返回nil。
 */
- (CTMSGMessage *)getMessage:(long)messageId;

/*!
 通过全局唯一ID获取消息实体
 
 @param messageUId   全局唯一ID（服务器消息唯一ID）
 @return 通过全局唯一ID获取到的消息实体，当获取失败的时候，会返回nil。
 */
- (CTMSGMessage *)getMessageByUId:(NSString *)messageUId;

/*!
 删除消息
 
 @param messageIds  消息ID的列表
 @return            是否删除成功
 */
- (BOOL)deleteMessages:(NSArray<NSString*> *)messageIds;

/*!
 删除某个会话中的所有消息
 
 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @param successBlock        成功的回调
 @param errorBlock          失败的回调
 
 @discussion 此方法删除数据库中该会话的消息记录，同时会整理压缩数据库，减少占用空间
 */
- (void)deleteMessages:(CTMSGConversationType)conversationType
              targetId:(NSString *)targetId
               success:(void (^)(void))successBlock
                 error:(void (^)(CTMSGErrorCode status))errorBlock;

/*!
 删除某个会话中的所有消息
 
 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @return                    是否删除成功
 */
- (BOOL)clearMessages:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

/*!
 设置消息的附加信息
 
 @param messageId   消息ID
 @param value       附加信息
 @return            是否设置成功
 */
- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value NS_UNAVAILABLE;

/*!
 设置消息的接收状态
 
 @param messageId       消息ID
 @param receivedStatus  消息的接收状态
 @return                是否设置成功
 */
- (BOOL)setMessageReceivedStatus:(CTMSGReceivedStatus)receivedStatus messageId:(long)messageId NS_UNAVAILABLE;

/*!
 设置消息的发送状态
 
 @param messageId       消息ID
 @param sentStatus      消息的发送状态
 @return                是否设置成功
 */
- (BOOL)setMessageSentStatus:(CTMSGSentStatus)sentStatus messageId:(long)messageId NS_UNAVAILABLE;

#pragma mark - 会话列表操作
/*!
 获取所有会话列表
 @return                        会话CTMSGConversation的列表
 
 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 */
- (NSArray<CTMSGConversation *> *)getConversationList;

/*!
 获取会话列表
 
 @param conversationTypeList 会话类型的数组(需要将CTMSGConversationType转为NSNumber构建Array)
 @return                        会话CTMSGConversation的列表
 
 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 */
- (NSArray<CTMSGConversation *> *)getConversationList:(nullable NSArray *)conversationTypeList;

/*!
 分页获取会话列表
 
 @param conversationTypeList 会话类型的数组(需要将CTMSGConversationType转为NSNumber构建Array)
 @param count                获取的数量
 @param startTime            会话的时间戳（获取这个时间戳之前的会话列表，0表示从最新开始获取）
 @return                     会话CTMSGConversation的列表
 
 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 */
- (NSArray<CTMSGConversation *> *)getConversationList:(nullable NSArray *)conversationTypeList count:(int)count startTime:(long long)startTime;


/*!
 获取某个类型的会话中所有的未读消息数
 
 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有的未读消息数
 */
- (int)getUnreadCount:(NSArray *)conversationTypes;

/*!
 获取单个会话数据
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @return                    会话的对象
 */
- (CTMSGConversation *)getConversation:(CTMSGConversationType)conversationType targetId:(NSString *)targetId NS_UNAVAILABLE;

/*!
 获取会话中的消息数量
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @return                    会话中的消息数量
 
 @discussion -1表示获取消息数量出错。
 */
- (int)getMessageCount:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

/*!
 删除指定类型的会话
 
 @param conversationTypeList 会话类型的数组(需要将CTMSGConversationType转为NSNumber构建Array)
 @return                        是否删除成功
 */
- (BOOL)clearConversations:(NSArray *)conversationTypeList;

/*!
 从本地存储中删除会话
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @return                    是否删除成功
 
 @discussion 此方法会从本地存储中删除该会话，但是不会删除会话中的消息。
 */
- (BOOL)removeConversation:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

/*!
 设置会话的置顶状态
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param isTop               是否置顶
 @return                    设置是否成功
 */
- (BOOL)setConversationToTop:(CTMSGConversationType)conversationType targetId:(NSString *)targetId isTop:(BOOL)isTop;

/*!
 获取置顶的会话列表
 
 @param conversationTypeList 会话类型的数组(需要将CTMSGConversationType转为NSNumber构建Array)
 @return                     置顶的会话CTMSGConversation的列表
 
 @discussion 此方法会从本地数据库中，读取置顶的会话列表。
 */
- (NSArray<CTMSGConversation *> *)getTopConversationList:(NSArray *)conversationTypeList NS_UNAVAILABLE;

#pragma mark 会话中的草稿操作
/*!
 获取会话中的草稿信息
 
 @param conversationType    会话类型
 @param targetId            会话目标ID
 @return                    该会话中的草稿
 */
- (NSString *)getTextMessageDraft:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

/*!
 保存草稿信息
 
 @param conversationType    会话类型
 @param targetId            会话目标ID
 @param content             草稿信息
 @return                    是否保存成功
 */
- (BOOL)saveTextMessageDraft:(CTMSGConversationType)conversationType
                    targetId:(NSString *)targetId
                     content:(NSString *)content;

/*!
 删除会话中的草稿信息
 
 @param conversationType    会话类型
 @param targetId            会话目标ID
 @return                    是否删除成功
 */
- (BOOL)clearTextMessageDraft:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

#pragma mark 未读消息数

/*!
 获取所有的未读消息数
 
 @return    所有的未读消息数
 */
- (int)getTotalUnreadCount;

/*!
 获取某个会话内的未读消息数
 
 @param conversationType    会话类型
 @param targetId            会话目标ID
 @return                    该会话内的未读消息数
 */
- (int)getUnreadCount:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

/*!
 获取某些会话的总未读消息数
 
 @param conversations       会话列表 （CTMSGConversation 对象只需要 conversationType 和 targetId ）
 @return                    传入会话列表的未读消息数
 */
- (int)getTotalUnreadCount:(NSArray<CTMSGConversation *> *)conversations NS_UNAVAILABLE;

/*!
 获取某个类型的会话中所有未读的被@的消息数
 
 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有未读的被@的消息数
 */
- (int)getUnreadMentionedCount:(NSArray *)conversationTypes NS_UNAVAILABLE;

/*!
 清除某个会话中的未读消息数
 
 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @return                    是否清除成功
 */
- (BOOL)clearMessagesUnreadStatus:(CTMSGConversationType)conversationType targetId:(NSString *)targetId;

/*!
 清除某个会话中的未读消息数
 
 @param conversationType    会话类型，不支持聊天室
 @param targetId            目标会话ID
 @param timestamp           该会话已阅读的最后一条消息的发送时间戳
 @return                    是否清除成功
 */
- (BOOL)clearMessagesUnreadStatus:(CTMSGConversationType)conversationType
                         targetId:(NSString *)targetId
                             time:(long long)timestamp NS_UNAVAILABLE;

#pragma mark 会话的消息提醒

/*!
 设置会话的消息提醒状态
 
 @param conversationType            会话类型
 @param targetId                    目标会话ID
 @param isBlocked                   是否屏蔽消息提醒
 @param successBlock                设置成功的回调
 [nStatus:会话设置的消息提醒状态]
 @param errorBlock                  设置失败的回调 [status:设置失败的错误码]
 
 @discussion
 如果您使用，此方法会屏蔽该会话的远程推送；如果您使用MessageKit，此方法会屏蔽该会话的所有提醒（远程推送、本地通知、前台提示音）,该接口不支持聊天室。
 */
- (void)setConversationNotificationStatus:(CTMSGConversationType)conversationType
                                 targetId:(NSString *)targetId
                                isBlocked:(BOOL)isBlocked
                                  success:(void (^)(CTMSGConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(CTMSGErrorCode status))errorBlock NS_UNAVAILABLE;

/*!
 查询会话的消息提醒状态
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param successBlock        查询成功的回调 [nStatus:会话设置的消息提醒状态]
 @param errorBlock          查询失败的回调 [status:设置失败的错误码]
 */
- (void)getConversationNotificationStatus:(CTMSGConversationType)conversationType
                                 targetId:(NSString *)targetId
                                  success:(void (^)(CTMSGConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(CTMSGErrorCode status))errorBlock NS_UNAVAILABLE;

/*!
 获取屏蔽消息提醒的会话列表
 
 @param conversationTypeList 会话类型的数组(需要将CTMSGConversationType转为NSNumber构建Array)
 @return                     屏蔽消息提醒的会话CTMSGConversation的列表
 
 @discussion 此方法会从本地数据库中，读取屏蔽消息提醒的会话列表。
 */
- (NSArray<CTMSGConversation *> *)getBlockedConversationList:(NSArray *)conversationTypeList NS_UNAVAILABLE;

#pragma mark 全局消息提醒

/*!
 全局屏蔽某个时间段的消息提醒
 
 @param startTime       开始屏蔽消息提醒的时间，格式为HH:MM:SS
 @param spanMins        需要屏蔽消息提醒的分钟数，0 < spanMins < 1440
 @param successBlock    屏蔽成功的回调
 @param errorBlock      屏蔽失败的回调 [status:屏蔽失败的错误码]
 
 @discussion 此方法设置的屏蔽时间会在每天该时间段时生效。
 如果您使用，此方法会屏蔽该会话在该时间段的远程推送；如果您使用MessageKit，此方法会屏蔽该会话在该时间段的所有提醒（远程推送、本地通知、前台提示音）。
 */
- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(int)spanMins
                          success:(void (^)(void))successBlock
                            error:(void (^)(CTMSGErrorCode status))errorBlock NS_UNAVAILABLE;



#pragma mark - 黑名单

/*!
 将某个用户加入黑名单
 
 @param userId          需要加入黑名单的用户ID
 @param successBlock    加入黑名单成功的回调
 @param errorBlock      加入黑名单失败的回调 [status:失败的错误码]
 */
- (void)addToBlacklist:(NSString *)userId
               success:(void (^)(void))successBlock
                 error:(void (^)(CTMSGErrorCode status))errorBlock;

/*!
 将某个用户移出黑名单
 
 @param userId          需要移出黑名单的用户ID
 @param successBlock    移出黑名单成功的回调
 @param errorBlock      移出黑名单失败的回调[status:失败的错误码]
 */
- (void)removeFromBlacklist:(NSString *)userId
                    success:(void (^)(void))successBlock
                      error:(void (^)(CTMSGErrorCode status))errorBlock;

/*!
 查询某个用户是否已经在黑名单中
 
 @param userId          需要查询的用户ID
 @param successBlock    查询成功的回调
 [bizStatus:该用户是否在黑名单中。0表示已经在黑名单中，101表示不在黑名单中]
 @param errorBlock      查询失败的回调 [status:失败的错误码]
 */
- (void)getBlacklistStatus:(NSString *)userId
                   success:(void (^)(int bizStatus))successBlock
                     error:(void (^)(CTMSGErrorCode status))errorBlock;

/*!
 查询已经设置的黑名单列表
 
 @param successBlock    查询成功的回调
 [blockUserIds:已经设置的黑名单中的用户ID列表]
 @param errorBlock      查询失败的回调 [status:失败的错误码]
 */
- (void)getBlacklist:(void (^)(NSArray *blockUserIds))successBlock error:(void (^)(CTMSGErrorCode status))errorBlock NS_UNAVAILABLE;

#pragma mark - 推送业务数据统计


/*!
 获取点击的启动事件中，推送服务的扩展字段
 
 @param launchOptions   App的启动附加信息
 @return 收到的推送服务的扩展字段，nil表示该启动事件不包含来自的推送服务
 
 @discussion 此方法仅用于获取推送服务的扩展字段。
 */
- (NSDictionary *)getPushExtraFromLaunchOptions:(NSDictionary *)launchOptions;

/*!
 获取点击的远程推送中，推送服务的扩展字段
 
 @param userInfo    远程推送的内容
 @return 收到的推送服务的扩展字段，nil表示该远程推送不包含来自的推送服务
 
 @discussion 此方法仅用于获取推送服务的扩展字段。
 */
- (NSDictionary *)getPushExtraFromRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - 工具类方法

/*!
 获取当前 SDK的版本号
 
 @return 当前 SDK的版本号，如: @"2.0.0"
 */
- (NSString *)getKITVersion;

/*!
 获取当前手机与服务器的时间差
 
 @return 时间差
 */
- (long long)getDeltaTime;

/*!
 将AMR格式的音频数据转化为WAV格式的音频数据，数据开头携带WAVE文件头
 
 @param data    AMR格式的音频数据，必须是AMR-NB的格式
 @return        WAV格式的音频数据
 */
- (NSData *)decodeAMRToWAVE:(NSData *)data;

/*!
 将AMR格式的音频数据转化为WAV格式的音频数据，数据开头不携带WAVE文件头
 
 @param data    AMR格式的音频数据，必须是AMR-NB的格式
 @return        WAV格式的音频数据
 */
- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data;

/*!
 将WAV格式的音频数据转化为AMR格式的音频数据（8KHz采样）
 
 @param data            WAV格式的音频数据
 @param nChannels       声道数
 @param nBitsPerSample  采样位数（精度）
 @return                AMR-NB格式的音频数据
 
 @discussion
 此方法为工具类方法，您可以使用此方法将任意WAV音频转换为AMR-NB格式的音频。
 
 @warning
 如果您想和SDK自带的语音消息保持一致和互通，考虑到跨平台和传输的原因，SDK对于WAV音频有所限制.
 具体可以参考RCVoiceMessage中的音频参数说明(nChannels为1，nBitsPerSample为16)。
 */
- (NSData *)encodeWAVEToAMR:(NSData *)data channel:(int)nChannels nBitsPerSample:(int)nBitsPerSample;

#pragma mark - NS_UNAVAILABLE

/*!
 发送某个会话中消息阅读的回执
 
 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param timestamp           该会话中已阅读的最后一条消息的发送时间戳
 @param successBlock        发送成功的回调
 @param errorBlock          发送失败的回调[nErrorCode: 失败的错误码]
 
 @discussion 此接口只支持单聊, 如果使用Lib 可以注册监听
 RCLibDispatchReadReceiptNotification 通知,使用kit 直接设置RCIM.h
 中的enabledReadReceiptConversationTypeList。
 
 @warning 目前仅支持单聊。
 */
- (void)sendReadReceiptMessage:(CTMSGConversationType)conversationType
                      targetId:(NSString *)targetId
                          time:(long long)timestamp
                       success:(void (^)(void))successBlock
                         error:(void (^)(CTMSGErrorCode nErrorCode))errorBlock NS_UNAVAILABLE;

/*!
 请求消息阅读回执
 
 @param message      要求阅读回执的消息
 @param successBlock 请求成功的回调
 @param errorBlock   请求失败的回调[nErrorCode: 失败的错误码]
 
 @discussion 通过此接口，可以要求阅读了这条消息的用户发送阅读回执。
 */
- (void)sendReadReceiptRequest:(CTMSGMessage *)message
                       success:(void (^)(void))successBlock
                         error:(void (^)(CTMSGErrorCode nErrorCode))errorBlock NS_UNAVAILABLE;

/*!
 发送阅读回执
 
 @param conversationType 会话类型
 @param targetId         会话ID
 @param messageList      已经阅读了的消息列表
 @param successBlock     发送成功的回调
 @param errorBlock       发送失败的回调[nErrorCode: 失败的错误码]
 
 @discussion 当用户阅读了需要阅读回执的消息，可以通过此接口发送阅读回执，消息的发送方即可直接知道那些人已经阅读。
 */
- (void)sendReadReceiptResponse:(CTMSGConversationType)conversationType
                       targetId:(NSString *)targetId
                    messageList:(NSArray<CTMSGMessage *> *)messageList
                        success:(void (^)(void))successBlock
                          error:(void (^)(CTMSGErrorCode nErrorCode))errorBlock NS_UNAVAILABLE;

/*!
 设置导航服务器和上传文件服务器信息
 
 @param naviServer     导航服务器地址，具体的格式参考下面的说明
 @param fileServer     文件服务器地址，具体的格式参考下面的说明
 @return               是否设置成功
 
 @warning 仅限独立数据中心使用，使用前必须先联系商务开通。必须在SDK init之前进行设置。
 @discussion
 naviServer必须为有效的服务器地址，fileServer如果想使用默认的，可以传nil。
 naviServer和fileServer的格式说明：
 1、如果使用https，则设置为https://cn.xxx.com:port或https://cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用443端口。
 2、如果使用http，则设置为cn.xxx.com:port或cn.xxx.com格式，其中域名部分也可以是IP，如果不指定端口，将默认使用80端口。
 */
- (BOOL)setServerInfo:(NSString *)naviServer fileServer:(NSString *)fileServer NS_UNAVAILABLE;

/*!
 删除已设置的全局时间段消息提醒屏蔽
 
 @param successBlock    删除屏蔽成功的回调
 @param errorBlock      删除屏蔽失败的回调 [status:失败的错误码]
 */
- (void)removeNotificationQuietHours:(void (^)(void))successBlock error:(void (^)(CTMSGErrorCode status))errorBlock NS_UNAVAILABLE;

/*!
 查询已设置的全局时间段消息提醒屏蔽
 
 @param successBlock    屏蔽成功的回调 [startTime:已设置的屏蔽开始时间,
 spansMin:已设置的屏蔽时间分钟数，0 < spansMin < 1440]
 @param errorBlock      查询失败的回调 [status:查询失败的错误码]
 */
- (void)getNotificationQuietHours:(void (^)(NSString *startTime, int spansMin))successBlock
                            error:(void (^)(CTMSGErrorCode status))errorBlock NS_UNAVAILABLE;


/*!
 向会话中发送正在输入的状态
 
 @param conversationType    会话类型
 @param targetId            会话目标ID
 @param objectName         正在输入的消息的类型名
 
 @discussion
 contentType为用户当前正在编辑的消息类型名，即CTMSGMessageContent中getObjectName的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。
 
 @warning 目前仅支持单聊。
 */
- (void)sendTypingStatus:(CTMSGConversationType)conversationType
                targetId:(NSString *)targetId
             contentType:(NSString *)objectName NS_UNAVAILABLE;
/*!
 获取Vendor token. 仅供第三方服务厂家使用。
 
 @param  successBlock 成功回调
 @param  errorBlock   失败回调
 */


/*!
 统计App启动的事件
 
 @param launchOptions   App的启动附加信息
 
 @discussion 此方法用于统计推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate的-application:didFinishLaunchingWithOptions:中，
 调用此方法并将launchOptions传入即可。
 */
- (void)recordLaunchOptionsEvent:(NSDictionary *)launchOptions NS_UNAVAILABLE;

/*!
 统计本地通知的事件
 
 @param notification   本体通知的内容
 
 @discussion 此方法用于统计推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate的-application:didReceiveLocalNotification:中，
 调用此方法并将launchOptions传入即可。
 */
- (void)recordLocalNotificationEvent:(UILocalNotification *)notification NS_UNAVAILABLE;

/*!
 统计远程推送的事件
 
 @param userInfo    远程推送的内容
 
 @discussion 此方法用于统计推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate的-application:didReceiveRemoteNotification:中，
 调用此方法并将launchOptions传入即可。
 */
- (void)recordRemoteNotificationEvent:(NSDictionary *)userInfo NS_UNAVAILABLE;
- (void)getVendorToken:(void (^)(NSString *vendorToken))successBlock error:(void (^)(CTMSGErrorCode nErrorCode))errorBlock NS_UNAVAILABLE;


//#pragma mark - 客服方法
///*!
// 发起客服聊天
//
// @param kefuId       客服ID
// @param csInfo       客服信息
// @param successBlock            发起客服会话成功的回调
// @param errorBlock              发起客服会话失败的回调 [errorCode:失败的错误码 errMsg:错误信息]
// @param modeTypeBlock           客服模式变化
// @param pullEvaluationBlock     客服请求评价
// @param selectGroupBlock        客服分组选择
// @param quitBlock 客服被动结束。如果主动调用stopCustomerService，则不会调用到该block
//
// @discussion
// 有些客服提供商可能会主动邀请评价，有些不会，所以用lib开发客服需要注意对pullEvaluationBlock的处理。在pullEvaluationBlock里应该弹出评价。如果pullEvaluationBlock没有被调用到，需要在结束客服时（之前之后都可以）弹出评价框并评价。如果客服有分组，selectGroupBlock会被回调，此时必须让用户选择分组然后调用selectCustomerServiceGroup:withGroupId:。
//
// @warning 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)startCustomerService:(NSString *)kefuId
//                        info:(CTMSGCustomerServiceInfo *)csInfo
//                   onSuccess:(void (^)(CTMSGCustomerServiceConfig *config))successBlock
//                     onError:(void (^)(int errorCode, NSString *errMsg))errorBlock
//                  onModeType:(void (^)(CTMSGCSModeType mode))modeTypeBlock
//            onPullEvaluation:(void (^)(NSString *dialogId))pullEvaluationBlock
//               onSelectGroup:(void (^)(NSArray<CTMSGCustomerServiceGroupItem *> *groupList))selectGroupBlock
//                      onQuit:(void (^)(NSString *quitMsg))quitBlock;

///*!
// 结束客服聊天
//
// @param kefuId       客服ID
//
// @discussion 此方法依赖startCustomerService方法，只有调用成功以后才有效。
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)stopCustomerService:(NSString *)kefuId;
//
///*!
// 选择客服分组模式
//
// @param kefuId       客服ID
// @param groupId       选择的客服分组id
// @discussion 此方法依赖startCustomerService方法，只有调用成功以后才有效。
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)selectCustomerServiceGroup:(NSString *)kefuId withGroupId:(NSString *)groupId;
//
///*!
// 切换客服模式
//
// @param kefuId       客服ID
//
// @discussion
// 此方法依赖startCustomerService方法，而且只有当前客服模式为机器人优先才可调用。
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)switchToHumanMode:(NSString *)kefuId;
//
///*!
// 评价机器人客服，用于对单条机器人应答的评价。
//
// @param kefuId                客服ID
// @param knownledgeId          知识点ID
// @param isRobotResolved       是否解决问题
// @param suggest                客户建议
//
// @discussion 此方法依赖startCustomerService方法。可在客服结束之前或之后调用。
// @discussion
// 有些客服服务商需要对机器人回答的词条进行评价，机器人回答的文本消息的extra带有{“robotEva”:”1”,
// “sid”:”xxx”}字段，当用户对这一条消息评价后调用本函数同步到服务器，knownledgedID为extra中的sid。若是离开会话触发的评价或者在加号扩展中主动触发的评价，knownledgedID填nil
//
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)evaluateCustomerService:(NSString *)kefuId
//                   knownledgeId:(NSString *)knownledgeId
//                     robotValue:(BOOL)isRobotResolved
//                        suggest:(NSString *)suggest;
//
///*!
// 评价人工客服。
//
// @param kefuId                客服ID
// @param dialogId              对话ID，客服请求评价的对话ID
// @param value                 分数，取值范围1-5
// @param suggest               客户建议
//
// @discussion 此方法依赖startCustomerService方法。可在客服结束之前或之后调用。
// @discussion
// 有些客服服务商会主动邀请评价，pullEvaluationBlock会被调用到，当评价完成后调用本函数同步到服务器，dialogId填pullEvaluationBlock返回的dialogId。若是离开会话触发的评价或者在加号扩展中主动触发的评价，dialogID为nil
//
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)evaluateCustomerService:(NSString *)kefuId
//                       dialogId:(NSString *)dialogId
//                     humanValue:(int)value
//                        suggest:(NSString *)suggest;
//
///*!
// 通用客服评价，不区分机器人人工
//
// @param kefuId                客服ID
// @param dialogId              对话ID，客服请求评价的对话ID
// @param value                 分数，取值范围1-5
// @param suggest               客户建议
// @param resolveStatus         解决状态，如果没有解决状态，这里可以随意赋值，SDK不会处理
// @discussion 此方法依赖startCustomerService方法。可在客服结束之前或之后调用。
// @discussion
// 有些客服服务商会主动邀请评价，pullEvaluationBlock会被调用到，当评价完成后调用本函数同步到服务器，dialogId填pullEvaluationBlock返回的dialogId。若是离开会话触发的评价或者在加号扩展中主动触发的评价，dialogID为nil
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)evaluateCustomerService:(NSString *)kefuId
//                       dialogId:(NSString *)dialogId
//                      starValue:(int)value
//                        suggest:(NSString *)suggest
//                  resolveStatus:(RCCSResolveStatus)resolveStatus;
//
///*!
// 客服留言
//
// @param kefuId                客服ID
// @param leaveMessageDic       客服留言信息字典，根据RCCSLeaveMessageItem中关于留言的配置存储对应的key-value
// @discussion 此方法依赖startCustomerService方法。可在客服结束之前或之后调用。
// @discussion 如果一些值没有，可以传nil
// @warning
// 如果你使用MessageKit，请不要使用此方法。CTMSGConversationViewController默认已经做了处理。
// */
//- (void)leaveMessageCustomerService:(NSString *)kefuId
//                    leaveMessageDic:(NSDictionary *)leaveMessageDic
//                            success:(void (^)(void))successBlock
//                            failure:(void (^)(void))failureBlock;
//#pragma mark - 搜索
//
///*!
// 根据关键字搜索指定会话中的消息
//
// @param conversationType 会话类型
// @param targetId         会话ID
// @param keyword          关键字
// @param count            最大的查询数量
// @param startTime        查询记录的起始时间（传 0 表示不限时间）
//
// @return 匹配的消息列表
// */
//- (NSArray<CTMSGMessage *> *)searchMessages:(CTMSGConversationType)conversationType
//                                   targetId:(NSString *)targetId
//                                    keyword:(NSString *)keyword
//                                      count:(int)count
//                                  startTime:(long long)startTime;
//
///*!
// 根据关键字搜索会话
//
// @param conversationTypeList 需要搜索的会话类型列表
// @param objectNameList       需要搜索的消息类型名列表(即每个消息类方法getObjectName的返回值)
// @param keyword              关键字
//
// @return 匹配的会话搜索结果列表
//
// @discussion 目前，SDK内置的文本消息、文件消息、图文消息支持搜索。
// 自定义的消息必须要实现CTMSGMessageContent的getSearchableWords接口才能进行搜索。
// */
//- (NSArray<CTMSGSearchConversationResult *> *)searchConversations:(NSArray<NSNumber *> *)conversationTypeList
//                                                   messageType:(NSArray<NSString *> *)objectNameList
//                                                       keyword:(NSString *)keyword;

#pragma mark - 历史消息
/**
 设置离线消息补偿时间（以天为单位）
 
 @param duration 离线消息补偿时间，范围【1~7天】
 @param  successBlock 成功回调
 @param  errorBlock   失败回调
 */
- (void)setOfflineMessageDuration:(int)duration
                          success:(void (^)(void))successBlock
                          failure:(void (^)(CTMSGErrorCode nErrorCode))errorBlock NS_UNAVAILABLE;

/**
 获取离线消息补偿时间 （以天为单位）
 
 @return 离线消息补偿时间
 */
- (int)getOfflineMessageDuration NS_UNAVAILABLE;


- (void)receiveTestMessage:(CTMSGMessage *)message;

@end

NS_ASSUME_NONNULL_END
