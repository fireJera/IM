//
//  CTMSGChatCameraViewController.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatCameraViewController.h"
#import "CTMSGBeautyFilter.h"
#import "CADisplayLink+CTMSG_Block.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"

#if __has_include (<GPUImage.h>)
#import <GPUImage.h>
#else
#import "GPUImage.h"
#endif

//https://blog.csdn.net/Philm_iOS/article/list/7? GPUImage 源码解读
//http://blog.leichunfeng.com/blog/2015/12/25/reactivecocoa-v2-dot-5-yuan-ma-jie-xi-zhi-jia-gou-zong-lan/ reactivecocoa
//https://juejin.im/post/5ab272e9518825558507720f reactivecocoa

static const int kCameraWidth = 540;
static const int kCameraHeight = 960;
static const int kRoundWidth = 80;
static const int kLittleRoundWidth = 60;
static const int kLeftInterval = 36;

//拍照按钮的中间
#define kRecordCenter CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - kLeftInterval - (kRoundWidth / 2))
//录像存储路径
#define kVideoPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"myFile/movie.mov"]

#define kCompressVideoPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"myFile/compresMovie.mov"];

@interface CTMSGChatCameraViewController () <CAAnimationDelegate> {
    CGFloat _allTime;
    UIImage *_tempImg;
    AVPlayerLayer *_avplayer;
}

//******** UIKit Property *************
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *cameraSwitch;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *recaptureButton;
@property (nonatomic, strong) UIButton *commitButton;
//
@property (nonatomic, strong) GPUImageView *cameraView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel * noteLabel;
//@property (nonatomic, strong) LETADBeautySlider *beautySlider;

//******** Animation Property **********
@property (nonatomic, strong) CAShapeLayer * progressLayer;
@property (nonatomic, strong) UIView * roundFace;
@property (nonatomic, strong) UIView * littleRoundFace;
@property (nonatomic, strong) CALayer * focusLayer;
@property (nonatomic, strong) CADisplayLink * timer;

//******** Media Property **************
@property (nonatomic, copy) NSString *moviePath;
@property (nonatomic, strong) NSDictionary *audioSettings;
@property (nonatomic, strong) NSMutableDictionary *videoSettings;

//******** GPUImage Property ***********
@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilterGroup *normalFilter;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) CTMSGBeautyFilter *leveBeautyFilter;

@end

@implementation CTMSGChatCameraViewController

#pragma mark - Life Cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self p_letad_setupUI];
    [self p_letad_setupNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Private Method

- (void)p_letad_setupUI {
    self.cameraView = ({
        GPUImageView * g = [[GPUImageView alloc] init];
        [g.layer addSublayer:self.focusLayer];
        [g addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusTap:)]];
        [g setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        [self.view addSubview:g];
        g;
    });
    
    self.backButton = ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setImage:[UIImage imageNamed:@"letad_aremac_5"] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(p_letad_cancelRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        b;
    });
    
//    if (_viewmodel.isSwitchCamera) {
//        [self.view addSubview:self.cameraSwitch];
//    }
    
    _roundFace = ({
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(kRecordCenter.x - (kRoundWidth / 2), kRecordCenter.y - (kRoundWidth / 2), kRoundWidth, kRoundWidth)];
//        view.backgroundColor = [UIColor cameraGrayColor];
        view.layer.cornerRadius = kRoundWidth / 2;
        [self.view addSubview:view];
        view;
    });
    
    _littleRoundFace = ({
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(kRecordCenter.x - (kLittleRoundWidth / 2), kRecordCenter.y - (kLittleRoundWidth / 2), kLittleRoundWidth, kLittleRoundWidth)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = kLittleRoundWidth / 2;
        [self.view addSubview:view];
        view;
    });
    
    self.recordButton = ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:b];
        b;
    });
    
    self.noteLabel = ({
        UILabel * l = [[UILabel alloc] init];
//        l.text = _viewmodel.takeNote;
        l.textAlignment = NSTextAlignmentCenter;
        l.textColor = [UIColor whiteColor];
        l.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:l];
        l;
    });
    
