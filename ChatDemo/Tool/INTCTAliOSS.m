//
//  INTCTAliOSS.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "INTCTAliOSS.h"
#import <AVFoundation/AVFoundation.h>
#import "INTCTAliOSSModel.h"
//#import "INTCTViewmodelHeader.h"
//#import "INTCTKeyChain.h"
#import "NSGIF.h"
#import "UIImage+INTCT_Custom.h"
//#import "INTCTFilePathHelper.h"
//#import "NSDate+INTCT_Custom.h"
#import "NSData+INTCT_Custom.h"
#import <YYModel/YYModel.h>
#import "NSString+INTCT_Custom.h"
#import "INTCTNetWorkManager.h"
#import "INTCTNetWorkManager+IChat.h"

#if __has_include (<SDWebImage/NSData+ImageContentType.h>)
#import <SDWebImage/NSData+ImageContentType.h>
#else
#import "NSData+ImageContentType.h"
#endif

#if __has_include (<AliyunOSSiOS.h>)
#import <AliyunOSSiOS.h>
#else
#import "AliyunOSSiOS.h"
#endif

static NSString * imageTypeWith(SDImageFormat formatt) {
    if (formatt == SDImageFormatPNG) {
        return @"png";
    } else if (formatt == SDImageFormatGIF) {
        return @"gif";
    } else if (formatt == SDImageFormatJPEG) {
        return @"jpg";
    } else if (formatt == SDImageFormatWebP) {
        return @"webp";
    } else {
        return @"image";
    }
}

static OSSClient * _client = nil;
static long long _expiryTime = 0;
static const int kExpirySecond = 200;

static dispatch_semaphore_t _clientLock;
static dispatch_queue_t _stsQueue = NULL;
#define LOCK() dispatch_semaphore_wait(_clientLock, DISPATCH_TIME_FOREVER);
#define UNLOCK() dispatch_semaphore_signal(_clientLock);

@interface INTCTAliOSS ()

@property (nonatomic, strong) INTCTAliOSSModel * model;

@end

@implementation INTCTAliOSS

- (instancetype)initWithNSDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _model = [INTCTAliOSSModel yy_modelWithJSON:dictionary];
        NSMutableDictionary * mDic = [dictionary[@"callbackParam"] mutableCopy];
        NSDictionary * callbackVar = mDic[@"callbackVar"];
        [mDic removeObjectForKey:@"callbackVar"];
        _model.callbackParam = [mDic copy];
        _model.callbackVar = callbackVar;
        _model.needAppendOrigin = NO;
        if (!_clientLock) {
            _clientLock = dispatch_semaphore_create(1);
        }
    }
    return self;
}

- (void)uploadImage:(UIImage *)image
            quality:(float)quality
           progress:(INTCTNetProgressBlock)progressBlock
             result:(INTCTAliOSSImageResultBlock)resultBlock {
    if (image) {
        [self uploadImages:@[image] quality:quality progress:progressBlock result:resultBlock];
    }
}

- (void)uploadImages:(NSArray<UIImage *> *)images
             quality:(float)quality
            progress:(INTCTNetProgressBlock)progressBlock
              result:(INTCTAliOSSImageResultBlock _Nullable)resultBlock {
    [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nonnull result) {
        if (!error) {
            [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIImage * image = obj;
                NSData * uploadData;
                NSError * sourceError;
                if ([image isKindOfClass:[UIImage class]]) {
                    float q = quality;
                    if (q > 1) {
                        q = q / 100;
                    }
                    uploadData = UIImageJPEGRepresentation(image, q);
                    long long dataLength = uploadData.length / 1024 / 1024;
                    if (dataLength > 20.0) {
                        NSString *domain = @"com.BanteaySrei.INTCTAliOSS.ErrorDomain";
                        NSString *desc = @"图片过大！！！";
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                        sourceError = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
                    }
                } else {
                    NSString *domain = @"com.BanteaySrei.INTCTAliOSS.ErrorDomain";
                    NSString *desc = @"上传对象必须为图片！";
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                    sourceError = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
                }
                if (sourceError && resultBlock) {
                    resultBlock(sourceError, nil);
                    return ;
                }
                SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
                NSString * type = imageTypeWith(formatt);
                
                //文件目录
                _model.fileType = type;
                _model.fileTypeVar = @"image";
                _model.uploadType = @"photo";
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                [self p_intct_aliUpload:uploadData
                                  index:(int)idx
                              tailIndex:0
                                   time:time
                                    dic:nil
                               progress:progressBlock
                                 result:resultBlock];
            }];
        }
    }];
}

