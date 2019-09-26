//
//  CTMSGChatCameraViewController.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGBeautySlider : UISlider

@end

@class GPUImageView, CTMSGBeautyFilter, GPUImageStillCamera, GPUImageFilterGroup, GPUImageMovieWriter, CTMSGBeautyFilter;

@protocol MessageKitCameraViewDelegate;

@interface MessageKitCameraView : UIView

/**
 default is NO
 */
@property (nonatomic, assign) BOOL showBeautySlider;

/**
 default is YES
 */
@property (nonatomic, assign) BOOL addBeautyFilter;

/**
 default AVCaptureDevicePositionFront
 */
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

/**
 0-1
 */
@property (nonatomic, assign) float beautyValue;

/**
 defaul 3s
 */
@property (nonatomic, assign) NSUInteger minReocrdTime;
/**
 defaul 10s
 */
@property (nonatomic, assign) NSUInteger maxReocrdTime;

/**
 default UIInterfaceOrientationPortrait
 */
@property (nonatomic, assign) UIInterfaceOrientation outputImageOrientation;

/**
 是否正在录制
 */
@property (nonatomic, assign, readonly) BOOL recording;

@property (nonatomic, strong) GPUImageView *cameraView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CTMSGBeautySlider *beautySlider;
@property (nonatomic, strong) CALayer * focusLayer;

//******** Media Property **************
@property (nonatomic, assign, readonly) float recordDuration;
@property (nonatomic, copy) NSString *moviePath;
//@property (nonatomic, copy) NSString *compressdMoviePath;
@property (nonatomic, strong) NSDictionary *audioSettings;
@property (nonatomic, strong) NSDictionary *videoSettings;

//******** GPUImage Property ***********
@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilterGroup *normalFilter;
@property (nonatomic, strong) GPUImageMovieWriter * _Nullable movieWriter;
@property (nonatomic, strong) CTMSGBeautyFilter *leveBeautyFilter;
@property (nonatomic, weak) id<MessageKitCameraViewDelegate> delegate;

- (void)ctmsg_showCameraView;
- (void)ctmsg_switchCamera;

- (void)ctmsg_recapture;
- (void)ctmsg_initCapture;

- (void)ctmsg_startRecordVideo;
- (void)ctmsg_endReocrd:(void(^)(id result, NSError * _Nullable error))block;

- (void)ctmsg_takePhoto:(void(^)(UIImage *image, NSError *error))block;
- (void)ctmsg_endRecordVideo:(void(^)(NSString *videoPath))block;
- (void)ctmsg_play:(nullable NSString *)path;
- (void)ctmsg_pausePlay;

- (void)ctmsg_dismiss;

@end

@protocol MessageKitCameraViewDelegate <NSObject>

@optional

- (void)ctmsg_cameraViewRecordTime:(float)time;
- (void)ctmsg_cameraViewDetectFaceResult:(NSArray<AVMetadataFaceObject *> *)metadataObjects;

@end


@protocol CTMSGChatCameraDelegate;

@interface CTMSGChatCameraViewController : UIViewController

@property (nonatomic, strong) MessageKitCameraView * cameraView;
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
 */
- (void)ctmsg_cameraPhotoTaked:(CTMSGChatCameraViewController *)controller image:(UIImage *)image;

- (void)ctmsg_cameraVideoTaked:(CTMSGChatCameraViewController *)controller videoPath:(NSString *)videoPath;

- (void)ctmsg_cancelCamera:(CTMSGChatCameraViewController *)controller;

@end

NS_ASSUME_NONNULL_END
