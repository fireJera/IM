//
//  CTMSGChatAliOSS.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//返回输出结果
typedef void(^CTMSGBOOLIDBlock)(BOOL isSuccess, id _Nullable result);
//返回信息结果
typedef void(^CTMSGBOOLStringBlock)(BOOL isSuccess, NSString * _Nullable msg);
//返回信息结果
typedef void(^CTMSGBOOLIDStringBlock)(BOOL isSuccess, id _Nullable result, NSString * _Nullable msg);
//进度
typedef void(^CTMSGProgressBlock)(float progressValue);

@interface CTMSGChatAliOSS : NSObject

@property (nonatomic, copy, readonly) NSString * chatPath;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
//从服务器获取权限
- (void)stsRequest:(CTMSGBOOLIDBlock)resultBlock;

//上传单张图片
- (void)uploadImage:(UIImage *)image
            quality:(float)quality
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock;


/**
 上传相册单张图片 因为要异步获取图片
 
 @param image image
 @param index order
 @param quality compress quality
 @param isCover video cover?
 @param time send time interval
 @param progressBlock 进度回调
 @param msgBlock 结果回调
 */
- (void)uploadAssetImage:(UIImage *)image
                   index:(int)index
                 quality:(float)quality
                 isCover:(BOOL)isCover
                    time:(NSTimeInterval)time
                progress:(CTMSGProgressBlock)progressBlock
                 message:(CTMSGBOOLIDStringBlock)msgBlock;
//包含封面和gif
- (void)uploadVideo:(NSString *)videoPath
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock;

//包含封面和gif和customDic
- (void)uploadVideo:(NSString *)videoPath
                dic:(nullable NSDictionary *)customDic
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock;

//只有视频
- (void)uploadVideoOnly:(NSString *)videoPath
                    dic:(nullable NSDictionary *)customDic
               progress:(CTMSGProgressBlock)progressBlock
                message:(CTMSGBOOLIDStringBlock)msgBlock;

/*
 前三个都需要再进行一次sts request
 这个方法需确认已经进行过sts request了
 */
- (void)uploadVideoWithOutSts:(NSString *)videoPath
                     progress:(CTMSGProgressBlock)progressBlock
                      message:(CTMSGBOOLIDStringBlock)msgBlock;

/**
 裁剪
 
 @param image 原图
 @param quality 质量
 @param clipImage 裁剪图
 @param progressBlock 进度回调
 @param msgBlock 结果回调
 */
- (void)uploadImage:(UIImage *)image
            quality:(float)quality
                dic:(NSDictionary *)customDic
          clipImage:(UIImage *)clipImage
           progress:(CTMSGProgressBlock)progressBlock
            message:(void(^)(BOOL isSuccess, id result, NSString * msg, BOOL isOrigin))msgBlock;

//chat upload
- (void)uploadImage:(UIImage *)image name:(NSString *)name;
- (void)uploadWav:(NSData *)data name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