- (void)uploadAssetImage:(UIImage *)image
                   index:(int)index
               tailIndex:(int)tailIndex
                 quality:(float)quality
                 isCover:(BOOL)isCover
                    time:(NSTimeInterval)time
                progress:(INTCTNetProgressBlock)progressBlock
                  result:(INTCTAliOSSImageResultBlock _Nullable)resultBlock {
    if (!image) {
        return;
    }
    NSData * uploadData = [image imageRepensationWithQuality:quality];
    long long dataLength = uploadData.length / 1024 / 1024;
    if (dataLength > 20.0) {
        NSString *domain = @"com.BanteaySrei.INTCTAliOSS.ErrorDomain";
        NSString *desc = @"图片过大！！！";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
        NSError * sourceError = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
        if (resultBlock) {
            resultBlock(sourceError, nil);
            return ;
        }
    }
    
    NSString * type = [uploadData imageDataFormat];
    //文件目录
    _model.fileType = type;
    _model.fileTypeVar = @"image";
    _model.uploadType = isCover ? @"video" : @"photo";
    NSTimeInterval tempTime;
    tempTime = time ? time : [[NSDate date] timeIntervalSince1970];
    [self p_intct_aliUpload:uploadData
                      index:index
                  tailIndex:tailIndex
                       time:tempTime
                        dic:nil
                   progress:progressBlock
                     result:resultBlock];
}

- (UIImage *)uploadVideo:(NSString *)videoPath
                progress:(INTCTNetProgressBlock)progressBlock
                  result:(INTCTAliOSSImageResultBlock)resultBlock {
    //    NSLog(@"-----video path:%@-------", videoPath);
    return [self uploadVideo:videoPath dic:nil progress:progressBlock result:resultBlock];
}

- (UIImage *)uploadVideo:(NSString *)videoPath
                     dic:(NSDictionary *)customDic
                progress:(INTCTNetProgressBlock)progressBlock
                  result:(INTCTAliOSSImageResultBlock)resultBlock {
    if (!videoPath) {
        NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
        NSString *desc = @"视频压缩失败";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
        NSError *netError = [NSError errorWithDomain:domain
                                                code:-1111
                                            userInfo:userInfo];
        resultBlock(netError, nil);
        return nil;
    }
    UIImage * cover = [UIImage imageInLocalVideoPath:videoPath];
    [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nonnull result) {
        if (!error) {
            [NSGIF createGIFfromURL:[NSURL fileURLWithPath:videoPath] withFrameCount:5 intervalTime:0.1 delayTime:0.1 completion:^(NSURL *GifURL) {
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                _model.uploadType = @"video";
                
                if (GifURL) {
                    NSData * uploadData = [NSData dataWithContentsOfURL:GifURL];
                    _model.fileType = @"gif";
                    _model.fileTypeVar = @"gif";
                    [self p_intct_aliUpload:uploadData
                                      index:0
                                  tailIndex:0
                                       time:time
                                        dic:customDic
                                   progress:nil
                                     result:nil];
                }
                NSArray<UIImage*> *images = [UIImage imagesInLocalVideoPath:videoPath timeInterval:0.5];
                for (int i = 0; i < images.count; i++) {
                    UIImage * cover = images[i];
                    if (cover) {
                        [self uploadAssetImage:cover index:0 tailIndex:i + 1 quality:100 isCover:YES time:time progress:nil result:nil];
                    }
                }
                //                UIImage * cover = [UIImage imageInLocalVideoPath:videoPath];
//                [self uploadAssetImage:cover index:0 quality:100 isCover:YES time:time progress:nil result:nil];
                NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
                [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
                _model.fileType = @"mov";
                _model.fileTypeVar = @"video";
                [self p_intct_aliUpload:videoData
                                  index:0
                              tailIndex:0
                                   time:time
                                    dic:customDic
                               progress:progressBlock
                                 result:resultBlock];
            }];
        } else {
            if (resultBlock) {
                resultBlock(error, result);
            }
        }
    }];
    return cover;
}

- (void)uploadVideoOnly:(NSString *)videoPath
                    dic:(NSDictionary *)customDic
               progress:(INTCTNetProgressBlock)progressBlock
                 result:(INTCTAliOSSImageResultBlock)resultBlock {
    [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nullable result) {
        if (!error) {
            NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
            [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
            _model.fileType = @"mov";
            _model.fileTypeVar = @"video";
            _model.uploadType = @"video";
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            [self p_intct_aliUpload:videoData
                              index:0
                          tailIndex:0
                               time:time
                                dic:customDic
                           progress:progressBlock
                             result:resultBlock];
        }
    }];
}

