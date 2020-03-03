//
//  CTMSGDatePhotoPreviewViewController.m
//  微博照片选择
//
//  Created by 洪欣 on 2017/10/14.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "CTMSGDatePhotoPreviewViewController.h"
#import "UIImage+CTMSG_Cat.h"
#import "CTMSGPhotoModel.h"
#import "CTMSGAlbumTool.h"
#import "UIButton+CTMSG_Cat.h"
#import "CTMSGCircleProgressView.h"
//#import "UIView+INTCT_Frame.h"

#pragma mark - CTMSGDatePhotoPreviewViewCell

@interface CTMSGDatePhotoPreviewViewCell ()<UIScrollViewDelegate,PHLivePhotoViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGPoint imageCenter;
@property (strong, nonatomic) UIImage *gifImage;
@property (strong, nonatomic) UIImage *gifFirstFrame;
@property (assign, nonatomic) PHImageRequestID requestID;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView NS_AVAILABLE_IOS(9.1);
@property (assign, nonatomic) BOOL livePhotoAnimating;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) UIButton *videoPlayBtn;
@property (strong, nonatomic) CTMSGCircleProgressView *progressView;
@end

@implementation CTMSGDatePhotoPreviewViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.requestID = -1;
        [self p_ctmsg_setup];
    }
    return self;
}
- (void)p_ctmsg_setup {
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.contentView.layer addSublayer:self.playerLayer];
    [self.contentView addSubview:self.videoPlayBtn];
    //    [self.scrollView addSubview:self.livePhotoView];
    [self.contentView addSubview:self.progressView];
}
- (void)resetScale {
    [self.scrollView setZoomScale:1.0 animated:NO];
}
- (void)setModel:(CTMSGPhotoModel *)model {
    _model = model;
    [self cancelRequest];
    self.playerLayer.player = nil;
    self.player = nil;
    self.progressView.hidden = YES;
    self.progressView.progress = 0;
    self.videoPlayBtn.userInteractionEnabled = YES;
    
    [self resetScale];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    CGFloat w;
    CGFloat h;
    
    imgHeight = width / imgWidth * imgHeight;
    if (imgHeight > height) {
        w = height / self.model.imageSize.height * imgWidth;
        h = height;
        self.scrollView.maximumZoomScale = width / w + 0.5;
    }else {
        w = width;
        h = imgHeight;
        self.scrollView.maximumZoomScale = 2.5;
    }
    self.imageView.frame = CGRectMake(0, 0, w, h);
    self.imageView.center = CGPointMake(width / 2, height / 2);
    
    self.imageView.hidden = NO;
    __weak typeof(self) weakSelf = self;
    if (model.type == CTMSGPhotoModelMediaTypeGif) {
        if (model.tempImage) {
            self.imageView.image = model.tempImage;
        }
        self.requestID = [CTMSGAlbumTool fetchPhotoDataForPHAsset:model.asset completion:^(NSData *imageData, NSDictionary *info) {
            UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
            if (gifImage.images.count == 0) {
                weakSelf.gifFirstFrame = gifImage;
                weakSelf.imageView.image = gifImage;
            }else {
                weakSelf.gifFirstFrame = gifImage.images.firstObject;
                weakSelf.imageView.image = weakSelf.gifFirstFrame;
            }
            weakSelf.model.tempImage = nil;
            weakSelf.gifImage = gifImage;
        }];
        self.requestID = [CTMSGAlbumTool getImageData:model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.hidden = NO;
                weakSelf.requestID = cloudRequestId;
            });
        } progressHandler:^(double progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.hidden = NO;
                weakSelf.progressView.progress = progress;
            });
        } completion:^(NSData *imageData, UIImageOrientation orientation) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
                if (gifImage.images.count == 0) {
                    weakSelf.gifFirstFrame = gifImage;
                    weakSelf.imageView.image = gifImage;
                }else {
                    weakSelf.gifFirstFrame = gifImage.images.firstObject;
                    weakSelf.imageView.image = weakSelf.gifFirstFrame;
                }
                weakSelf.model.tempImage = nil;
                weakSelf.gifImage = gifImage;
            });
        } failed:^(NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.hidden = YES;
            });
        }];
    }else {
//        if (model.type == CTMSGPhotoModelMediaTypeCameraPhoto || model.type == CTMSGPhotoModelMediaTypeCameraVideo) {
//            self.imageView.image = model.thumbPhoto;
//            model.tempImage = nil;
//        } else {
            if (model.type == CTMSGPhotoModelMediaTypeLive) {
                if (model.tempImage) {
                    self.imageView.image = model.tempImage;
                    model.tempImage = nil;
                }else {
                    self.requestID = [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(self.ct_w * 0.5, self.ct_h * 0.5) completion:^(UIImage *image, NSDictionary *info) {
                        weakSelf.imageView.image = image;
                    }];
                }
            }else {
                if (model.previewPhoto) {
                    self.imageView.image = model.previewPhoto;
                    model.tempImage = nil;
                }else {
                    if (model.tempImage) {
                        self.imageView.image = model.tempImage;
                        model.tempImage = nil;
                    }else {
                        PHImageRequestID requestID;
                        if (imgHeight > imgWidth / 9 * 17) {
                            requestID = [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(self.ct_w * 0.6, self.ct_h * 0.6) completion:^(UIImage *image, NSDictionary *info) {
                                weakSelf.imageView.image = image;
                            }];
                        }else {
                            requestID = [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8) completion:^(UIImage *image, NSDictionary *info) {
                                weakSelf.imageView.image = image;
                            }];
                        }
                        self.requestID = requestID;
                    }
                }
//            }
        }
    }
    if (model.subType == CTMSGPhotoModelMediaSubTypeVideo) {
        self.playerLayer.hidden = NO;
        self.videoPlayBtn.hidden = NO;
    } else {
        self.playerLayer.hidden = YES;
        self.videoPlayBtn.hidden = YES;
    }
}

