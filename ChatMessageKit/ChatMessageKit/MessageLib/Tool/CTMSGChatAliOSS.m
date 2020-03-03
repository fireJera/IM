//
//  CTMSGChatAliOSS.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatAliOSS.h"
#import "CTMSGAliOSSModel.h"
#import "CTMSGIMClient.h"
//#import "UCNNetWorkManager.h"
//#import "UCNUser.h"
#import <AVFoundation/AVFoundation.h>
//#import "NSGIF.h"
//#import "UCNFilePathHelper.h"
#import "NSString+CTMSG_Str.h"
#import "UIImage+CTMSG_Image.h"
#import "NSData+CTMSG_Data.h"
#import "NSDate+CTMSG_Date.h"

//#import <AliyunOSSiOS/AliyunOSSiOS.h>

#if __has_include (<YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif

#if __has_include (<SDWebImage/NSData+ImageContentType.h>)
#import <SDWebImage/NSData+ImageContentType.h>
#else
#import "NSData+ImageContentType.h"
#endif

@interface CTMSGChatAliOSS ()

@property (nonatomic, strong) CTMSGAliOSSModel * model;
//@property (nonatomic, strong) OSSClient * client;

@end

@implementation CTMSGChatAliOSS

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _model = [CTMSGAliOSSModel yy_modelWithJSON:dictionary];
        NSMutableDictionary * mDic = [dictionary[@"callbackParam"] mutableCopy];
        NSDictionary * callbackVar = mDic[@"callbackVar"];
        [mDic removeObjectForKey:@"callbackVar"];
        _model.callbackParam = [mDic copy];
        _model.callbackVar = callbackVar;
        _model.needAppendOrigin = NO;
    }
    return self;
}

- (void)uploadImage:(UIImage *)image
            quality:(float)quality
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock {
    if (image) {
        [self uploadImages:@[image] quality:quality progress:progressBlock message:msgBlock];
    }
}

- (void)uploadImages:(NSArray<UIImage *> *)images
             quality:(float)quality
            progress:(CTMSGProgressBlock)progressBlock
             message:(CTMSGBOOLIDStringBlock)msgBlock {
    [self p_stsRequest:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIImage * image = obj;
                NSData * uploadData;
                if ([image isKindOfClass:[UIImage class]]) {
                    float q = quality;
                    if (q > 1) {
                        q = q / 100;
                    }
                    uploadData = UIImageJPEGRepresentation(image, q);
                }
                NSString * type;
                SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
                if (formatt == SDImageFormatPNG) {
                    type = @"png";
                } else if (formatt == SDImageFormatGIF) {
                    type = @"gif";
                } else if (formatt == SDImageFormatJPEG) {
                    type = @"jpg";
                } else if (formatt == SDImageFormatWebP) {
                    type = @"webp";
                } else {
                    type = @"image";
                }
                //文件目录
                _model.fileType = type;
                _model.fileTypeVar = @"image";
                _model.uploadType = @"photo";
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                [self p_aliUpload:uploadData
                            index:(int)idx
                             time:time
                              dic:nil
                         progress:progressBlock
                          message:msgBlock];
            }];
        }
    }];
}

- (void)uploadAssetImage:(UIImage *)image
                   index:(int)index
                 quality:(float)quality
                 isCover:(BOOL)isCover
                    time:(NSTimeInterval)time
                progress:(CTMSGProgressBlock)progressBlock
                 message:(CTMSGBOOLIDStringBlock)msgBlock {
    if (!image) {
        return;
    }
    NSData * uploadData;
    if ([image isKindOfClass:[UIImage class]]) {
        float q = quality;
        if (q > 1) {
            q = q / 100;
        }
        uploadData = UIImageJPEGRepresentation(image, q);
    }
    NSString * type;
    SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
    if (formatt == SDImageFormatPNG) {
        type = @"png";
    } else if (formatt == SDImageFormatGIF) {
        type = @"gif";
    } else if (formatt == SDImageFormatJPEG) {
        type = @"jpg";
    } else if (formatt == SDImageFormatWebP) {
        type = @"webp";
    } else {
        type = @"image";
    }
    //文件目录
    _model.fileType = type;
    _model.fileTypeVar = @"image";
    //    NSString * suffix = isCover ? @"_cover" : nil;
    NSTimeInterval tempTime;
    tempTime = time ? time : [[NSDate date] timeIntervalSince1970];
    _model.uploadType = isCover ? @"video" : @"photo";
    [self p_aliUpload:uploadData
                index:index
                 time:tempTime
                  dic:nil
             progress:progressBlock
              message:msgBlock];
}