- (void)uploadVideoWithoutSts:(NSString *)videoPath
                   coverImage:(UIImage *__autoreleasing *)image
                          dic:(nullable NSDictionary *)customDic
                     progress:(INTCTNetProgressBlock)progressBlock
                       result:(INTCTAliOSSImageResultBlock)resultBlock {
    if (!videoPath) {
        NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
        NSString *desc = @"文件路径不存在";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
        NSError *netError = [NSError errorWithDomain:domain
                                                code:-1111
                                            userInfo:userInfo];
        resultBlock(netError, nil);
        return;
    }
    UIImage * cover = [UIImage imageInLocalVideoPath:videoPath];
    *image = cover;
    [NSGIF createGIFfromURL:[NSURL fileURLWithPath:videoPath] withFrameCount:5 intervalTime:0.1 delayTime:0.1 completion:^(NSURL *GifURL) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        _model.uploadType = @"video";
        
        if (GifURL) {
            NSData * uploadData = [NSData dataWithContentsOfURL:GifURL];
            _model.fileType = @"gif";
            _model.fileTypeVar = @"gif";
            [self p_intct_aliUpload:uploadData
                              index:0
                          tailIndex:0
                               time:time
                                dic:customDic
                           progress:nil
                             result:resultBlock];
        }
        //        UIImage * cover = [UIImage imageInLocalVideoPath:videoPath];
        [self uploadAssetImage:cover index:0 tailIndex:0 quality:100 isCover:YES time:time progress:nil result:resultBlock];
        NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
        _model.fileType = @"mov";
        _model.fileTypeVar = @"video";
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
        [self p_intct_aliUpload:videoData
                          index:0
                      tailIndex:0
                           time:time
                            dic:customDic
                       progress:progressBlock
                         result:resultBlock];
    }];
}

- (void)uploadImage:(UIImage *)image
            quality:(float)quality
                dic:(NSDictionary *)customDic
          clipImage:(UIImage *)clipImage
           progress:(INTCTNetProgressBlock)progressBlock
            message:(nonnull void (^)(NSError * _Nonnull, id _Nullable, BOOL))msgBlock {
    [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nullable result) {
        if (!error) {
            if (!image || !clipImage) return;
            NSArray * images = @[image, clipImage];
            NSArray * imageNames = @[@"image", @"cropImage"];
            
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            
            [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIImage * image = obj;
                NSData * uploadData = [image imageRepensationWithQuality:quality];
                long long dataLength = uploadData.length / 1024 / 1024;
                if (dataLength > 20.0) {
                    NSString *domain = @"com.BanteaySrei.INTCTAliOSS.ErrorDomain";
                    NSString *desc = @"图片过大！！！";
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                    NSError * sourceError = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
                    if (msgBlock) {
                        msgBlock(sourceError, nil, idx == 0);
                        return ;
                    }
                }
                
                NSString * type = [uploadData imageDataFormat];
                //文件目录
                _model.fileType = type;
                _model.fileTypeVar = imageNames[idx];
                NSDictionary * dic = customDic;
                if (idx == 0) {
                    _model.needAppendOrigin = YES;
                    NSMutableDictionary *mDic = [customDic mutableCopy];
                    NSString * md5String = [uploadData md5String];
                    [mDic setObject:md5String forKey:@"x:file_md5"];
                    dic = [mDic copy];
                }
                _model.uploadType = @"photo";
                [self p_intct_aliUpload:uploadData
                                  index:0
                              tailIndex:0
                                   time:time
                                    dic:dic
                               progress:progressBlock
                                 result:^(NSError * _Nullable error, id  _Nullable result) {
                                     if (msgBlock) {
                                         msgBlock(error, result, idx == 0);
                                     }
                                 }];
            }];
        } else {
            NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
            NSString *desc = @"获取权限失败";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
            NSError *netError = [NSError errorWithDomain:domain
                                                    code:-1111
                                                userInfo:userInfo];
            if (msgBlock) {
                msgBlock(netError, nil, YES);
            }
        }
    }];
}