- (void)requestHDImage {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    CGSize size;
    __weak typeof(self) weakSelf = self;
    if (imgHeight > imgWidth / 9 * 17) {
        size = CGSizeMake(width, height);
    }else {
        size = CGSizeMake(_model.endImageSize.width * 2.0, _model.endImageSize.height * 2.0);
    }
    if (self.model.type == CTMSGPhotoModelMediaTypeLive) {
        if (_livePhotoView.livePhoto) {
            if (@available(iOS 9.1, *)) {
                [self.livePhotoView stopPlayback];
            } else {
                // Fallback on earlier versions
            }
            if (@available(iOS 9.1, *)) {
                [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
            } else {
                // Fallback on earlier versions
            }
            return;
        }
        if (@available(iOS 9.1, *)) {
            self.requestID = [CTMSGAlbumTool fetchLivePhotoForPHAsset:self.model.asset size:self.model.endImageSize completion:^(PHLivePhoto *livePhoto, NSDictionary *info) {
                weakSelf.livePhotoView.frame = weakSelf.imageView.frame;
                [weakSelf.scrollView addSubview:weakSelf.livePhotoView];
                weakSelf.imageView.hidden = YES;
                weakSelf.livePhotoView.livePhoto = livePhoto;
                [weakSelf.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
            }];
        } else {
            // Fallback on earlier versions
        }
    }else if (self.model.type == CTMSGPhotoModelMediaTypePhoto) {
        self.requestID = [CTMSGAlbumTool getHighQualityFormatPhoto:self.model.asset size:size startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            weakSelf.progressView.hidden = NO;
            weakSelf.requestID = cloudRequestId;
        } progressHandler:^(double progress) {
            weakSelf.progressView.hidden = NO;
            weakSelf.progressView.progress = progress;
        } completion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.hidden = YES;
                weakSelf.imageView.image = image;
            });
        } failed:^(NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressView.hidden = YES;
            });
        }];
    }else if (self.model.type == CTMSGPhotoModelMediaTypeGif) {
        if (self.gifImage) {
            self.imageView.image = self.gifImage;
        }else {
            self.requestID = [CTMSGAlbumTool getImageData:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.progressView.hidden = NO;
                    weakSelf.requestID = cloudRequestId;
                });
            } progressHandler:^(double progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.progressView.hidden = NO;
                    weakSelf.progressView.progress = progress;
                });
            } completion:^(NSData *imageData, UIImageOrientation orientation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
                    if (gifImage.images.count == 0) {
                        weakSelf.gifFirstFrame = gifImage;
                        //                        weakSelf.imageView.image = gifImage;
                    }else {
                        weakSelf.gifFirstFrame = gifImage.images.firstObject;
                        //                        weakSelf.imageView.image = weakSelf.gifFirstFrame;
                    }
                    weakSelf.model.tempImage = nil;
                    weakSelf.imageView.image = gifImage;
                    weakSelf.gifImage = gifImage;
                });
            } failed:^(NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.progressView.hidden = YES;
                });
            }];
        }
    }
    if (self.player != nil) return;
    if (self.model.type == CTMSGPhotoModelMediaTypeVideo) {
        self.requestID = [CTMSGAlbumTool getPlayerItemWithPHAsset:self.model.asset startRequestIcloud:^(PHImageRequestID cloudRequestId) {
            weakSelf.progressView.hidden = NO;
            weakSelf.requestID = cloudRequestId;
            weakSelf.videoPlayBtn.userInteractionEnabled = NO;
        } progressHandler:^(double progress) {
            weakSelf.progressView.hidden = NO;
            weakSelf.progressView.progress = progress;
        } completion:^(AVPlayerItem *playerItem) {
            weakSelf.videoPlayBtn.userInteractionEnabled = YES;
            weakSelf.player = [AVPlayer playerWithPlayerItem:playerItem];
            weakSelf.playerLayer.player = weakSelf.player;
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(p_ctmsg_pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:weakSelf.player.currentItem];
        } failed:^(NSDictionary *info) {
            weakSelf.videoPlayBtn.userInteractionEnabled = YES;
            weakSelf.progressView.hidden = YES;
        }];
    }
