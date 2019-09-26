////
////  CTMSGChatAliOSS.m
////  ChatMessageKit
////
////  Created by Jeremy on 2019/4/12.
////  Copyright © 2019 JersiZhu. All rights reserved.
////
//
//#import "CTMSGChatAliOSS.h"
//#import "CTMSGIMClient.h"
//#import "CTMSGNetManager.h"
//#import <AVFoundation/AVFoundation.h>
//#import "NSString+INTCT_Custom.h"
//#import "UIImage+INTCT_Custom.h"
//#import <CodeFrame/CodeFrame.h>
////#import <CodeFrameFrame/NSData+INTCT_Custom.h>
////#import <CodeFrame/NSDate+INTCT_Custom.h>
//#import <AliyunOSSiOS/AliyunOSSiOS.h>
//
//#if __has_include (<YYModel.h>)
//#import <YYModel.h>
//#else
//#import "YYModel.h"
//#endif
//
//#if __has_include (<SDWebImage/NSData+ImageContentType.h>)
//#import <SDWebImage/NSData+ImageContentType.h>
//#else
//#import "NSData+ImageContentType.h"
//#endif
//
//NS_INLINE BOOL CHATLIBIsDictionaryWithItems(id object) {
//    return (object && [object isKindOfClass:[NSDictionary class]] &&
//            [(NSDictionary *)object count] > 0);
//}
//
//@interface CTMSGAliOSSModel : NSObject
//
//@property (nonatomic, copy) NSString * bucketName;
//@property (nonatomic, copy) NSString * endPoint;
//@property (nonatomic, copy) NSString * objectPath;
//@property (nonatomic, copy) NSString * stsUrl;
//
//@property (nonatomic, copy) NSString * accessKeyId;
//@property (nonatomic, copy) NSString * accessKeySecret;
//@property (nonatomic, copy) NSString * expiration;
//@property (nonatomic, copy) NSString * securityToken;
//
//@property (nonatomic, copy) NSDictionary * callbackParam;
//@property (nonatomic, copy) NSDictionary * callbackVar;
//
////自定义 临时用
//@property (nonatomic, copy)     NSString * fileType;                //文件类型
//@property (nonatomic, copy)     NSString * fileTypeVar;             //自定义回调参数
////@property (nonatomic, assign)   BOOL needAppendOrigin;              //上传头像时是否需要在原图文件名加上后缀
///*
// 上传视频时 video cover gif统统为video
// 图片时 为 photo
// */
//@property (nonatomic, copy) NSString * uploadType;
//
////chat
//@property (nonatomic, copy) NSString * visitUrl;
//
//@end
//
//@interface CTMSGChatAliOSS ()
//
//@property (nonatomic, strong) CTMSGAliOSSModel * model;
//@property (nonatomic, strong) OSSClient * client;
//
//@end
//
//
//@implementation CTMSGAliOSSModel
//
//- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    
//}
//
//@end
//
//
//
//
//
//@implementation CTMSGChatAliOSS
//
//- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
//    if (self = [super init]) {
//        _model = [CTMSGAliOSSModel yy_modelWithJSON:dictionary];
//        NSMutableDictionary * mDic = [dictionary[@"callbackParam"] mutableCopy];
//        NSDictionary * callbackVar = mDic[@"callbackVar"];
//        [mDic removeObjectForKey:@"callbackVar"];
//        _model.callbackParam = [mDic copy];
//        _model.callbackVar = callbackVar;
//        //        _model.needAppendOrigin = NO;
//    }
//    return self;
//}
//
//- (void)uploadImage:(UIImage *)image
//           progress:(CTMSGProgressBlock)progressBlock
//            success:(CTMSGUploadSuccessBlock)successBlock
//              faile:(CTMSGUploadFaileBlock)faileBlock {
//    if (image && [image isKindOfClass:[UIImage class]]) {
//        [self p_stsRequest:^(id  _Nullable result) {
//            NSData * uploadData = UIImagePNGRepresentation(image);
//            long long dataLength = uploadData.length / 1024 / 1024;
//            if (dataLength > 20.0) {
//                NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
//                NSString *desc = @"图片过大！！！";
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//                NSError * error = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
//                if (faileBlock) {
//                    faileBlock(nil, error);
//                }
//                return ;
//            }
//            NSString * type;
//            SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
//            if (formatt == SDImageFormatPNG) {
//                type = @"png";
//            } else if (formatt == SDImageFormatGIF) {
//                type = @"gif";
//            } else if (formatt == SDImageFormatJPEG) {
//                type = @"jpg";
//            } else if (formatt == SDImageFormatWebP) {
//                type = @"webp";
//            } else {
//                type = @"image";
//            }
//            //文件目录
//            _model.fileType = type;
//            _model.fileTypeVar = @"image";
//            _model.uploadType = @"photo";
//            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//            [self p_aliUpload:uploadData
//                        index:0
//                         time:time
//                    customDic:@{@"x:msgType": @"img"}
//                     progress:progressBlock
//                 successBlock:successBlock
//                   faileBlock:faileBlock];
//        } faileBlock:^(id  _Nullable result, NSError * _Nonnull error) {
//            
//        }];
//    }
//}
//
//- (void)uploadWav:(NSData *)data
//         duration:(float)duration
//         progress:(CTMSGProgressBlock)progressBlock
//          success:(CTMSGUploadSuccessBlock)successsBlock
//            faile:(CTMSGUploadFaileBlock)faileBlock {
//    if (!data) return;
//    [self p_stsRequest:^(id  _Nullable result) {
//        NSString * type = @"wav";
//        //文件目录
//        _model.fileType = type;
//        _model.fileTypeVar = type;
//        _model.uploadType = @"voice";
//        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//        [self p_aliUpload:data
//                    index:0
//                     time:time
//                customDic:@{@"x:msgType": @"voice", @"x:duration": @(duration)}
//                 progress:progressBlock
//             successBlock:successsBlock
//               faileBlock:faileBlock];
//    } faileBlock:^(id  _Nullable result, NSError * _Nonnull error) {
//        
//    }];
//}
//
//- (void)uploadVideoCover:(UIImage *)image
//                    time:(NSTimeInterval)time
//                progress:(CTMSGProgressBlock)progressBlock
//                 success:(CTMSGUploadSuccessBlock _Nullable)successsBlock
//                   faile:(CTMSGUploadFaileBlock _Nullable)faileBlock {
//    if (!image) {
//        return;
//    }
//    NSData * uploadData = UIImagePNGRepresentation(image);
//    NSString * type;
//    SDImageFormat formatt = [NSData sd_imageFormatForImageData:uploadData];
//    if (formatt == SDImageFormatPNG) {
//        type = @"png";
//    } else if (formatt == SDImageFormatGIF) {
//        type = @"gif";
//    } else if (formatt == SDImageFormatJPEG) {
//        type = @"jpg";
//    } else if (formatt == SDImageFormatWebP) {
//        type = @"webp";
//    } else {
//        type = @"image";
//    }
//    //文件目录
//    _model.fileType = type;
//    _model.fileTypeVar = @"image";
//    NSTimeInterval tempTime;
//    tempTime = time ? time : [[NSDate date] timeIntervalSince1970];
//    _model.uploadType = @"video";
//    [self p_aliUpload:uploadData
//                index:0
//                 time:tempTime
//            customDic:@{@"x:msgType": @"video"}
//             progress:progressBlock
//         successBlock:successsBlock
//           faileBlock:faileBlock];
//}
//
//- (void)uploadVideo:(NSString *)videoPath
//           progress:(CTMSGProgressBlock)progressBlock
//            success:(CTMSGUploadSuccessBlock)successBlock
//              faile:(CTMSGUploadFaileBlock)faileBlock {
//    if (!videoPath) {
//        NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
//        NSString *desc = @"视频压缩失败";
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//        NSError * error = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
//        if (faileBlock) {
//            faileBlock(nil, error);
//        }
//        return ;
//    }
//    NSLog(@"-----video path:%@-------", videoPath);
//    [self p_stsRequest:^(id  _Nullable result) {
//        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//        UIImage * cover = [UIImage imageInLocalVideoPath:videoPath];
//        [self uploadVideoCover:cover time:time progress:nil success:^(id  _Nullable result) {
//            
//        } faile:^(id  _Nullable result, NSError * _Nonnull error) {
//            
//        }];
//        
//        NSData * videoData = [NSData dataWithContentsOfFile:videoPath];
//        
//        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
//        _model.fileType = @"mov";
//        _model.fileTypeVar = @"video";
//        [self p_aliUpload:videoData
//                    index:0
//                     time:time
//                customDic:@{@"x:msgType": @"video"}
//                 progress:progressBlock
//             successBlock:successBlock
//               faileBlock:faileBlock];
//    } faileBlock:^(id  _Nullable result, NSError * _Nonnull error) {
//        //        NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
//        //        NSString *desc = @"获取上传权限失败";
//        //        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//        //        NSError * stsError = [NSError errorWithDomain:domain code:-1111 userInfo:userInfo];
//        if (faileBlock) {
//            faileBlock(nil, error);
//        }
//        return ;
//    }];
//}
//
//- (void)p_aliUpload:(NSData *)content
//              index:(int)index
//               time:(NSTimeInterval)time
//          customDic:(NSDictionary *)customDic
//           progress:(CTMSGProgressBlock)progressBlock
//       successBlock:(CTMSGUploadSuccessBlock)successBlock
//         faileBlock:(CTMSGUploadFaileBlock)faileBlock {
//    OSSPutObjectRequest * put = [[OSSPutObjectRequest alloc] init];
//    put.bucketName = _model.bucketName;
//    
//    NSString * objectKey;
//    //    if (_model.needAppendOrigin) {
//    //        objectKey = [NSString stringWithFormat:@"%@%@_origin.%@", _model.objectPath, [self fileName:index time:time], _model.fileType];
//    //    } else {
//    objectKey = [NSString stringWithFormat:@"%@%@.%@", _model.objectPath, [self fileName:index time:time], _model.fileType];
//    //    }
//    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
//    if (objectKey) {
//        [resultDic setValue:objectKey forKey:@"objectKey"];
//    }
//    put.objectKey = objectKey;
//    //    _model.needAppendOrigin = NO;
//    
//    NSLog(@"------upload filepath : %@--------", put.objectKey);
//    put.contentMd5 = [OSSUtil base64Md5ForData:content];
//    put.uploadingData = content;
//    //设置回调参数
//    NSMutableDictionary * callbackDic = [_model.callbackParam mutableCopy];
//    NSString * urlString = callbackDic[@"callbackUrl"];
//    NSString * encodeSuffix = [self URLEncode:[CTMSGIMClient sharedCTMSGIMClient].netUA];
//    if ([urlString containsString:@"?"]) {
//        urlString = [NSString stringWithFormat:@"%@&_ua=%@", urlString, encodeSuffix];
//    } else {
//        urlString = [NSString stringWithFormat:@"%@?_ua=%@", urlString, encodeSuffix];
//    }
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
//        //        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
//        float sendFloat = (float)totalByteSent;
//        float totalFloat = (float)totalBytesExpectedToSend;
//        //        NSLog(@"%f", sendFloat / totalFloat);
//        //        float value = (float)(totalByteSent / totalBytesExpectedToSend) * 100.0f;
//        float value = sendFloat / totalFloat * 100.0f;
//        if (progressBlock) {
//            NSLog(@"---------strvalue =   %.2f", value);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                progressBlock(value);
//            });
//        }
//    };
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        OSSTask * putTask = [_client putObject:put];
//        [putTask continueWithBlock:^id(OSSTask *task) {
//            if (!task.error) {
//                OSSPutObjectResult * result = (OSSPutObjectResult *)task.result;
//                NSLog(@"upload object success!");
//                //                NSLog(@"%@", result.serverReturnJsonString);
//                NSDictionary * dic = [result.serverReturnJsonString convertToObject];
//                if (CHATLIBIsDictionaryWithItems(dic)) {
//                    [resultDic setValue:dic forKey:@"aliOSS"];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if ([dic[@"status"] isEqualToString:@"ok"]) {
//                            if (successBlock) {
//                                successBlock(resultDic);
//                            }
//                        } else {
//                            if (faileBlock) {
//                                NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
//                                NSString *desc = dic[@"msg"];
//                                if (!desc) {
//                                    desc = @"net error";
//                                }
//                                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//                                NSError *netError = [NSError errorWithDomain:domain
//                                                                        code:-1011
//                                                                    userInfo:userInfo];
//                                faileBlock(resultDic, netError);
//                            }
//                        }
//                    });
//                }
//            } else {
//                NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
//                NSString *desc = [NSString stringWithFormat:@"%ld", task.error.code];
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//                NSError *netError = [NSError errorWithDomain:domain
//                                                        code:task.error.code
//                                                    userInfo:userInfo];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (faileBlock) {
//                        faileBlock(nil, netError);
//                    }
//                });
//                NSLog(@"upload object failed, error: %@" , task.error);
//            }
//            return nil;
//        }];
//        [putTask waitUntilFinished];
//    });
//}
////
////- (void)stsRequest:(CTMSGBOOLIDBlock)resultBlock {
////    [self p_stsRequest:resultBlock];
////}
//
//- (void)p_stsRequest:(CTMSGUploadSuccessBlock)successBlock faileBlock:(CTMSGUploadFaileBlock)faileBlock {
//    NSParameterAssert(_model);
//    if (!_model){
//        NSString *domain = @"com.MessageLib.CTMSGChatAliOSS.ErrorDomain";
//        NSString *desc = @"无法上传文件, 请检查错误(退出页面稍后重试)";
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//        NSError *netError = [NSError errorWithDomain:domain
//                                                code:-1011
//                                            userInfo:userInfo];
//        faileBlock(nil, netError);
//    }
//    NSString * urlStr = _model.stsUrl;
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost url:urlStr params:nil success:^(id  _Nonnull response) {
//        if ([response[@"ok"] intValue] == 1) {
//            [_model setValuesForKeysWithDictionary:response[@"data"]];
//            NSString * endpoint = _model.endPoint;
//            id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_model.accessKeyId secretKeyId:_model.accessKeySecret securityToken:_model.securityToken];
//            _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
//            if (successBlock) {
//                successBlock(response);
//            }
//        }
//    } failure:^(NSError * _Nonnull err) {
//        if (faileBlock) {
//            faileBlock(nil, err);
//        }
//    }];
//}
//
//- (NSString *)fileName:(int)index time:(NSTimeInterval)time {
//    NSString * uid = [CTMSGIMClient sharedCTMSGIMClient].UUIDStr;
//    NSString * secondStr = [NSString stringWithFormat:@"%f", time];
//    NSString * str = [NSString stringWithFormat:@"%@%@%d", uid, secondStr, index];
//    return [str md5String];
//}
//
//#pragma mark - chat
//
//- (NSString *)chatPath {
//    NSString * path = [NSString stringWithFormat:@"%@%@", _model.visitUrl, _model.objectPath];
//    NSString * defaultString = [[NSDate date] toString:@"yyyy-MM-dd"];
//    defaultString = [NSString stringWithFormat:@"chat-msg/%@", defaultString];
//    return path ? path : defaultString;
//}
//
//- (NSString *)URLEncode:(NSString *)string {
//    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
//    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
//    NSString * encodedStr = [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
//    return encodedStr;
//}
//
////- (void)uploadWav:(NSData *)data name:(NSString *)name {
////    if (!data) {
////        return ;
////    }
//////    NSData * uploadData = data;
//////
//////    //    [uploadData base64EncodedDataWithOptions:0];
//////    NSString * audioStr = [uploadData base64EncodedStringWithOptions:0];
//////    //    [uploadData base64String];
//////
//////    NSData * strData = [audioStr dataUsingEncoding:NSUTF8StringEncoding];
//////    NSString * filePath = [UCNFilePathHelper audioCacheDirPath];
//////    filePath = [filePath stringByAppendingPathComponent:name];
//////    [strData writeToFile:filePath atomically:YES];
//////
//////    [audioStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//////
//////    NSData * temp = [NSData dataWithContentsOfFile:filePath];
////    [self p_stsRequest:^(BOOL isSuccess, id result) {
////        if (isSuccess) {
////            [self p_aliChatUpload:data name:name type:nil path:nil];
////        } else {
////
////        }
////    }];
////}
////
////- (void)p_aliChatUpload:(NSData *)content name:(NSString *)name type:(NSString *)type path:(NSString *)filePath {
////    //endpoint
////    //    NSString * endpoint = _model.endPoint;
////    //    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_model.accessKeyId secretKeyId:_model.accessKeySecret securityToken:_model.securityToken];
////    //    OSSClient * client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
////
////    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
////
////    //bucketname unclekon
////    put.bucketName = _model.bucketName;
////
////    //文件目录
////    NSString * uploadPath = [NSString stringWithFormat:@"%@%@", _model.objectPath, name];
////    if (type) {
////        uploadPath = [NSString stringWithFormat:@"%@.%@", uploadPath, type];
////    }
////    put.objectKey = uploadPath;
////    NSLog(@"------upload filepath : %@--------", put.objectKey);
////    // 以下可选字段的含义参考： https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject
////    // put.contentType = @"";
////    // 设置MD5校验，可选
////    put.contentMd5 = [OSSUtil base64Md5ForData:content];
////    put.uploadingData = content;    // Directly upload NSData
////
////    //    put.callbackVar = callbackVar;
////
////    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
////        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
////    };
////
////    dispatch_async(dispatch_get_global_queue(0, 0), ^{
////        OSSTask * putTask = [_client putObject:put];
////
////        [putTask continueWithBlock:^id(OSSTask *task) {
////            //        if (filePath) {
////            //            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
////            //                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
////            //            }
////            //        }
////            //        if (!task.error) {
////            //
////            //        } else {
////            //            NSString * errorCode = [NSString stringWithFormat:@"%ld", task.error.code];
////            //            NSLog(@"upload object failed, error: %@" , task.error);
////            //        }
////            return nil;
////        }];
////        [putTask waitUntilFinished];
////    });
////}
//
//@end
