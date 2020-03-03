//
//  CTMSGUtilities.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUtilities.h"
#import <Photos/Photos.h>

NSString * const CTMSGDefaultAvatar = @"chat_mesage_kit_avatar";

@implementation CTMSGUtilities

+ (NSString *)timeStrConvetedByMiseSeconds:(long long)timeSecond {
    return @"刚刚";
}

+ (UIImage *)imageForNameInBundle:(NSString *)imageName {
    if (!imageName) return nil;
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"ChatKit" ofType:@"bundle"];
    NSString *imgPath= [bundle stringByAppendingPathComponent:imageName];
    return [UIImage imageWithContentsOfFile:imgPath];
}

+ (NSURL *)voiceUrlForName:(NSString *)fileName {
    if (!fileName) return nil;
    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"ChatKit" ofType:@"bundle"];
    NSString *voicePath = [bundle stringByAppendingPathComponent:fileName];
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

@end
