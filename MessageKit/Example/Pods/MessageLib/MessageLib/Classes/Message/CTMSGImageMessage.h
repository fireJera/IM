//
//  CTMSGImageMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 图片消息的类型名
 */
extern NSString * const CTMSGImageMessageTypeIdentifier;
extern NSString * const CTMSGImageMessageNetTypeIdentifier;

/*!
 图片消息类
 
 @discussion 图片消息类，此消息会进行存储并计入未读消息数。
 */
@interface CTMSGImageMessage : CTMSGMessageContent <NSCoding>

/*!
 图片消息的缩略图
 */
@property(nonatomic, strong) UIImage *thumbnailImage;

/*!
 图片消息的原始图片信息
 */
@property(nonatomic, strong) UIImage *originalImage;

/*!
 图片消息的URL地址
 
 @discussion 发送方此字段为图片的本地路径，接收方此字段为网络URL地址。
 */
@property(nonatomic, strong) NSString *imageURL;

@property(nonatomic, strong) NSString *thumbnailURL;
@property(nonatomic, assign) CGSize imageSize;

/*!
 图片的本地路径
 */
@property(nonatomic, strong) NSString *localPath;
/*!
 是否发送原图
 
 @discussion 在发送图片的时候，是否发送原图，默认值为NO。
 */
@property(nonatomic, getter=isFull) BOOL full NS_UNAVAILABLE;

/*!
 图片消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 图片消息的原始图片信息
 */
@property(nonatomic, strong, readonly) NSData *originalImageData;

/*!
 初始化图片消息
 
 @param image   原始图片
 @return        图片消息对象
 */
+ (instancetype)messageWithImage:(UIImage *)image imageURI:(NSString *)imageURI;

/*!
 初始化图片消息
 
 @param imageURI    图片的本地路径
 @return            图片消息对象
 */
+ (instancetype)messageWithImageURI:(NSString *)imageURI;

///*!
// 初始化图片消息
// 
// @param imageData    图片的原始数据
// @return            图片消息对象
// */
//+ (instancetype)messageWithImageData:(NSData *)imageData;

+ (instancetype)messageWithImageURL:(NSString *)imageURL
                           thumbURL:(NSString *)thumbURL
                              width:(CGFloat)width
                             height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