- (void)p_intct_aliUpload:(NSData *)content
                    index:(int)index
                tailIndex:(int)tailIndex
                     time:(NSTimeInterval)time
                      dic:(NSDictionary *)customDic
                 progress:(INTCTNetProgressBlock)progressBlock
                   result:(INTCTAliOSSImageResultBlock)resultBlock {
    OSSPutObjectRequest * put = [[OSSPutObjectRequest alloc] init];
    //bucketname unclekon
    put.bucketName = _model.bucketName;
    //文件目录
    NSString * objectKey;
    if (_model.needAppendOrigin) {
        objectKey = [NSString stringWithFormat:@"%@%@_origin.%@", _model.objectPath, [self fileName:index time:time tailIndex:(int)tailIndex], _model.fileType];
    } else {
        objectKey = [NSString stringWithFormat:@"%@%@.%@", _model.objectPath, [self fileName:index time:time tailIndex:(int)tailIndex], _model.fileType];
    }
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (objectKey) {
        [resultDic setValue:objectKey forKey:@"objectKey"];
    }
    put.objectKey = objectKey;
    _model.needAppendOrigin = NO;
    NSLog(@"------upload filepath : %@--------", put.objectKey);
    // 以下可选字段的含义参考： https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject
    // put.contentType = @"";
    // 设置MD5校验，可选
    put.contentMd5 = [OSSUtil base64Md5ForData:content];
    put.uploadingData = content; // Directly upload NSData
    //设置回调参数
    NSMutableDictionary * callbackDic = [_model.callbackParam mutableCopy];
    NSString * urlString = callbackDic[@"callbackUrl"];
    NSString * encodeSuffix = [[INTCTNetWorkManager intct_urlStringSuffix:NO] URLEncode];
    if ([urlString containsString:@"?"]) {
        urlString = [NSString stringWithFormat:@"%@&_ua=%@", urlString, encodeSuffix];
    } else {
        urlString = [NSString stringWithFormat:@"%@?_ua=%@", urlString, encodeSuffix];
    }
    [callbackDic setValue:urlString forKey:@"callbackUrl"];
    NSDictionary * callbackP = [callbackDic copy];
    put.callbackParam = callbackP;
    //设置自定义变量
    
    NSMutableDictionary * mDic = [_model.callbackVar mutableCopy];
    [mDic setValue:_model.fileTypeVar forKey:@"x:fileType"];
    if (_model.uploadType) {
        [mDic setValue:_model.uploadType forKey:@"x:uploadType"];
    }
    if (customDic) {
        NSArray * keys = customDic.allKeys;
        for (NSString * key in keys) {
            NSString * str = [NSString stringWithFormat:@"%@", customDic[key]];
            [mDic setValue:str forKey:key];
        }
    }
    NSDictionary * callbackVar = [mDic copy];
    put.callbackVar = callbackVar;
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        float sendFloat = (float)totalByteSent;
        float totalFloat = (float)totalBytesExpectedToSend;
        //        NSLog(@"%f", sendFloat / totalFloat);
        //        float value = (float)(totalByteSent / totalBytesExpectedToSend) * 100.0f;
        float value = sendFloat / totalFloat * 100.0f;
        if (progressBlock) {
            //            NSLog(@"---------strvalue =   %.2f", value);
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(value);
            });
        }
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        OSSTask * putTask = [_client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                OSSPutObjectResult * result = (OSSPutObjectResult *)task.result;
                NSLog(@"upload object success!");
                NSLog(@"%@", result.serverReturnJsonString);
                NSDictionary * dic = [result.serverReturnJsonString convertToObject];
                if (IsDictionaryWithItems(dic)) {
                    [resultDic setValue:dic forKey:@"aliOSS"];
                    if ([dic[@"status"] isEqualToString:@"ok"]) {
                        if (resultBlock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(nil, resultDic);
                            });
                        }
                    } else {
                        NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
                        NSString *desc = dic[@"msg"];
                        if (!desc) {
                            desc = @"";
                        }
                        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
                        NSError *netError = [NSError errorWithDomain:domain
                                                                code:-500
                                                            userInfo:userInfo];
                        if (resultBlock) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(netError, resultDic);
                            });
                        }
                    }
                }
            } else {
                NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
                NSString *desc = INTCTNetWorkErrorNoteString;
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                NSError *netError = [NSError errorWithDomain:domain
                                                        code:task.error.code
                                                    userInfo:userInfo];
                if (resultBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resultBlock(netError, nil);
                    });
                }
                NSLog(@"upload object failed, error: %@" , task.error);
            }
            return nil;
        }];
        [putTask waitUntilFinished];
    });
}

- (void)stsRequest:(INTCTAliOSSImageResultBlock)resultBlock {
    [self p_intct_stsRequest:resultBlock];
}

