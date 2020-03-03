
//
//  YYPhotoGroupCell.m
//  Orange
//
//  Created by JerRen on 28/01/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import "YYPhotoGroupCell.h"
#import <AVFoundation/AVFoundation.h>
#import "YYAnimatedImageView.h"
#import "YYCGUtilities.h"
#import "YYPhotoGroupItem.h"
#import "CALayer+YYAdd.h"
#import "UIView+YYAdd.h"
#import "YYWebImage.h"
//#import "LETADAlbum.h"

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

@interface YYPhotoGroupCell () <UIScrollViewDelegate> {
    struct {
        unsigned int cellScrollViewDidScroll : 1;
        unsigned int cellScrollViewDidEndScroll : 1;
    } _delegateFlags;
    AVPlayerLayer *_avplayer;
}

@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, readonly) BOOL itemDidLoad;

//播放器
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) UIImageView * playerStatus;

@end

@implementation YYPhotoGroupCell

- (instancetype)init {
    self = super.init;
    if (!self) return nil;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.multipleTouchEnabled = YES;
    self.alwaysBounceVertical = NO;
    self.bouncesZoom = YES;
    self.maximumZoomScale = 3;
    self.frame = [UIScreen mainScreen].bounds;
    self.delegate = self;
    _imageContainerFace = [UIView new];
    _imageContainerFace.clipsToBounds = YES;
    
    _imageView = [YYAnimatedImageView new];
    _imageView.clipsToBounds = YES;
#pragma mark - 一开始展现的颜色 要修改可以改这里
    _imageView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:1.000];
    [_imageContainerFace addSubview:_imageView];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.size = CGSizeMake(40, 40);
    _progressLayer.cornerRadius = 20;
    _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.lineWidth = 2;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.hidden = YES;
    _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    _progressLayer.path = path.CGPath;
    
    [self addSubview:_imageContainerFace];
    [self.layer addSublayer:_progressLayer];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.center = CGPointMake(self.width / 2, self.height / 2);
}

- (void)setScrollDelegate:(id<YYPhotoScrolleDelegate>)scrollDelegate {
    _scrollDelegate = scrollDelegate;
    _delegateFlags.cellScrollViewDidScroll = [_scrollDelegate respondsToSelector:@selector(letad_cellScrollViewDidScroll:)];
    _delegateFlags.cellScrollViewDidEndScroll = [_scrollDelegate respondsToSelector:@selector(letad_cellScrollViewDidEndScroll:)];
}

- (void)setItem:(YYPhotoGroupItem *)item {
    if (_item == item) return;
    self.scrollEnabled = YES;
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 1;
//    _imageView.hidden = NO;
    [_avplayer removeFromSuperlayer];
    _itemDidLoad = NO;
    _item = item;
    
    [_imageView yy_cancelCurrentImageRequest];
    
    _progressLayer.hidden = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressLayer.strokeEnd = 0;
    _progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (!_item) {
        _imageView.image = nil;
        return;
    }
    
    @weakify(self);
    if (!item.largeImageURL) {
        item.largeImageURL = [NSURL URLWithString:@""];
    }
    [_imageView yy_setImageWithURL:item.largeImageURL placeholder:item.thumbImage options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        @strongify(self);
        if (!self) return;
        CGFloat progress = receivedSize / (float)expectedSize;
        progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
        if (isnan(progress)) progress = 0;
        self.progressLayer.hidden = NO;
        self.progressLayer.strokeEnd = progress;
    } transform:nil completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        @strongify(self);
        if (!self) return;
        self.progressLayer.hidden = YES;
        if (stage == YYWebImageStageFinished) {
            self.maximumZoomScale = 3;
            if (image) {
                self->_itemDidLoad = YES;
                [self resizeSubviewSize];
                [self.imageView.layer addFadeAnimationWithDuration:0.1 curve:UIViewAnimationCurveLinear];
            }
        }
    }];
    
    [self resizeSubviewSize];