//    if (_viewmodel.useFilter) {
//        [self.view addSubview:self.beautySlider];
//    }
//    [self.videoCamera addTarget:_viewmodel.useFilter ? self.leveBeautyFilter : self.normalFilter];
//    [_viewmodel.useFilter ? self.leveBeautyFilter : self.normalFilter addTarget:self.cameraView];
    [self.videoCamera addTarget:self.leveBeautyFilter];
    [self.leveBeautyFilter addTarget:self.cameraView];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:self.moviePath] size:CGSizeMake(kCameraWidth, kCameraWidth) fileType:AVFileTypeQuickTimeMovie outputSettings:self.videoSettings];
    [self.videoCamera addAudioInputsAndOutputs];
    self.videoCamera.audioEncodingTarget = _movieWriter;
    
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    [self.videoCamera startCameraCapture];
    //    });
    //
//    if ([_viewmodel.uploadType isEqualToString:@"photo"]) {
//        [_recordButton addTarget:self action:@selector(p_letad_takePhoto:) forControlEvents:UIControlEventTouchDown];
//    } else if ([_viewmodel.uploadType isEqualToString:@"video"]) {
//        [_recordButton addTarget:self action:@selector(p_letad_beginRecord:) forControlEvents:UIControlEventTouchDown];
//        [_recordButton addTarget:self action:@selector(p_letad_endRecord:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
//    } else if ([_viewmodel.uploadType isEqualToString:@"all"]) {
        [_recordButton addTarget:self action:@selector(p_letad_beginAllTypeRecord:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(p_letad_endAllTypeRecord:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [self.videoCamera startCameraCapture];
    });
}

- (void)p_letad_setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_letad_moviePlayDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_letad_applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_letad_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.cameraView.frame = self.view.bounds;
    self.noteLabel.frame = CGRectMake((self.view.frame.size.width - 160) / 2, self.view.frame.size.width - 190, 160, 20);
    
    self.recordButton.bounds = CGRectMake(0, 0, kRoundWidth, kRoundWidth);
    self.recordButton.center = kRecordCenter;
    
    self.backButton.frame = CGRectMake(0, 0, 70, 38);
    self.backButton.center = CGPointMake(kLeftInterval + 70 / 2, kRecordCenter.y);
    
    self.cameraSwitch.frame = CGRectMake(0, 0, 70, 62);
    self.cameraSwitch.center = CGPointMake(self.view.frame.size.width - 70 / 2 - kLeftInterval, kRecordCenter.y);
}

#pragma mark - Logic Method

- (void)p_letad_beautyValueChanged:(UISlider *)slider {
    if (slider.value == 0) {
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.normalFilter];
        [self.normalFilter addTarget:self.cameraView];
    } else {
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.leveBeautyFilter];
        [self.leveBeautyFilter addTarget:self.cameraView];
        self.leveBeautyFilter.beautyLevel = slider.value / 100;
    }
}

- (void)p_letad_takePhoto:(UIButton *)sender {
    unlink([self.moviePath UTF8String]);
    sender.enabled = NO;
    [self.leveBeautyFilter addTarget:self.movieWriter];
//    if (_viewmodel.useFilter) {
//        [(_beautySlider.value > 0  ? self.leveBeautyFilter : self.normalFilter) addTarget:self.movieWriter];
//    } else {
//        [self.normalFilter addTarget:self.movieWriter];
//    }
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat width = kRoundWidth + 20;
        _roundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
        _roundFace.layer.cornerRadius = width / 2;
        width = kLittleRoundWidth - 20;
        _littleRoundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
        _littleRoundFace.layer.cornerRadius = width / 2;
    }];
    
    [self.movieWriter startRecording];
    
    sender.selected = YES;
    [sender setTitle:@"" forState:UIControlStateNormal];
    [self p_letad_finishTakePhoto];
}

- (void)p_letad_finishTakePhoto {
    [self.leveBeautyFilter removeTarget:self.movieWriter];
//    if (_viewmodel.useFilter) {
//        [(self.beautySlider.value > 0 ? self.leveBeautyFilter : self.normalFilter) removeTarget:self.movieWriter];
//    } else {
//        [self.normalFilter removeTarget:self.movieWriter];
//    }
    [self.movieWriter finishRecording];
    
    __weak typeof(self) weakSelf = self;
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:self.leveBeautyFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_tempImg = processedImage;
        [weakSelf p_letad_createNewWritter];
        weakSelf.imageView.image = processedImage;
//        if (weakSelf.viewmodel.userEdit) {
//            [weakSelf p_letad_recaptureAction];
//            [weakSelf p_letad_pushEdit:processedImage];
//        } else {
            [weakSelf p_letad_showPhoto];
//        }
    }];
}