//    else if (self.model.type == CTMSGPhotoModelMediaTypeCameraVideo ) {
//        self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:self.model.videoURL]];
//        self.playerLayer.player = self.player;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_ctmsg_pausePlayerAndShowNaviBar) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
//    }
}
- (void)p_ctmsg_pausePlayerAndShowNaviBar {
    [self.player pause];
    self.videoPlayBtn.selected = NO;
    [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
}
- (void)cancelRequest {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    self.progressView.hidden = YES;
    self.progressView.progress = 0;
    self.videoPlayBtn.userInteractionEnabled = YES;
    if (self.model.type == CTMSGPhotoModelMediaTypeLive) {
        if (_livePhotoView.livePhoto) {
            if (@available(iOS 9.1, *)) {
                self.livePhotoView.livePhoto = nil;
                [self.livePhotoView removeFromSuperview];
            } else {
                // Fallback on earlier versions
            }
            
            self.imageView.hidden = NO;
            [self stopLivePhoto];
        }
    }else if (self.model.type == CTMSGPhotoModelMediaTypePhoto) {
        
    }else if (self.model.type == CTMSGPhotoModelMediaTypeGif) {
        self.imageView.image = nil;
        self.gifImage = nil;
        self.imageView.image = self.gifFirstFrame;
    }
    if (self.model.subType == CTMSGPhotoModelMediaSubTypeVideo) {
        if (self.player != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            [self.player pause];
            self.videoPlayBtn.selected = NO;
            [self.player seekToTime:kCMTimeZero];
            self.playerLayer.player = nil;
            self.player = nil;
        }
    }
}
- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.cellTapClick) {
        self.cellTapClick();
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        CGPoint touchPoint;
        if (self.model.type == CTMSGPhotoModelMediaTypeLive) {
            if (@available(iOS 9.1, *)) {
                touchPoint = [tap locationInView:self.livePhotoView];
            } else {
                // Fallback on earlier versions
            }
        }else {
            touchPoint = [tap locationInView:self.imageView];
        }
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = width / newZoomScale;
        CGFloat ysize = height / newZoomScale;
        
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}
#pragma mark - < PHLivePhotoViewDelegate >
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle NS_AVAILABLE_IOS(9.1) {
    self.livePhotoAnimating = YES;
}
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle NS_AVAILABLE_IOS(9.1) {
    [self stopLivePhoto];
}
- (void)stopLivePhoto {
    self.livePhotoAnimating = NO;
    if (@available(iOS 9.1, *)) {
        [self.livePhotoView stopPlayback];
    } else {
        // Fallback on earlier versions
    }
}
#pragma mark - < UIScrollViewDelegate >

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.model.type == CTMSGPhotoModelMediaTypeLive) {
        if (@available(iOS 9.1, *)) {
            return self.livePhotoView;
        } else {
            // Fallback on earlier versions
            return [UIView new];
        }
    }else {
        return self.imageView;
    }
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    if (self.model.type == CTMSGPhotoModelMediaTypeLive) {
        if (@available(iOS 9.1, *)) {
            self.livePhotoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
        } else {
            // Fallback on earlier versions
        }
    }else {
        self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    }
}
- (void)didPlayBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.player play];
    }else {
        [self.player pause];
    }
    if (self.cellDidPlayVideoBtn) {
        self.cellDidPlayVideoBtn(button.selected);
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.playerLayer.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.ct_w, self.ct_h);
    self.progressView.center = CGPointMake(self.ct_w / 2, self.ct_h / 2);
}

#pragma mark - lazy property
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.minimumZoomScale = 1;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [_scrollView addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [_scrollView addGestureRecognizer:tap2];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}
- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.clipsToBounds = YES;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.delegate = self;
    }
    return _livePhotoView;
}
- (UIButton *)videoPlayBtn {
    if (!_videoPlayBtn) {
        _videoPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoPlayBtn setImage:[CTMSGAlbumTool ctmsg_imageNamed:@"multimedia_videocard_play@2x.png"] forState:UIControlStateNormal];
        [_videoPlayBtn setImage:[[UIImage alloc] init] forState:UIControlStateSelected];
        [_videoPlayBtn addTarget:self action:@selector(didPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _videoPlayBtn.frame = self.bounds;
        _videoPlayBtn.hidden = YES;
    }
    return _videoPlayBtn;
}
- (CTMSGCircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CTMSGCircleProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}
- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.hidden = YES;
    }
    return _playerLayer;
}


- (void)dealloc {
    [self cancelRequest];
}
@end