- (void)p_intct_stsRequest:(INTCTAliOSSImageResultBlock)resultBlock {
    if (!_model) {
        NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
        NSString *desc = @"配置为空，无法上传";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
        NSError *netError = [NSError errorWithDomain:domain
                                                code:-1011
                                            userInfo:userInfo];
        if (resultBlock) {
            resultBlock(netError, nil);
        }
        return;
    }
    if (!_stsQueue) {
        _stsQueue = dispatch_queue_create("com.alioss.stsqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    dispatch_async(_stsQueue, ^{
        LOCK()
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (now - _expiryTime > kExpirySecond) {
            _client = nil;
        }
        if (_client) {
            UNLOCK()
            resultBlock(nil, @{@"client" : @"old"});
            return;
        }

        [INTCTNetWorkManager intct_post:_model.stsUrl withParameters:nil success:^(id result) {
            [_model setValuesForKeysWithDictionary:result[@"data"]];
            NSString * endpoint = _model.endPoint;
            id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_model.accessKeyId secretKeyId:_model.accessKeySecret securityToken:_model.securityToken];
            _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
            _expiryTime = [[NSDate date] timeIntervalSince1970];
            UNLOCK()
            if (resultBlock) {
                resultBlock(nil, result);
            }
        } failed:^(BOOL netReachable, NSString *msg, id result) {
            NSString *domain = @"com.CodeFrame.INTCTChatAliOSS.ErrorDomain";
            NSString *desc = msg;
            if (!desc) {
                desc = INTCTNetWorkErrorNoteString;
            }
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
            NSError *netError = [NSError errorWithDomain:domain
                                                    code:-500
                                                userInfo:userInfo];
            UNLOCK()
            if (resultBlock) {
                resultBlock(netError, result);
            }
        }];
    });
}

- (NSString *)fileName:(int)index time:(NSTimeInterval)time tailIndex:(int)tailIndex {
    NSString * uid = @"INTCTNetWorkManager";
//    [INTCTKeyChain UUId];
    NSString * secondStr = [NSString stringWithFormat:@"%f", time];
    NSString * str;
    if (tailIndex == 0) {
        str = [[NSString stringWithFormat:@"%@%@%d", uid, secondStr, index] md5String];
    }
    else {
        str = [[NSString stringWithFormat:@"%@%@%d", uid, secondStr, index] md5String];
        str = [NSString stringWithFormat:@"%@_%d", str, tailIndex];
    }
    return str;
}

@end


@implementation INTCTAliOSS (Message)

- (void)uploadMessageImage:(UIImage *)image
                parameters:(NSDictionary *)parameters
                  progress:(INTCTNetProgressBlock)progressBlock
                    result:(INTCTMessageOSSResultBlock)resultBlock {
    if (image && [image isKindOfClass:[UIImage class]]) {
        [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nullable result) {
            if (!error) {
                NSData * uploadData = UIImagePNGRepresentation(image);
                long long dataLength = uploadData.length / 1024 / 1024;
                if (dataLength > 20.0) {
                    NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
                    NSString *desc = @"图片过大！！！";
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                    NSError * error = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
                    if (resultBlock) {
                        resultBlock(error, 0, nil);
                    }
                    return;
                }
                SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
                NSString * type = imageTypeWith(formatt);
                //文件目录
                _model.fileType = type;
                _model.fileTypeVar = @"image";
                _model.uploadType = @"photo";
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                
                
                NSDictionary * dic = @{@"x:msgType": @"img"};
                NSMutableDictionary * mDic = [dic mutableCopy];
                if (parameters) {
                    NSArray * keys = parameters.allKeys;
                    for (NSString * key in keys) {
                        NSString * str = [NSString stringWithFormat:@"%@", parameters[key]];
                        [mDic setValue:str forKey:key];
                    }
                }
                
                [self p_intct_aliUpload:uploadData index:0 tailIndex:0 time:time dic:mDic progress:progressBlock result:^(NSError * _Nullable error, id  _Nullable result) {
                    long msgUID = 0;
                    if ([result isKindOfClass:NSDictionary.class]) {
                        msgUID = [result[@"aliOSS"][@"data"][@"msgId"] longValue];
                    }
                    if (resultBlock) {
                        resultBlock(error, msgUID, result);
                    }
                }];
            }
        }];
    }
}