- (void)p_letad_beginRecord:(UIButton *)sender {
    unlink([self.moviePath UTF8String]);
    sender.enabled = NO;
    [self.leveBeautyFilter addTarget:self.movieWriter];
//    if (_viewmodel.useFilter) {
//        [(_beautySlider.value > 0  ? self.leveBeautyFilter : self.normalFilter) addTarget:self.movieWriter];
//    } else {
//        [self.normalFilter addTarget:self.movieWriter];
//    }
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat width = kRoundWidth + 20;
        _roundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
        _roundFace.layer.cornerRadius = width / 2;
        width = kLittleRoundWidth - 20;
        _littleRoundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
        _littleRoundFace.layer.cornerRadius = width / 2;
    }];
    unlink([kVideoPath UTF8String]);
    [self.movieWriter startRecording];
    
    [self.view.layer addSublayer:self.progressLayer];
    sender.selected = YES;
    
    __weak typeof(self) weakSelf = self;
    _timer = [CADisplayLink displayLinkWithExecuteBlock:^(CADisplayLink *displayLink) {
        [weakSelf p_letad_timerupdating];
    }];
    _timer.frameInterval = 3;
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _allTime = 0;
}

- (void)p_letad_endRecord:(UIButton *)sender {
    sender.selected = NO;
    if (!_timer) {
        return;
    }
    
    [_timer invalidate];
    _timer = nil;
    
    [self p_letad_showPlayer];
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        self.recaptureButton.alpha = 1.0;
        self.commitButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [self.leveBeautyFilter removeTarget:self.movieWriter];
    
//    if (_viewmodel.useFilter) {
//        [(self.beautySlider.value > 0 ? self.leveBeautyFilter : self.normalFilter) removeTarget:self.movieWriter];
//    } else {
//        [self.normalFilter removeTarget:self.movieWriter];
//    }
    
    if (_allTime < _minTime) {
//        NSString * msg = [NSString stringWithFormat:@"视频最短为%d秒", _minTime];
//        [self showTextHUD:msg toView:self.view];
        [self.movieWriter finishRecording];
        [self p_letad_createNewWritter];
        [self p_letad_recaptureAction];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf p_letad_createNewWritter];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf->_allTime > 0.5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.videoCamera pauseCameraCapture];
                strongSelf->_avplayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:[NSURL fileURLWithPath:kVideoPath]]];
                strongSelf->_avplayer.frame = weakSelf.view.bounds;
                [weakSelf.view.layer insertSublayer:strongSelf->_avplayer above:weakSelf.cameraView.layer];
                [strongSelf->_avplayer.player play];
            });
        }
    }];
}

- (void)p_letad_beginAllTypeRecord:(UIButton *)sender {
    [self p_letad_beginRecord:sender];
}

- (void)p_letad_endAllTypeRecord:(UIButton *)sender {
    if (_allTime < 0.3) {
        [self p_letad_finishTakePhoto];
        [_timer invalidate];
        _timer = nil;
        return;
    } else {
        [self p_letad_endRecord:sender];
    }
}

- (void)back:(UIButton *)sender {
    [_focusLayer removeAllAnimations];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)p_letad_cancelRecord:(UIButton *)sender {
    [_focusLayer removeAllAnimations];
    [self.videoCamera stopCameraCapture];
    [self dismissViewControllerAnimated:true completion:nil];
//    if ([_delegate respondsToSelector:@selector(cancelCamera)]) {
//        [_delegate cancelCamera];
//    }
}

- (void)p_letad_timerupdating {
    _allTime += 0.05;
    //    NSLog(@"_alltime:-------%f", _allTime);
    [self updateProgress:_allTime / _maxTime playing:NO];
}

- (void)p_letad_createNewWritter {
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:self.moviePath] size:CGSizeMake(kCameraWidth, kCameraWidth) fileType:AVFileTypeQuickTimeMovie outputSettings:self.videoSettings];
    _movieWriter.hasAudioTrack = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    /// 如果不加上这一句，会出现第一帧闪现黑屏
    [_videoCamera addAudioInputsAndOutputs];
    self.videoCamera.audioEncodingTarget = _movieWriter;
}


