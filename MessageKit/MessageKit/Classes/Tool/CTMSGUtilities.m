//
//  CTMSGUtilities.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUtilities.h"
#import <Photos/Photos.h>
//#import <UIImage+WebP.h>

NSString * const CTMSGDefaultAvatar = @"chat_mesage_kit_avatar";

@implementation CTMSGUtilities

+ (NSString *)timeStrConvetedByMiseSeconds:(long long)timeSecond {
    return @"刚刚";
}

+ (UIImage *)imageForNameInBundle:(NSString *)imageName {
    if (!imageName) return nil;
    NSBundle * selfBundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [selfBundle pathForResource:@"ChatKit" ofType:@"bundle"];
    NSString *imgPath= [path stringByAppendingPathComponent:imageName];
    return [UIImage imageWithContentsOfFile:imgPath];
}

+ (UIImage *)webpImageForNameInBundle:(NSString *)imageName {
    if (!imageName) return nil;
//    NSBundle * selfBundle = [NSBundle bundleForClass:[self class]];
//    NSString * path = [selfBundle pathForResource:@"ChatKit" ofType:@"bundle"];
//    NSString *imgPath= [path stringByAppendingPathComponent:imageName];
//    NSData * imageData = [NSData dataWithContentsOfFile:imgPath];
//    return [UIImage sd_imageWithWebPData:imageData];
    return nil;
}

+ (NSURL *)voiceUrlForName:(NSString *)fileName {
    if (!fileName) return nil;
    NSBundle * selfBundle = [NSBundle bundleForClass:[self class]];
    NSString * path = [selfBundle pathForResource:@"ChatKit" ofType:@"bundle"];
    NSString *voicePath = [path stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:voicePath];
}

+ (void)creatDirPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL exit =[fm fileExistsAtPath:path isDirectory:&isDir];
    if (!exit || !isDir) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)fetchImage:(PHAsset *)asset image:(CTMSGImageFetchBlock)image {
    if (asset) {
        [self fetchImages:@[asset] images:^(NSArray<UIImage *> *images) {
            if (images.count > 0) {
                if (image) {
                    image(images.firstObject);
                }
            }
        }];
    }
}

+ (void)fetchImages:(NSArray<PHAsset *> *)assets images:(CTMSGImagesFetchBlock)images {
    __block NSMutableArray<UIImage *> * array = [NSMutableArray arrayWithCapacity:assets.count];
    
    __block int count = 0;
    __block BOOL isPhotoInICloud = NO;
    
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.sourceType == PHAssetSourceTypeCloudShared) {
            isPhotoInICloud = YES;
            *stop = YES;
        }
    }];
    
    //    hud = [self customProgressHUDTitle:@"你选择的照片不在本地，正在从icloud获取照片"];
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            isPhotoInICloud = YES;
        };
        [array addObject:[UIImage new]];
        // 是否要原图
        //        CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //            NSLog(@"%@", result);
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            
            if (downloadFinined) {
                count++;
                if (result) {
                    [array replaceObjectAtIndex:idx withObject:result];
                }
            }
            if (count == assets.count) {
                if (images) {
                    images(array);
                }
            }
        }];
    }];
}

+ (void)convertVideo:(NSString *)originPath videoQuality:(NSString *)videoQuality finished:(CTMSGVideoCompressBlock)finishedBlock {
    NSString * quality = AVAssetExportPresetMediumQuality;
    if ([videoQuality isEqualToString:@"low"]) {
        quality = AVAssetExportPresetLowQuality;
    } else if ([videoQuality isEqualToString:@"middle"]) {
        quality = AVAssetExportPresetMediumQuality;
    } else if ([videoQuality isEqualToString:@"high"]) {
        quality = AVAssetExportPresetHighestQuality;
    }
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:originPath] options:nil];
    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset presetName:quality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    float nowTime = [[NSDate date] timeIntervalSince1970] * 10000;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
    parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
    NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_video.mov", parentPath, nowTime];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
        NSLog(@"%@",parentPath);
        [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    exportSession.outputURL = [NSURL fileURLWithPath:filePath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                finishedBlock([NSError new], originPath);
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                finishedBlock(nil, filePath);
            }
                [[NSFileManager defaultManager] removeItemAtPath:originPath error:nil];
                break;
        }
    }];
}

+ (void)convertAsset:(PHAsset *)phAsset finished:(CTMSGVideoCompressBlock)finishedBlock {
    [self convertAsset:phAsset videoQuality:AVAssetExportPresetMediumQuality finished:finishedBlock];
}

+ (void)convertAsset:(PHAsset *)phAsset videoQuality:(NSString *)videoQuality finished:(CTMSGVideoCompressBlock)finishedBlock {
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        
        float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
        parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
        NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_video.mov", parentPath, nowTime];
        BOOL isDir;
        if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
            NSLog(@"%@",parentPath);
            [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (asset) {
                if ([asset isKindOfClass:[AVComposition class]]) {
                    if (finishedBlock) {
                        finishedBlock([NSError new], nil);
                    }
                    return ;
                }
                NSURL *fileRUL = [asset valueForKey:@"URL"];
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:fileRUL options:nil];
                
                NSURL *url = urlAsset.URL;
                NSData *data = [NSData dataWithContentsOfURL:url];
                
                BOOL isSuccess = [data writeToFile:filePath atomically:YES];
                if (isSuccess) {
                    [CTMSGUtilities convertVideo:filePath videoQuality:videoQuality finished:finishedBlock];
                } else {
                    if (finishedBlock) {
                        finishedBlock([NSError new], nil);
                    }
                }
            }
            else {
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue]) {
                    __block BOOL ero = NO;
                    PHImageRequestID cloudRequestId = 0;
                    PHVideoRequestOptions *cloudOptions = [[PHVideoRequestOptions alloc] init];
                    cloudOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeMediumQualityFormat;
                    cloudOptions.networkAccessAllowed = YES;
                    cloudOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                        if (error) {
                            [[PHImageManager defaultManager] cancelImageRequest:cloudRequestId];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!ero) {
                                    ero = YES;
                                    if (finishedBlock) {
                                        finishedBlock(error, nil);
                                    }
                                }
                            });
                        }
                    };
                    
                    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:cloudOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        if (asset) {
                            NSURL *fileRUL = [asset valueForKey:@"URL"];
                            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:fileRUL options:nil];
                            
                            NSURL *url = urlAsset.URL;
                            NSData *data = [NSData dataWithContentsOfURL:url];
                            
                            BOOL isSuccess = [data writeToFile:filePath atomically:YES];
                            if (isSuccess) {
                                [CTMSGUtilities convertVideo:filePath videoQuality:videoQuality finished:finishedBlock];
                            } else {
                                if (finishedBlock) {
                                    finishedBlock(nil, filePath);
                                }
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!ero) {
                                    ero = YES;
                                    if (finishedBlock) {
                                        finishedBlock(nil, nil);
                                    }
                                }
                            });
                        }
                    }];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (finishedBlock) {
                            finishedBlock([NSError new], nil);
                        }
                    });
                }
            }
        }];
    }
}

@end
