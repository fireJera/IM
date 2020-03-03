////
////  CTMSGChatAliOSS.h
////  ChatMessageKit
////
////  Created by Jeremy on 2019/4/12.
////  Copyright © 2019 JersiZhu. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//typedef void(^CTMSGUploadSuccessBlock)(id _Nullable result);
//
//typedef void(^CTMSGUploadFaileBlock)(id _Nullable result, NSError * error);
////进度
//typedef void(^CTMSGProgressBlock)(float progressValue);
//
//@interface CTMSGChatAliOSS : NSObject
//
//@property (nonatomic, copy, readonly) NSString * chatPath;
//
//- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
//
//////从服务器获取权限
////- (void)stsRequest:(CTMSGBOOLIDBlock)resultBlock;
//
////上传图片
//- (void)uploadImage:(UIImage *)image
//           progress:(CTMSGProgressBlock)progressBlock
//            success:(CTMSGUploadSuccessBlock)successsBlock
//              faile:(CTMSGUploadFaileBlock)faileBlock;
//
//- (void)uploadWav:(NSData *)data
//         duration:(float)duration
//         progress:(CTMSGProgressBlock)progressBlock
//          success:(CTMSGUploadSuccessBlock)successsBlock
//            faile:(CTMSGUploadFaileBlock)faileBlock;
//
///**
// 上传相册单张图片 因为要异步获取图片
// 
// @param image image
// @param time send time interval
// @param progressBlock 进度回调
// @param successsBlock 成功回调
// @param faileBlock 失败回调
// */
//- (void)uploadVideoCover:(UIImage *)image
//                    time:(NSTimeInterval)time
//                progress:(_Nullable CTMSGProgressBlock)progressBlock
//                 success:(_Nullable CTMSGUploadSuccessBlock)successsBlock
//                   faile:(_Nullable CTMSGUploadFaileBlock)faileBlock;
//
////包含封面
//- (void)uploadVideo:(NSString *)videoPath
//           progress:(CTMSGProgressBlock)progressBlock
//            success:(CTMSGUploadSuccessBlock)successsBlock
//              faile:(CTMSGUploadFaileBlock)faileBlock;
//
//////chat upload
////- (void)uploadImage:(UIImage *)image name:(NSString *)name;
////- (void)uploadWav:(NSData *)data name:(NSString *)name;
//
//@end
//
//NS_ASSUME_NONNULL_END