- (void)uploadVideo:(NSString *)videoPath
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock {
    NSLog(@"-----video path:%@-------", videoPath);
    [self uploadVideo:videoPath dic:nil progress:progressBlock message:msgBlock];
}

- (void)uploadVideo:(NSString *)videoPath
                dic:(NSDictionary *)customDic
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock {
    [self p_stsRequest:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            if (!videoPath) {
                msgBlock(NO, nil, @"视频压缩失败");
                return ;
            }

//            [NSGIF createGIFfromURL:[NSURL fileURLWithPath:videoPath] withFrameCount:5 intervalTime:0.1 delayTime:0.1 completion:^(NSURL *GifURL) {
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//                _model.uploadType = @"video";
//
//                if (GifURL) {
//                    NSData * uploadData = [NSData dataWithContentsOfURL:GifURL];
//                    _model.fileType = @"gif";
//                    _model.fileTypeVar = @"gif";
//                    [self p_aliUpload:uploadData
//                                index:0
//                                 time:time
//                                  dic:customDic
//                             progress:nil message:nil];
//                }
                UIImage * cover = [UIImage imageWithLocalVideoPath:videoPath];
                [self uploadAssetImage:cover index:0 quality:100 isCover:YES time:time progress:nil message:nil];

                NSData * videoData = [NSData dataWithContentsOfFile:videoPath];

                [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
                _model.fileType = @"mov";
                _model.fileTypeVar = @"video";
                [self p_aliUpload:videoData
                            index:0
                             time:time
                              dic:customDic
                         progress:progressBlock
                          message:msgBlock];
//            }];
        }
    }];
}

- (void)uploadVideoOnly:(NSString *)videoPath
                    dic:(NSDictionary *)customDic
               progress:(CTMSGProgressBlock)progressBlock
                message:(CTMSGBOOLIDStringBlock)msgBlock {
    [self p_stsRequest:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
            [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
            _model.fileType = @"mov";
            _model.fileTypeVar = @"video";
            _model.uploadType = @"video";
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            [self p_aliUpload:videoData
                        index:0
                         time:time
                          dic:customDic
                     progress:progressBlock
                      message:msgBlock];
        }
    }];
}

- (void)uploadVideoWithOutSts:(NSString *)videoPath
                     progress:(CTMSGProgressBlock)progressBlock
                      message:(CTMSGBOOLIDStringBlock)msgBlock {
    if (!videoPath) {
        msgBlock(NO, nil, @"文件路径不存在");
        return;
    }
//    [NSGIF createGIFfromURL:[NSURL fileURLWithPath:videoPath] withFrameCount:5 intervalTime:0.1 delayTime:0.1 completion:^(NSURL *GifURL) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//        _model.uploadType = @"video";
//
//        if (GifURL) {
//            NSData * uploadData = [NSData dataWithContentsOfURL:GifURL];
//            _model.fileType = @"gif";
//            _model.fileTypeVar = @"gif";
//            [self p_aliUpload:uploadData
//                        index:0
//                         time:time
//                          dic:nil
//                     progress:nil message:nil];
//        }
        UIImage * cover = [UIImage imageWithLocalVideoPath:videoPath];

        [self uploadAssetImage:cover index:0 quality:100 isCover:YES time:time progress:nil message:nil];

        NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
        _model.fileType = @"mov";
        _model.fileTypeVar = @"video";
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
        [self p_aliUpload:videoData
                    index:0
                     time:time
                      dic:nil
                 progress:progressBlock
                  message:msgBlock];
//    }];
}

