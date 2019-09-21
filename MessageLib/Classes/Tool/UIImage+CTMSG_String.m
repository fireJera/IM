//
//  UIImage+CTMSG_String.m
//  MessageLib
//
//  Created by Jeremy on 2019/5/27.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "UIImage+CTMSG_String.h"
#import "NSData+CTMSG_Base64.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (CTMSG_String)

+ (UIImage *)ctmsg_libImageInLocalPath:(NSString *)videoPath {
    if (!videoPath) return nil;
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"temp"] URLByAppendingPathExtension:@"mov"];
    NSLog(@"fileURL: %@", [fileURL path]);
    NSData *urlData = [NSData dataWithContentsOfFile:videoPath];
    [urlData writeToURL:fileURL options:NSAtomicWrite error:nil];
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    
    CMTime thumbnailTime = [asset duration];
    thumbnailTime.value = 1;
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:nil];
    return thumbnail;
}

- (NSString *)ctmsg_imageBase64String {
    NSData *data = UIImageJPEGRepresentation(self, 1.0f);
    return [data ctmsg_base64String];
}

@end
