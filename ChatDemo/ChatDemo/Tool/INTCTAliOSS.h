//
//  INTCTAliOSS.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Header.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ _Nullable INTCTAliOSSImageResultBlock)(NSError * _Nullable error, id _Nullable result);
typedef void(^ _Nullable INTCTMessageOSSResultBlock)(NSError * _Nullable error, long messageUId, id _Nullable result);
//typedef void(^ _Nullable INTCTAliOSSMultiImageResultBlock)(NSArray * uploadedArray, NSArray * failedArray);

@interface INTCTAliOSS : NSObject

@property (nonatomic, copy, readonly) NSString * chatPath;

- (instancetype)initWithNSDictionary:(NSDictionary *)dictionary;

//从服务器获取权限
- (void)stsRequest:(INTCTAliOSSImageResultBlock)resultBlock;

//上传单张图片
- (void)uploadImage:(UIImage *)image
            quality:(float)quality
           progress:(INTCTNetProgressBlock)progressBlock
             result:(INTCTAliOSSImageResultBlock)resultBlock;

/**
 上传相册单张图片 因为要异步获取图片
 
 @param image image
 @param index order
 @param tailIndex index of frame image from video
 @param quality compress quality
 @param isCover video cover?
 @param time send time interval
 @param progressBlock 进度回调
 @param resultBlock 结果回调
 */
- (void)uploadAssetImage:(UIImage *)image
                   index:(int)index
               tailIndex:(int)tailIndex
                 quality:(float)quality
                 isCover:(BOOL)isCover
                    time:(NSTimeInterval)time
                progress:(_Nullable INTCTNetProgressBlock)progressBlock
                  result:(_Nullable INTCTAliOSSImageResultBlock)resultBlock;
//包含封面和gif
- (UIImage *)uploadVideo:(NSString *)videoPath
                progress:(_Nullable INTCTNetProgressBlock)progressBlock
                  result:(INTCTAliOSSImageResultBlock)resultBlock;

//包含封面和gif和customDic
- (UIImage *)uploadVideo:(NSString *)videoPath
                     dic:(nullable NSDictionary *)customDic
                progress:(_Nullable INTCTNetProgressBlock)progressBlock
                  result:(INTCTAliOSSImageResultBlock)resultBlock;

//只有视频
- (void)uploadVideoOnly:(NSString *)videoPath
                    dic:(nullable NSDictionary *)customDic
               progress:(_Nullable INTCTNetProgressBlock)progressBlock
                 result:(INTCTAliOSSImageResultBlock)resultBlock;

/*
 前三个都需要再进行一次sts request
 这个方法需确认已经进行过sts request了
 */
- (void)uploadVideoWithoutSts:(NSString *)videoPath
                   coverImage:(UIImage * _Nullable * _Nullable)image
                          dic:(nullable NSDictionary *)customDic
                     progress:(_Nullable INTCTNetProgressBlock)progressBlock
                       result:(INTCTAliOSSImageResultBlock)resultBlock;

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
           progress:(INTCTNetProgressBlock)progressBlock
            message:(void(^)(NSError * error, id _Nullable result, BOOL isOrigin))msgBlock;

@end

typedef void(^INTCTUploadMessageSuccessBlock)(id _Nullable result);

typedef void(^INTCTUploadMessageFaileBlock)(id _Nullable result, NSError * error);


@interface INTCTAliOSS (Message)

//上传图片
- (void)uploadMessageImage:(UIImage *)image
                parameters:(NSDictionary *)parameters
                  progress:(INTCTNetProgressBlock)progressBlock
                    result:(INTCTMessageOSSResultBlock)resultBlock;

- (void)uploadMessageWav:(NSData *)data
                duration:(float)duration
              parameters:(NSDictionary *)parameters
                progress:(INTCTNetProgressBlock)progressBlock
                  result:(INTCTMessageOSSResultBlock)resultBlock;

/**
 上传相册单张图片 因为要异步获取图片
 
 @param image image
 @param time send time interval
 @param progressBlock 进度回调
 @param resultBlock 结果回调
 */

- (void)uploadMessageVideoCover:(UIImage *)image
                           time:(NSTimeInterval)time
                     parameters:(NSDictionary *)parameters
                       progress:(_Nullable INTCTNetProgressBlock)progressBlock
                         result:(INTCTAliOSSImageResultBlock)resultBlock;

//包含封面
- (void)uploadMessageVideo:(NSString *)videoPath
                 videoSize:(CGSize)videoSize
                parameters:(NSDictionary *)parameters
                  progress:(INTCTNetProgressBlock)progressBlock
                    result:(INTCTMessageOSSResultBlock)resultBlock;

@end


NS_ASSUME_NONNULL_END