- (void)p_letad_showCameraView {
    _recordButton.hidden = NO;
    _recordButton.enabled = YES;
    _backButton.hidden = NO;
    _cameraSwitch.hidden = NO;
//    !_viewmodel.isSwitchCamera;
    [_imageView removeFromSuperview];
//    _beautySlider.hidden = !_viewmodel.useFilter;
    [self.recaptureButton removeFromSuperview];
    [self.commitButton removeFromSuperview];
    [_imageView addSubview:_recaptureButton];
    [_imageView addSubview:_commitButton];
    
    [_avplayer.player pause];
    [_avplayer removeFromSuperlayer];
    [_progressLayer removeFromSuperlayer];
    
    _roundFace.hidden = NO;
    _littleRoundFace.hidden = NO;
    CGFloat width = kRoundWidth;
    _roundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
    _roundFace.layer.cornerRadius = width / 2;
    width = kLittleRoundWidth;
    _littleRoundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
    _littleRoundFace.layer.cornerRadius = width / 2;
}

- (void)p_letad_showPhoto {
    _recordButton.enabled = YES;
    [self.view addSubview:_imageView];
    [self.recaptureButton removeFromSuperview];
    [self.commitButton removeFromSuperview];
    _commitButton.alpha = 1;
    _recaptureButton.alpha = 1;
    [_imageView addSubview:_recaptureButton];
    
    [_imageView addSubview:_commitButton];
    _roundFace.hidden = YES;
    _littleRoundFace.hidden = YES;
}

- (void)p_letad_showPlayer {
    _recordButton.hidden = YES;
    _cameraSwitch.hidden = YES;
    _backButton.hidden = YES;
//    _beautySlider.hidden = YES;
    [_progressLayer removeFromSuperlayer];
    _progressLayer.path = nil;
    
    [self.recaptureButton removeFromSuperview];
    [self.commitButton removeFromSuperview];
    [self.view addSubview:_recaptureButton];
    [self.view addSubview:_commitButton];
    _roundFace.hidden = YES;
    _littleRoundFace.hidden = YES;
}

#pragma mark - AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:1.0f];
}

- (void)p_letad_applicationWillResignActive:(NSNotification *)notification {
    if (_avplayer) {
        [_avplayer.player pause];
    }
}

- (void)p_letad_applicationDidBecomeActive:(NSNotification *)notification {
    if (_avplayer) {
        [_avplayer.player play];
    }
}

#pragma mark - User Action

- (void)p_letad_commitAction:(UIButton *)sender {
    if (_tempImg) {
        sender.enabled = NO;
        if ([_delegate respondsToSelector:@selector(ctmsg_cameraPhotoTaked:image:imagePath:)]) {
            [_delegate ctmsg_cameraPhotoTaked:self image:_tempImg imagePath:nil];
        }
    } else {
        [_avplayer.player pause];
        if ([_delegate respondsToSelector:@selector(ctmsg_cameraVideoTaked:videoPath:)]) {
            [_delegate ctmsg_cameraVideoTaked:self videoPath:kVideoPath];
        }
    }
}

- (void)p_letad_recaptureAction {
    [self p_letad_showCameraView];
    [self.videoCamera resumeCameraCapture];
    _avplayer = nil;
    _tempImg = nil;
    [[NSFileManager defaultManager] removeItemAtPath:kVideoPath error:nil];
}

- (void)p_letad_turnAction:(id)sender {
    [self.videoCamera pauseCameraCapture];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.videoCamera rotateCamera];
        [self.videoCamera resumeCameraCapture];
    });
    [self performSelector:@selector(p_letad_animationCamera) withObject:self afterDelay:0.2f];
}

- (void)p_letad_pushEdit:(UIImage *)image {
//    LETADClipImageViewController * clip = [[LETADClipImageViewController alloc] init];
//    LETADClipImageViewmodel * viewmodel = [[LETADClipImageViewmodel alloc] initWithNSDictionary:_viewmodel.aliDic];
//    clip.viewmodel = viewmodel;
//    clip.delegate = self;
//    clip.image = image;
//    [self presentViewController:clip animated:YES completion:nil];
}