- (void)uploadMessageWav:(NSData *)data
                duration:(float)duration
              parameters:(NSDictionary *)parameters
                progress:(INTCTNetProgressBlock)progressBlock
                  result:(INTCTMessageOSSResultBlock)resultBlock {
    if (!data) return;
    [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nullable result) {
        if (!error) {
            NSString * type = @"wav";
            //文件目录
            _model.fileType = type;
            _model.fileTypeVar = type;
            _model.uploadType = @"voice";
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            
            NSDictionary * dic = @{@"x:msgType": @"voice", @"x:duration": @(duration)};
            NSMutableDictionary * mDic = [dic mutableCopy];
            if (parameters) {
                NSArray * keys = parameters.allKeys;
                for (NSString * key in keys) {
                    NSString * str = [NSString stringWithFormat:@"%@", parameters[key]];
                    [mDic setValue:str forKey:key];
                }
            }
            
            [self p_intct_aliUpload:data index:0 tailIndex:0 time:time dic:mDic progress:progressBlock result:^(NSError * _Nullable error, id  _Nullable result) {
                long msgUID = 0;
                if ([result isKindOfClass:NSDictionary.class]) {
                    msgUID = [result[@"aliOSS"][@"data"][@"msgId"] longValue];
                }
                if (resultBlock) {
                    resultBlock(error, msgUID, result);
                }
            }];
        } else {
            
        }
    }];
}

- (void)uploadMessageVideoCover:(UIImage *)image
                           time:(NSTimeInterval)time
                     parameters:(NSDictionary *)parameters
                       progress:(INTCTNetProgressBlock)progressBlock
                         result:(INTCTAliOSSImageResultBlock)resultBlock {
    if (!image) {
        return;
    }
    NSData * uploadData = UIImagePNGRepresentation(image);
    SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
    NSString * type = imageTypeWith(formatt);
    //文件目录
    _model.fileType = type;
    _model.fileTypeVar = @"image";
    NSTimeInterval tempTime;
    tempTime = time ? time : [[NSDate date] timeIntervalSince1970];
    _model.uploadType = @"video";
    
    NSDictionary * dic = @{@"x:msgType": @"video"};
    NSMutableDictionary * mDic = [dic mutableCopy];
    if (parameters) {
        NSArray * keys = parameters.allKeys;
        for (NSString * key in keys) {
            NSString * str = [NSString stringWithFormat:@"%@", parameters[key]];
            [mDic setValue:str forKey:key];
        }
    }
    
    [self p_intct_aliUpload:uploadData index:0 tailIndex:0 time:tempTime dic:mDic progress:progressBlock result:resultBlock];
}

- (void)uploadMessageVideo:(NSString *)videoPath
                 videoSize:(CGSize)videoSize
                parameters:(NSDictionary *)parameters
                  progress:(INTCTNetProgressBlock)progressBlock
                    result:(INTCTMessageOSSResultBlock)resultBlock {
    if (!videoPath) {
        NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
        NSString *desc = @"视频压缩失败";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
        NSError * error = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, 0, nil);
        }
        return ;
    }
    NSLog(@"-----video path:%@-------", videoPath);
    [self p_intct_stsRequest:^(NSError * _Nullable error, id  _Nullable result) {
        if (!error) {
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            UIImage * cover = [UIImage imageInLocalVideoPath:videoPath];
            [self uploadMessageVideoCover:cover time:time parameters:parameters progress:nil result:^(NSError * _Nullable error, id  _Nullable result) {
                
            }];
            
            NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
            _model.fileType = @"mov";
            _model.fileTypeVar = @"video";
            NSDictionary * dic = @{
                                   @"x:msgType": @"video",
                                   @"x:videoWidth" : @(videoSize.width),
                                   @"x:videoHeight" : @(videoSize.height),
                                   };
            NSMutableDictionary * mDic = [dic mutableCopy];
            if (parameters) {
                NSArray * keys = parameters.allKeys;
                for (NSString * key in keys) {
                    NSString * str = [NSString stringWithFormat:@"%@", parameters[key]];
                    [mDic setValue:str forKey:key];
                }
            }
            
            [self p_intct_aliUpload:videoData index:0 tailIndex:0 time:time dic:mDic progress:progressBlock result:^(NSError * _Nullable error, id  _Nullable result) {
                long msgUID = 0;
                if ([result isKindOfClass:NSDictionary.class]) {
                    msgUID = [result[@"aliOSS"][@"data"][@"msgId"] longValue];
                }
                if (resultBlock) {
                    resultBlock(error, msgUID, result);
                }
            }];
        }
    }];
}

@end
