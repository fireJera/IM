//
//  CTMSGChatCameraViewController.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CTMSGChatCameraDelegate;

@interface CTMSGChatCameraViewController : UIViewController

@property (nonatomic, weak) id<CTMSGChatCameraDelegate> delegate;
@property (nonatomic, copy, readonly) NSString * videoPath;
@property (nonatomic, copy, readonly) NSString * compressedVideoPath;

@property (nonatomic, assign) int minTime;
@property (nonatomic, assign) int maxTime;

@end

@protocol CTMSGChatCameraDelegate <NSObject>

@optional

/**
 拍完照片的回调

 @param controller self
 @param image image
 @param imagePath imagePath
 */
- (void)ctmsg_cameraPhotoTaked:(CTMSGChatCameraViewController *)controller image:(UIImage *)image imagePath:(nullable NSString *)imagePath;

- (void)ctmsg_cameraVideoTaked:(CTMSGChatCameraViewController *)controller videoPath:(NSString *)videoPath;

- (void)ctmsg_cancelCamera:(CTMSGChatCameraViewController *)controller;

@end

NS_ASSUME_NONNULL_END