//    if (_item.album.isVideo) {
//        [self p_letad_setPlayer];
//        self.scrollEnabled = NO;
////        _imageView.hidden = YES;
//        self.maximumZoomScale = 1.0;
//    }
}

- (void)p_letad_setPlayer {
    _player = nil;
    _avplayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _avplayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _avplayer.contentsScale = [[UIScreen mainScreen] scale];
    _avplayer.frame = self.bounds;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.layer addSublayer:_avplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_letad_playbackFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player.currentItem];
}

- (void)p_letad_playbackFinished:(NSNotification *)notification {
    [_player pause];
    [self addSubview:self.playerStatus];
    [self.player.currentItem seekToTime:kCMTimeZero];
}

- (void)resizeSubviewSize {
    _imageContainerFace.width = self.width;
    _imageContainerFace.origin = CGPointZero;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.width) {
        _imageContainerFace.height = floor(image.size.height / (image.size.width / self.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        _imageContainerFace.height = height;
        _imageContainerFace.centerY = self.height / 2;
    }
    if (_imageContainerFace.height > self.height && _imageContainerFace.height - self.height <= 1) {
        _imageContainerFace.height = self.height;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _imageView.frame = _imageContainerFace.bounds;
    [CATransaction commit];
    
    self.contentSize = CGSizeMake(self.width, MAX(_imageContainerFace.height, self.height));
    [self scrollRectToVisible:self.bounds animated:NO];
    
    if (_imageContainerFace.height <= self.height) {
        self.alwaysBounceVertical = NO;
    } else {
        self.alwaysBounceVertical = YES;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerFace;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    UIView *subView = _imageContainerFace;
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == 1) {
        if (_delegateFlags.cellScrollViewDidScroll) {
            [_scrollDelegate letad_cellScrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.zoomScale == 1) {
        if (decelerate) {
            if (_delegateFlags.cellScrollViewDidEndScroll) {
                [_scrollDelegate letad_cellScrollViewDidEndScroll:scrollView];
            }
        }
    }
}

#pragma mark - tap
- (void)playVideo {
//    if (_item.album.isVideo) {
//        [self.player.currentItem seekToTime:kCMTimeZero];
//        [self.player play];
//    }
//    [_playerStatus removeFromSuperview];
}

- (void)pauseVideo {
//    if (_item.album.isVideo) [self.player pause];
}

- (void)resumePlayVideo {
//    if (_item.album.isVideo) {
//        [self.player play];
//    }
}

- (void)stopVideo {
//    if (!_item.album.isVideo) {
//        [_avplayer removeFromSuperlayer];
//        return;
//    }
    [self.player pause];
    [self.player.currentItem seekToTime:kCMTimeZero];
}

- (void)reverPlayerStatus {
    if (self.player.rate > 0 ) {
        [self pauseVideo];
        [self addSubview:self.playerStatus];
    } else {
        [self resumePlayVideo];
        [self.playerStatus removeFromSuperview];
    }
}

#pragma mark - lazy property
- (AVPlayer *)player
{
    if (!_player ) {
        AVPlayerItem *playerItem = [self getPlayItem];
        _player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    }
    return _player;
}

- (AVPlayerItem *)getPlayItem
{
    [[NSNotificationCenter defaultCenter] removeObserver:_player.currentItem];
    NSURL *saveUrl;
//    if (_item.album.link.length > 0) {
//        saveUrl = [NSURL URLWithString:_item.album.link];
//    }
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:saveUrl];
    return playerItem;
}

- (UIImageView *)playerStatus {
    if (!_playerStatus) {
        _playerStatus = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 53) / 2, (self.height - 60) / 2, 53, 60)];
        _playerStatus.contentMode = UIViewContentModeScaleAspectFit;
        _playerStatus.image = [UIImage imageNamed:@"letad_forall_13"];
    }
    return _playerStatus;
}

- (void)p_letad_releaseSub {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:_player.currentItem];
    [_player pause];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    });
    _avplayer = nil;
    _player = nil;
    [_avplayer removeFromSuperlayer];
}

- (void)dealloc {
    [self p_letad_releaseSub];
}

@end