- (void)uploadImage:(UIImage *)image
            quality:(float)quality
                dic:(NSDictionary *)customDic
          clipImage:(UIImage *)clipImage
           progress:(CTMSGProgressBlock)progressBlock
            message:(void (^)(BOOL isSuccess, id result, NSString * msg, BOOL isOrigin))msgBlock {
    [self p_stsRequest:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            if (!image || !clipImage) {
                return ;
            }
            NSArray * images = @[image, clipImage];
            NSArray * imageNames = @[@"image", @"cropImage"];

            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];

            [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIImage * image = obj;
                NSData * uploadData;
                if ([image isKindOfClass:[UIImage class]]) {
                    float q = quality;
                    if (q > 1) {
                        q = q / 100;
                    }
                    uploadData = UIImageJPEGRepresentation(image, q);
                }
                NSString * type;
                SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
                if (formatt == SDImageFormatPNG) {
                    type = @"png";
                } else if (formatt == SDImageFormatGIF) {
                    type = @"gif";
                } else if (formatt == SDImageFormatJPEG) {
                    type = @"jpg";
                } else if (formatt == SDImageFormatWebP) {
                    type = @"webp";
                } else {
                    type = @"image";
                }
                //文件目录
                _model.fileType = type;
                _model.fileTypeVar = imageNames[idx];
                if (idx == 0) {
                    _model.needAppendOrigin = YES;
                }
                _model.uploadType = @"photo";
                [self p_aliUpload:uploadData
                            index:0
                             time:time
                              dic:customDic
                         progress:progressBlock
                          message:^(BOOL isSuccess, id result, NSString *msg) {
                              msgBlock(isSuccess, result, msg, idx == 0);
                          }];
            }];
        } else {
            if (msgBlock) {
                msgBlock(NO, nil, @"获取权限失败", YES);
            }
        }
    }];
}

