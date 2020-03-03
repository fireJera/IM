//
//  CTMSGRichContentMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CTMSGRichContentMessageTypeIdentifier;
/*!
 图文消息的类型名
 */
/*!
 图文消息类
 
 @discussion 图文消息类，此消息会进行存储并计入未读消息数。
 */
@interface CTMSGRichContentMessage : CTMSGMessageContent <NSCoding>

/*!
 图文消息的标题
 */
@property(nonatomic, strong) NSString *title;

/*!
 图文消息的内容摘要
 */
@property(nonatomic, strong) NSString *digest;

/*!
 图文消息图片URL
 */
@property(nonatomic, strong) NSString *imageURL;

/*!
 图文消息中包含的需要跳转到的URL
 */
@property(nonatomic, strong) NSString *url;

/*!
 图文消息的扩展信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化图文消息
 
 @param title       图文消息的标题
 @param digest      图文消息的内容摘要
 @param imageURL    图文消息的图片URL
 @param extra       图文消息的扩展信息
 @return            图文消息对象
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                           extra:(NSString *)extra;

/*!
 初始化图文消息
 
 @param title       图文消息的标题
 @param digest      图文消息的内容摘要
 @param imageURL    图文消息的图片URL
 @param url         图文消息中包含的需要跳转到的URL
 @param extra       图文消息的扩展信息
 @return            图文消息对象
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                             url:(nullable NSString *)url
                           extra:(NSString *)extra;

@end

NS_ASSUME_NONNULL_END
