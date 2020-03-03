//
//  UIImage+CTMSG_Image.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/12.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "UIImage+CTMSG_Image.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (CTMSG_Image)

+ (UIImage *)imageWithLocalVideoPath:(NSString *)videoPath {
    
    
    if (!NSTemporaryDirectory())
    {
        // no tmp dir for the app (need to create one)
    }
    
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"temp"] URLByAppendingPathExtension:@"mov"];
    NSLog(@"fileURL: %@", [fileURL path]);
    NSData *urlData = [NSData dataWithContentsOfFile:videoPath];
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
    //        [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:nil];
    //    }
    [urlData writeToURL:fileURL options:NSAtomicWrite error:nil];
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    thumbnailTime.value = 1;
    
    //  Get image from the video at the given time
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:nil];
    return thumbnail;
}

@end