- (void)p_aliUpload:(NSData *)content
              index:(int)index
               time:(NSTimeInterval)time
                dic:(NSDictionary *)customDic
           progress:(CTMSGProgressBlock)progressBlock
            message:(CTMSGBOOLIDStringBlock)msgBlock {
//    //    //endpoint
//    //    NSString * endpoint = _model.endPoint;
//    //
//    //    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_model.accessKeyId secretKeyId:_model.accessKeySecret securityToken:_model.securityToken];
//    //
//    //    OSSClient * client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
//
//    OSSPutObjectRequest * put = [[OSSPutObjectRequest alloc] init];
//
//    //bucketname unclekon
//    put.bucketName = _model.bucketName;
//
//    //文件目录
//    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
//    NSString * objectKey;
//
//    if (_model.needAppendOrigin) {
//        objectKey = [NSString stringWithFormat:@"%@%@_origin.%@", _model.objectPath, [self fileName:index time:time], _model.fileType];
//    } else {
//        objectKey = [NSString stringWithFormat:@"%@%@.%@", _model.objectPath, [self fileName:index time:time], _model.fileType];
//    }
//    if (objectKey) {
//        [resultDic setValue:objectKey forKey:@"objectKey"];
//    }
//    put.objectKey = objectKey;
//    _model.needAppendOrigin = NO;
//
//    NSLog(@"------upload filepath : %@--------", put.objectKey);
//    // 以下可选字段的含义参考： https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject
//    // put.contentType = @"";
//    // 设置MD5校验，可选
//    put.contentMd5 = [OSSUtil base64Md5ForData:content];
//    put.uploadingData = content; // Directly upload NSData
//    //设置回调参数
//    NSMutableDictionary * callbackDic = [_model.callbackParam mutableCopy];
//    NSString * urlString = callbackDic[@"callbackUrl"];
////    NSString * encodeSuffix = [[UCNNetWorkManager urlStringSuffix:NO] URLEncode];
////    if ([urlString containsString:@"?"]) {
////        urlString = [NSString stringWithFormat:@"%@&_ua=%@", urlString, encodeSuffix];
////    } else {
////        urlString = [NSString stringWithFormat:@"%@?_ua=%@", urlString, encodeSuffix];
////    }
//    [callbackDic setValue:urlString forKey:@"callbackUrl"];
//    NSDictionary * callbackP = [callbackDic copy];
//    put.callbackParam = callbackP;
//    //设置自定义变量
//
//    NSMutableDictionary * mDic = [_model.callbackVar mutableCopy];
//    [mDic setValue:_model.fileTypeVar forKey:@"x:fileType"];
//    if (_model.uploadType) {
//        [mDic setValue:_model.uploadType forKey:@"x:uploadType"];
//    }
//    if (customDic) {
//        NSArray * keys = customDic.allKeys;
//        for (NSString * key in keys) {
//            NSString * str = [NSString stringWithFormat:@"%@", customDic[key]];
//            [mDic setValue:str forKey:key];
//        }
//    }
//    NSDictionary * callbackVar = [mDic copy];
//    put.callbackVar = callbackVar;
//
//    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
//        float sendFloat = (float)totalByteSent;
//        float totalFloat = (float)totalBytesExpectedToSend;
//        //        NSLog(@"%f", sendFloat / totalFloat);
//        //        float value = (float)(totalByteSent / totalBytesExpectedToSend) * 100.0f;
//        float value = sendFloat / totalFloat * 100.0f;
//        if (progressBlock) {
//            NSLog(@"---------strvalue =   %.2f", value);
//            progressBlock(value);
//        }
//    };
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        OSSTask * putTask = [_client putObject:put];
//
//        [putTask continueWithBlock:^id(OSSTask *task) {
//            if (!task.error) {
//                OSSPutObjectResult * result = (OSSPutObjectResult *)task.result;
//                NSLog(@"upload object success!");
//                NSLog(@"%@", result.serverReturnJsonString);
//                NSDictionary * dic = [result.serverReturnJsonString convertToObject];
//                if (IsDictionaryWithItems(dic)) {
//                    [resultDic setValue:dic forKey:@"aliOSS"];
//                    if ([dic[@"status"] isEqualToString:@"ok"]) {
//                        if (msgBlock) {
//                            msgBlock(task.completed, resultDic, dic[@"next"]);
//                        }
//                    } else {
//                        if (msgBlock) {
//                            msgBlock(NO, resultDic, dic[@"msg"]);
//                        }
//                    }
//                }
//            } else {
//                NSString * errorCode = [NSString stringWithFormat:@"%ld", task.error.code];
//                if (msgBlock) {
//                    msgBlock(NO, nil, errorCode);
//                }
//                NSLog(@"upload object failed, error: %@" , task.error);
//            }
//            return nil;
//        }];
//        [putTask waitUntilFinished];
//    });
}

- (void)stsRequest:(CTMSGBOOLIDBlock)resultBlock {
    [self p_stsRequest:resultBlock];
}

- (void)p_stsRequest:(CTMSGBOOLIDBlock)resultBlock {
//    NSString * urlStr = [NSString stringWithFormat:@"%@?token=%@", _model.stsUrl, UCNINSTANCE_USER.token];
//    [UCNNetWorkManager multipartPost:urlStr withParameters:nil result:^(BOOL isSuccess, id result) {
//        if (isSuccess) {
//            if ([result[@"ok"] intValue] == 1) {
//                [_model setValuesForKeysWithDictionary:result[@"data"]];
//
//                NSString * endpoint = _model.endPoint;
//
//                id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_model.accessKeyId secretKeyId:_model.accessKeySecret securityToken:_model.securityToken];
//
//                _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
//
//                if (resultBlock) {
//                    resultBlock(YES, result);
//                    return ;
//                }
//            }
//        }
//        if (resultBlock) {
//            resultBlock(NO, result);
//        }
//    }];
    if (resultBlock) {
        resultBlock(YES, nil);
        return ;
    }
}