#pragma mark - LETADNewClipImageDelegate
- (void)imageUploadFromClip:(UIImage *)originImage
                  clipImage:(UIImage *)clipImage
                    success:(BOOL)isSuccess
                     result:(id)result
                 originPath:(NSString *)originPath
                   clipPath:(NSString *)clipPath {
//    if ([_delegate respondsToSelector:@selector(letad_imageUploadFromCamera:clipImage:success:result:originPath:clipPath:)]) {
//        [_delegate letad_imageUploadFromCamera:originImage
//                                     clipImage:clipImage
//                                       success:YES
//                                        result:result
//                                    originPath:originPath
//                                      clipPath:clipPath];
//
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

#pragma mark 聚焦
- (void)focusTap:(UITapGestureRecognizer *)tap {
    self.cameraView.userInteractionEnabled = NO;
    
    CGPoint touchPoint = [tap locationInView:tap.view];
    
    if (touchPoint.y > self.view.frame.size.width) {
        return;
    }
    [self layerAnimationWithPoint:touchPoint];
    touchPoint = CGPointMake(touchPoint.x / tap.view.bounds.size.width, touchPoint.y / tap.view.bounds.size.height);
    //
    if ([self.videoCamera.inputCamera isFocusPointOfInterestSupported] && [self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([self.videoCamera.inputCamera lockForConfiguration:&error]) {
            [self.videoCamera.inputCamera setFocusPointOfInterest:touchPoint];
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([self.videoCamera.inputCamera isExposurePointOfInterestSupported] && [self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [self.videoCamera.inputCamera setExposurePointOfInterest:touchPoint];
                [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [self.videoCamera.inputCamera unlockForConfiguration];
            
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
    
}

#pragma mark - Notification Action
//播放结束
- (void)p_letad_moviePlayDidEnd:(NSNotification *)notification {
    [_avplayer.player seekToTime:kCMTimeZero];
    [_avplayer.player play];
}

#pragma mark - Animation
- (void)p_letad_animationCamera {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromRight;
    [self.cameraView.layer addAnimation:animation forKey:nil];
}

/**
 更新进度条
 
 @param value 进度
 @param playing 是否是播放
 */
- (void)updateProgress:(CGFloat)value playing:(BOOL)playing {
    if (value > 1.0) {
        [self p_letad_endRecord:self.recordButton];
    } else {
        NSLog(@"%f", value);
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:kRecordCenter radius:(kRoundWidth - 10) / 2 + 16 startAngle:- M_PI_2 endAngle:2 * M_PI * (value) - M_PI_2 clockwise:YES];
        self.progressLayer.path = path.CGPath;
    }
}

- (void)focusLayerNormal {
    self.cameraView.userInteractionEnabled = YES;
    _focusLayer.hidden = YES;
}

- (void)layerAnimationWithPoint:(CGPoint)point {
    [_focusLayer removeAllAnimations];
    if (_focusLayer) {
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
    }
}

#pragma mark - Lazy Property

- (GPUImageFilterGroup *)normalFilter {
    if (!_normalFilter) {
        GPUImageFilter *filter = [[GPUImageFilter alloc] init];
        _normalFilter = [[GPUImageFilterGroup alloc] init];
        [(GPUImageFilterGroup *) _normalFilter setInitialFilters:[NSArray arrayWithObject: filter]];
        [(GPUImageFilterGroup *) _normalFilter setTerminalFilter:filter];
    }
    
    return _normalFilter;
}

- (GPUImageStillCamera *)videoCamera {
    if (!_videoCamera) {
//        AVCaptureDevicePosition position = _viewmodel.useCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
        _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:position];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        [_videoCamera addAudioInputsAndOutputs];
    }
    return _videoCamera;
}

- (NSString *)moviePath {
    if (!_moviePath) {
        _moviePath = kVideoPath;
//        NSLog(@"maru: %@",_moviePath);
    }
    return _moviePath;
}

- (CTMSGBeautyFilter *)leveBeautyFilter {
    if (!_leveBeautyFilter) {
        _leveBeautyFilter = [[CTMSGBeautyFilter alloc] init];
    }
    return _leveBeautyFilter;
}

- (NSDictionary *)audioSettings {
    if (!_audioSettings) {
        AudioChannelLayout channelLayout;
        memset(&channelLayout, 0, sizeof(AudioChannelLayout));
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
        _audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                          [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                          [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
                          [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,
                          [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                          [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,
                          nil];
    }
    return _audioSettings;
}

- (NSMutableDictionary *)videoSettings {
    if (!_videoSettings) {
        _videoSettings = [[NSMutableDictionary alloc] init];
        [_videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
        [_videoSettings setObject:[NSNumber numberWithInteger:kCameraWidth] forKey:AVVideoWidthKey];
        [_videoSettings setObject:[NSNumber numberWithInteger:kCameraHeight] forKey:AVVideoHeightKey];
    }
    return _videoSettings;
}

#pragma mark - lazy uiview property

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}


- (UIButton *)commitButton {
    if (!_commitButton) {
        _commitButton = ({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [b addTarget:self action:@selector(p_letad_commitAction:) forControlEvents:UIControlEventTouchUpInside];
            [b setImage:[UIImage imageNamed:@"letad_aremac_6"] forState:UIControlStateNormal];
            b.frame = CGRectMake(0, 0, kRoundWidth, kRoundWidth);
//            b.right = self.view.frame.size.width - kLeftInterval;
//            b.bottom = self.view.frame.size.height - kLeftInterval;
            b;
        });
    }
    return _commitButton;
}


- (UIButton *)recaptureButton {
    if (!_recaptureButton) {
        _recaptureButton = ({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b setImage:[UIImage imageNamed:@"letad_aremac_4"] forState:UIControlStateNormal];
            [b addTarget:self action:@selector(p_letad_recaptureAction) forControlEvents:UIControlEventTouchUpInside];
            b.bounds = CGRectMake(0, 0, kRoundWidth, kRoundWidth);
//            b.left = kLeftInterval;
//            b.bottom = self.view.frame.size.height - kLeftInterval;
            b;
        });
    }
    return _recaptureButton;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = ({
            CAShapeLayer *l = [CAShapeLayer layer];
            l.lineWidth = 5.0f;
            l.fillColor = nil;
            l.strokeColor = [UIColor whiteColor].CGColor;
            l.lineCap = kCALineCapRound;
            l;
        });
    }
    return _progressLayer;
}

//- (LETADBeautySlider *)beautySlider {
//    if (!_beautySlider) {
//        _beautySlider = ({
//            LETADBeautySlider * slider = [[LETADBeautySlider alloc] init];
//            slider.minimumValue = 0;
//            slider.maximumValue = 100;
//            [slider setThumbImage:[UIImage imageNamed:@"letad_aremac_3"] forState:UIControlStateNormal];
//            [slider addTarget:self action:@selector(p_letad_beautyValueChanged:) forControlEvents:UIControlEventValueChanged];
//            slider.frame = CGRectMake(2 , LETADSCREENHEIGHT / 2, LETADSCREENWIDTH - 6, 8);
//            [slider setMinimumTrackImage:[UIImage imageNamed:@"letad_aremac_1"] forState:UIControlStateNormal];
//            [slider setMaximumTrackImage:[UIImage imageNamed:@"letad_aremac_2"] forState:UIControlStateNormal];
//            slider.value = 50;
//            slider.frame = CGRectMake(LETADSCREENWIDTH / 2 - 25 , LETADSCREENHEIGHT / 2, LETADSCREENWIDTH, 8);
//            slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
//            [self.view addSubview:slider];
//            slider;
//        });
//    }
//    return _beautySlider;
//}

- (UIButton *)cameraSwitch {
    if (!_cameraSwitch) {
        _cameraSwitch = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"letad_aremac_9"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(p_letad_turnAction:) forControlEvents:UIControlEventTouchUpInside];
//            button.hidden = !_viewmodel.isSwitchCamera;
            button;
        });
    }
    return _cameraSwitch;
}


- (CALayer *)focusLayer {
    if (!_focusLayer) {
        UIImage *focusImage = [UIImage imageNamed:@"letad_aremac_7"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
        imageView.image = focusImage;
        _focusLayer = imageView.layer;
        _focusLayer.hidden = YES;
    }
    return _focusLayer;
}


- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - getter

- (NSString *)videoPath {
    NSString * path = kVideoPath;
    return path;
}

- (NSString *)compresedVideoPath {
    NSString * path = kCompressVideoPath
    return path;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"🤩🤩🤩LETADCameraViewController deallc🤩🤩🤩");
}

@end
