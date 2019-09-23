//
//  CTMSGPhotoPreviewViewCell.m
//  微博照片选择
//
//  Created by 洪欣 on 17/2/9.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "CTMSGPhotoPreviewViewCell.h"
#import "CTMSGAlbumTool.h"
#import "UIImage+CTMSG_Cat.h"
#import "CTMSGCircleProgressView.h"

@interface CTMSGPhotoPreviewViewCell ()<UIScrollViewDelegate,PHLivePhotoViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGPoint imageCenter;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView NS_AVAILABLE_IOS(9.1);
@property (strong, nonatomic) UIImage *gifImage;
@property (assign, nonatomic) PHImageRequestID requestID;
@property (assign, nonatomic) PHImageRequestID longRequestId;
@property (strong, nonatomic) CTMSGCircleProgressView *progressView;
@property (assign, nonatomic) PHImageRequestID liveRequestID;

@end

@implementation CTMSGPhotoPreviewViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.requestID = 0;
        self.longRequestId = 0;
        [self p_ctmsg_setup];
    }
    return self;
}
#pragma mark - < 懒加载 >
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.ct_w, self.ct_h)];
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
        _scrollView.contentSize = CGSizeMake(self.ct_w, self.ct_h);
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:tap2];
    }
    return _scrollView;
}
- (CTMSGCircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CTMSGCircleProgressView alloc] init];
        _progressView.hidden = YES;
    }
    return _progressView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (PHLivePhotoView *)livePhotoView NS_AVAILABLE_IOS(9.1) {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.clipsToBounds = YES;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.delegate = self;
    }
    return _livePhotoView;
}
- (void)p_ctmsg_setup {
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    if (@available(iOS 9.1, *)) {
        [self.scrollView addSubview:self.livePhotoView];
    } else {
        // Fallback on earlier versions
    }
    [self.contentView addSubview:self.progressView];
}
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle NS_AVAILABLE_IOS(9.1) {
    self.isAnimating = YES;
}
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle NS_AVAILABLE_IOS(9.1) {
    [self stopLivePhoto];
}
- (void)startLivePhoto {
    if (self.isAnimating) {
        return;
    }
//    if (self.liveRequestID) {
//        [[PHImageManager defaultManager] cancelImageRequest:self.liveRequestID];
//        self.liveRequestID = -1;
//    }
//    [self.scrollView addSubview:self.livePhotoView];
    if (@available(iOS 9.1, *)) {
        if (self.livePhotoView.livePhoto) {
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }else {
            [[PHImageManager defaultManager] cancelImageRequest:self.liveRequestID];
            __weak typeof(self) weakSelf = self;
            self.liveRequestID = [CTMSGAlbumTool fetchLivePhotoForPHAsset:self.model.asset size:CGSizeMake(self.model.endImageSize.width, self.model.endImageSize.height) completion:^(PHLivePhoto * _Nonnull livePhoto, NSDictionary * _Nonnull info) {
                weakSelf.livePhotoView.livePhoto = livePhoto;
                [weakSelf.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
            }];
        }
    } else {
        // Fallback on earlier versions
    }
}
- (void)stopLivePhoto {
    self.isAnimating = NO;
    if (@available(iOS 9.1, *)) {
        [self.livePhotoView stopPlayback];
    } else {
        // Fallback on earlier versions
    }
}
- (void)fetchLongPhoto {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = self.model.imageSize.width;
    CGFloat imgHeight = self.model.imageSize.height;
    PHImageRequestID requestID;
    CGSize size;
    __weak typeof(self) weakSelf = self;
    if (imgHeight > imgWidth / 9 * 17) {
        size = CGSizeMake(width, height);
    }else {
        size = CGSizeMake(_model.endImageSize.width * 2.0, _model.endImageSize.height * 2.0);
    }
    requestID = [CTMSGAlbumTool getHighQualityFormatPhoto:self.model.asset size:size startRequestIcloud:^(PHImageRequestID cloudRequestId) {
        weakSelf.longRequestId = cloudRequestId;
        weakSelf.progressView.hidden = NO;
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
    if (self.longRequestId != requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.longRequestId];
        self.longRequestId = requestID;
    }
}

- (void)startGifImage {
    self.imageView.image = self.gifImage;
}

- (void)stopGifImage {
    self.imageView.image = nil;
    self.imageView.image = self.firstImage;
}

- (void)setModel:(CTMSGPhotoModel *)model {
    _model = model;
    self.progressView.hidden = YES;
    self.gifImage = nil;
    if (self.longRequestId) {
        [[PHImageManager defaultManager] cancelImageRequest:self.longRequestId];
        self.longRequestId = -1;
    }
    self.imageView.hidden = NO;
    [self.scrollView setZoomScale:1.0 animated:NO];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = model.imageSize.width;
    CGFloat imgHeight = model.imageSize.height;
    CGFloat w;
    CGFloat h;
    
    imgHeight = width / imgWidth * imgHeight;
    if (imgHeight > height) {
        w = height / model.imageSize.height * imgWidth;
        h = height;
        self.scrollView.maximumZoomScale = width / w + 0.5;
    }else {
        w = width;
        h = imgHeight;
        self.scrollView.maximumZoomScale = 2.5;
    }
    _imageView.frame = CGRectMake(0, 0, w, h);
    _imageView.center = CGPointMake(width / 2, height / 2);
    if (@available(iOS 9.1, *)) {
        self.livePhotoView.frame = self.imageView.frame;
        self.livePhotoView.hidden = YES;
    } else {
        // Fallback on earlier versions
    }
    
    self.imageView.hidden = NO;
    if (model.type == CTMSGPhotoModelMediaTypeGif) {
        if (model.tempImage) {
            self.imageView.image = model.tempImage;
        }
        __weak typeof(self) weakSelf = self;
        [CTMSGAlbumTool fetchPhotoDataForPHAsset:model.asset completion:^(NSData *imageData, NSDictionary *info) {
            UIImage *gifImage = [UIImage animatedGIFWithData:imageData];
            if (gifImage.images.count == 0) {
                weakSelf.firstImage = gifImage;
                weakSelf.imageView.image = gifImage;
            }else {
                weakSelf.firstImage = gifImage.images.firstObject;
                weakSelf.imageView.image = weakSelf.firstImage;
            }
            weakSelf.model.tempImage = nil;
            weakSelf.gifImage = gifImage;
        }];
    } else {
//        if (model.type == CTMSGPhotoModelMediaTypeCameraPhoto) {
//            self.imageView.image = model.thumbPhoto;
//            model.tempImage = nil;
//        } else {
            if (model.type == CTMSGPhotoModelMediaTypeLive) {
                if (@available(iOS 9.1, *)) {
                    self.livePhotoView.hidden = NO;
                } else {
                    // Fallback on earlier versions
                }
                self.imageView.hidden = YES;
                __weak typeof(self) weakSelf = self;
                if (@available(iOS 9.1, *)) {
                    self.liveRequestID = [CTMSGAlbumTool fetchLivePhotoForPHAsset:self.model.asset size:CGSizeMake(self.model.endImageSize.width, self.model.endImageSize.height) completion:^(PHLivePhoto * _Nonnull livePhoto, NSDictionary * _Nonnull info) {
                        weakSelf.livePhotoView.livePhoto = livePhoto;
                    }];
                } else {
                    // Fallback on earlier versions
                }
                
                if (model.tempImage) {
                    self.imageView.image = model.tempImage;
                    model.tempImage = nil;
                }else {
                    self.requestID = [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(width * 0.5, height * 0.5) completion:^(UIImage *image, NSDictionary *info) {
                        weakSelf.imageView.image = image;
                    }];
                }
            } else {
                if (model.previewPhoto) {
                    self.imageView.image = model.previewPhoto;
                    model.tempImage = nil;
                }else {
                    if (model.tempImage) {
                        self.imageView.image = model.tempImage;
                        model.tempImage = nil;
                    }else {
                        __weak typeof(self) weakSelf = self;
                        PHImageRequestID requestID;
                        if (imgHeight > imgWidth / 9 * 17) {
                            requestID = [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(width * 0.6, height * 0.6) completion:^(UIImage *image, NSDictionary *info) {
                                weakSelf.imageView.image = image;
                            }];
                        }else {
                            requestID = [CTMSGAlbumTool getPhotoForPHAsset:model.asset size:CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8) completion:^(UIImage *image, NSDictionary *info) {
                                weakSelf.imageView.image = image;
                            }];
                        }
                        if (self.requestID != requestID) {
                            [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
                        }
                        self.requestID = requestID;
                    }
                }
            }
//        }
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
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = width / newZoomScale;
        CGFloat ysize = height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - 返回需要缩放的控件
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.model.type == CTMSGPhotoModelMediaTypeLive) {
        if (@available(iOS 9.1, *)) {
            return self.livePhotoView;
        } else {
            return [UIView new];
        }
    } else {
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

- (void)updateImageSize {
    [_scrollView setZoomScale:1.0 animated:NO];
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
    }else {
        w = width;
        h = imgHeight;
    }
    _imageView.frame = CGRectMake(0, 0, w, h);
    _imageView.center = CGPointMake(width / 2, height / 2);
    _imageCenter = _imageView.center;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.progressView.center = CGPointMake(width / 2, height / 2); 
}
- (void)dealloc {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
    if (self.liveRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.liveRequestID];
        self.liveRequestID = -1;
    }
    if (self.longRequestId) {
        [[PHImageManager defaultManager] cancelImageRequest:self.longRequestId];
        self.longRequestId = -1;
    }
}
@end