- (NSString *)fileName:(int)index time:(NSTimeInterval)time {
    NSString * uid = [CTMSGIMClient sharedCTMSGIMClient].UUIDStr;
    //    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString * secondStr = [NSString stringWithFormat:@"%f", time];
    NSString * str = [NSString stringWithFormat:@"%@%@%d", uid, secondStr, index];
    return [str md5String];
}

#pragma mark - chat

- (NSString *)chatPath {
    NSString * path = [NSString stringWithFormat:@"%@%@", _model.visitUrl, _model.objectPath];
    NSString * defaultString = [[NSDate date] toString:@"yyyy-MM-dd"];
    defaultString = [NSString stringWithFormat:@"chat-msg/%@", defaultString];
    return path ? path : defaultString;
}

- (void)uploadImage:(UIImage *)image name:(NSString *)name {
    if (!image) {
        return ;
    }
    NSData * uploadData;
    if ([image isKindOfClass:[UIImage class]]) {
        uploadData = UIImageJPEGRepresentation(image, 1.0);
    }
    NSString * type;
    SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
    if (formatt == SDImageFormatPNG) {
        type = @"png";
    } else if (formatt == SDImageFormatGIF) {
        type = @"gif";
    } else if (formatt == SDImageFormatJPEG) {
        type = @"jpg";
    } else if (formatt == SDImageFormatWebP) {
        type = @"webp";
    } else {
        type = @"image";
    }
    [self p_stsRequest:^(BOOL isSuccess, id result) {
        if (isSuccess) {
            [self p_aliChatUpload:uploadData name:name type:type path:nil];
        } else {

        }
    }];
}

- (void)uploadWav:(NSData *)data name:(NSString *)name {
    if (!data) {
        return ;
    }
    NSData * uploadData = data;

    //    [uploadData base64EncodedDataWithOptions:0];
    NSString * audioStr = [uploadData base64EncodedStringWithOptions:0];
    //    [uploadData base64String];

    NSData * strData = [audioStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSString * filePath = [UCNFilePathHelper audioCacheDirPath];
//    filePath = [filePath stringByAppendingPathComponent:name];
//    [strData writeToFile:filePath atomically:YES];
//
//    [audioStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

//    NSData * temp = [NSData dataWithContentsOfFile:filePath];
//    [self p_stsRequest:^(BOOL isSuccess, id result) {
//        if (isSuccess) {
//            [self p_aliChatUpload:temp name:name type:nil path:nil];
//        } else {
//
//        }
//    }];
}

- (void)p_aliChatUpload:(NSData *)content name:(NSString *)name type:(NSString *)type path:(NSString *)filePath {
//    //endpoint
//    //    NSString * endpoint = _model.endPoint;
//    //    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_model.accessKeyId secretKeyId:_model.accessKeySecret securityToken:_model.securityToken];
//    //    OSSClient * client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
//
//    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
//
//    //bucketname unclekon
//    put.bucketName = _model.bucketName;
//
//    //文件目录
//    NSString * uploadPath = [NSString stringWithFormat:@"%@%@", _model.objectPath, name];
//    if (type) {
//        uploadPath = [NSString stringWithFormat:@"%@.%@", uploadPath, type];
//    }
//    put.objectKey = uploadPath;
//    NSLog(@"------upload filepath : %@--------", put.objectKey);
//    // 以下可选字段的含义参考： https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject
//    // put.contentType = @"";
//    // 设置MD5校验，可选
//    put.contentMd5 = [OSSUtil base64Md5ForData:content];
//    put.uploadingData = content;    // Directly upload NSData
//
//    //    put.callbackVar = callbackVar;
//
//    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
//    };
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        OSSTask * putTask = [_client putObject:put];
//
//        [putTask continueWithBlock:^id(OSSTask *task) {
//            //        if (filePath) {
//            //            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//            //                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
//            //            }
//            //        }
//            //        if (!task.error) {
//            //
//            //        } else {
//            //            NSString * errorCode = [NSString stringWithFormat:@"%ld", task.error.code];
//            //            NSLog(@"upload object failed, error: %@" , task.error);
//            //        }
//            return nil;
//        }];
//        [putTask waitUntilFinished];
//    });
}
    
@end
