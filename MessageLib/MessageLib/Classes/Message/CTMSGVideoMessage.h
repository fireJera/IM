//
//  CTMSGVideoMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"
#import <UIKit/UIKit.h>

//#define CTMSGVideoMessageTypeIdentifier  @"CTMSG:VideoMsg"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CTMSGVideoMessageTypeIdentifier;
extern NSString * const CTMSGVideoMessageNetTypeIdentifier;

/*!
 语音消息的类型名
 */
/*!
 语音消息类
 
 @discussion 语音消息类，此消息会进行存储并计入未读消息数。
 */
@interface CTMSGVideoMessage : CTMSGMessageContent <NSCoding>

@property (nonatomic, strong) UIImage * thumbnailImage;
@property (nonatomic, strong) NSString * localaPath;
@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, strong) NSString * videoURL;
@property (nonatomic, strong) NSString * thumbnailURL;
@property (nonatomic, assign) CGSize imageSize;

/*!
 语音消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/**
 初始化视频消息

 @param localPath 本地路径 不参与传播
 @param thumbnailImage 缩略图
 @return 消息对象
 */
+ (instancetype)messageWithLocalPath:(NSString *)localPath image:(UIImage *)thumbnailImage;

+ (instancetype)messageWithCoverURL:(NSString *)coverURL
                           videoURL:(NSString *)videoURL
                         videoWidth:(CGFloat)videoWidth
                        videoHeight:(CGFloat)videoHeight;

@end


NS_ASSUME_NONNULL_END
