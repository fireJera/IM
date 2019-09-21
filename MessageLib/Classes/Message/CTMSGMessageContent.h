//
//  CTMSGMessageContent.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMSGEnumDefine.h"

@class CTMSGUserInfo, CTMSGMentionedInfo;

NS_ASSUME_NONNULL_BEGIN

/*!
 消息内容的编解码协议
 
 @discussion 用于标示消息内容的类型，进行消息的编码和解码。
 所有自定义消息必须实现此协议，否则将无法正常传输和使用。
 */
@protocol CTMSGMessageCoding <NSObject>
@required

/*!
 将消息内容序列化，编码成为可传输的json数据
 
 @discussion
 消息内容通过此方法，将消息中的所有数据，编码成为json数据，返回的json数据将用于网络传输。
 */
- (NSData *)encode;

- (NSDictionary *)netSendParameters;

/*!
 将json数据的内容反序列化，解码生成可用的消息内容
 
 @param data    消息中的原始json数据
 
 @discussion
 网络传输的json数据，会通过此方法解码，获取消息内容中的所有数据，生成有效的消息内容。
 */
- (void)decodeWithData:(NSData *)data;

/*!
 返回消息的类型名
 
 @return 消息的类型名
 
 @discussion 您定义的消息类型名，需要在各个平台上保持一致，以保证消息互通。
 
 @warning 请勿使用@"CTMSG:"开头的类型名，以免和SDK默认的消息名称冲突
 */
+ (NSString *)getObjectName;
+ (NSString *)getNetObjectName;

/*!
 返回可搜索的关键内容列表
 
 @return 返回可搜索的关键内容列表
 
 @discussion 这里返回的关键内容列表将用于消息搜索，自定义消息必须要实现此接口才能进行搜索。
 */
- (NSArray<NSString *> *)getSearchableWords;
@end

/*!
 消息内容的存储协议
 
 @discussion 用于确定消息内容的存储策略。
 所有自定义消息必须实现此协议，否则将无法正常存储和使用。
 */
@protocol CTMSGMessagePersistentCompatible <NSObject>
@required

/*!
 返回消息的存储策略
 
 @return 消息的存储策略
 
 @discussion 指明此消息类型在本地是否存储、是否计入未读消息数。
 */
+ (CTMSGMessagePersistent)persistentFlag;
@end

/*!
 消息内容摘要的协议
 
 @discussion 用于在会话列表和本地通知中显示消息的摘要。
 */
@protocol CTMSGMessageContentView
@optional

/*!
 返回在会话列表和本地通知中显示的消息内容摘要
 
 @return 会话列表和本地通知中显示的消息内容摘要
 
 @discussion
 如果您使用MessageKit，当会话的最后一条消息为自定义消息时，需要通过此方法获取在会话列表展现的内容摘要；
 当App在后台收到消息时，需要通过此方法获取在本地通知中展现的内容摘要。
 */
- (NSString *)conversationDigest;

@end

/*!
 消息内容的基类
 
 @discussion 此类为消息实体类CTMSGMessage中的消息内容content的基类。
 所有的消息内容均为此类的子类，包括SDK自带的消息（如CTMSGTextMessage、CTMSGImageMessage等）和用户自定义的消息。
 所有的自定义消息必须继承此类，并实现CTMSGMessageCoding和CTMSGMessagePersistentCompatible、CTMSGMessageContentView协议。
 */

@interface CTMSGMessageContent : NSObject <CTMSGMessageCoding, CTMSGMessagePersistentCompatible, CTMSGMessageContentView>

/*!
 消息内容中携带的发送者的用户信息
 
 @discussion
 如果您使用MessageKit，可以通过CTMSGIM的enableMessageAttachUserInfo属性设置在每次发送消息中携带发送者的用户信息。
 */
@property(nonatomic, strong) CTMSGUserInfo *senderUserInfo;

@property(nonatomic, strong) NSDictionary *extraPara;
/*!
 消息中的@提醒信息
 */
@property(nonatomic, strong) CTMSGMentionedInfo *mentionedInfo NS_UNAVAILABLE;

//@property (nonatomic, assign) BOOL isLock;
//@property (nonatomic, copy) NSString * lockNote;            // lockMsgTxt
//@property (nonatomic, copy) NSString * bottomLockNote;      // lockTxt
//@property (nonatomic, copy) NSString * lockPostData;        // lockPostData
//@property (nonatomic, copy) NSString * lockURL;             // lockUrl

/*!
 将消息内容中携带的用户信息解码
 
 @param dictionary 用户信息的Dictionary
 */
- (void)decodeUserInfo:(NSDictionary *)dictionary;

/*!
 将消息内容中携带的@提醒信息解码
 
 @param dictionary @提醒信息的Dictionary
 */
- (void)decodeMentionedInfo:(NSDictionary *)dictionary NS_UNAVAILABLE;

/*!
 消息内容的原始json数据
 
 @discussion 此字段存放消息内容中未编码的json数据。
 SDK内置的消息，如果消息解码失败，默认会将消息的内容存放到此字段；如果编码和解码正常，此字段会置为nil。
 */
@property(nonatomic, strong, setter=setRawJSONData:) NSData *rawJSONData;

@end

NS_ASSUME_NONNULL_END
