//
//  CTMSGPhotoModel.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGPhotoModel.h"
#import "CTMSGAlbumTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CTMSGUtilities.h"
#import "UIImage+CTMSG_Cat.h"

@implementation CTMSGPhotoModel

- (NSDate *)creationDate {
    return [self.asset valueForKey:@"creationDate"];
}

- (NSDate *)modificationDate {
    return [self.asset valueForKey:@"modificationDate"];
}

- (NSData *)locationData {
    return [self.asset valueForKey:@"locationData"];
}

- (CLLocation *)location {
    return [self.asset valueForKey:@"location"];
}

+ (instancetype)photoModelWithPHAsset:(PHAsset *)asset {
    return [[self alloc] initWithPHAsset:asset];
}

+ (instancetype)photoModelWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

+ (instancetype)photoModelWithVideoURL:(NSURL *)videoURL videoTime:(NSTimeInterval)videoTime {
    return [[self alloc] initWithVideoURL:videoURL videoTime:videoTime];
}

- (instancetype)initWithPHAsset:(PHAsset *)asset{
    if (self = [super init]) {
        self.asset = asset;
        self.type = CTMSGPhotoModelMediaTypePhoto;
        self.type = CTMSGPhotoModelMediaSubTypePhoto;
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL videoTime:(NSTimeInterval)videoTime {
    if (self = [super init]) {
        self.type = CTMSGPhotoModelMediaTypeVideo;
        self.subType = CTMSGPhotoModelMediaSubTypeVideo;
        self.videoURL = videoURL;
//        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL] ;
//        player.shouldAutoplay = NO;
//        UIImage  *image = [player thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
        NSString *time = [CTMSGAlbumTool getNewTimeFromDurationSecond:videoTime];
        self.videoURL = videoURL;
        self.videoTime = time;
//        self.thumbPhoto = image;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.type = CTMSGPhotoModelMediaTypePhoto;
        self.subType = CTMSGPhotoModelMediaSubTypePhoto;
        if (image.imageOrientation != UIImageOrientationUp) {
            image = [image normalizedImage];
        }
        self.thumbPhoto = image;
        self.previewPhoto = image;
        self.imageSize = image.size;
    }
    return self;
}

- (CGSize)imageSize {
    if (_imageSize.width == 0 || _imageSize.height == 0) {
        if (self.asset) {
            _imageSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
        }else {
            _imageSize = self.thumbPhoto.size;
        }
    }
    return _imageSize;
}

- (float)videoSecond {
    if (!_videoSecond) {
        NSString *timeLength = [NSString stringWithFormat:@"%0.0f",self.asset.duration];
        _videoSecond = timeLength.floatValue;
    }
    return _videoSecond;
}

- (NSString *)videoTime {
    if (!_videoTime) {
        NSString *timeLength = [NSString stringWithFormat:@"%0.0f",self.asset.duration];
        _videoTime = [CTMSGAlbumTool getNewTimeFromDurationSecond:timeLength.integerValue];
    }
    return _videoTime;
}

- (NSString *)localIdentifier {
    if (!_localIdentifier) {
        _localIdentifier = self.asset.localIdentifier;
    }
    return _localIdentifier;
}

- (CGSize)endImageSize {
    if (_endImageSize.width == 0 || _endImageSize.height == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height - CTMSGNavBarHeight;
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        CGFloat w;
        CGFloat h;
        imgHeight = width / imgWidth * imgHeight;
        if (imgHeight > height) {
            w = height / self.imageSize.height * imgWidth;
            h = height;
        } else {
            w = width;
            h = imgHeight;
        }
        _endImageSize = CGSizeMake(w, h);
    }
    return _endImageSize;
}

- (CGSize)endDateImageSize {
    if (_endDateImageSize.width == 0 || _endDateImageSize.height == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height - kTopMargin - kBottomMargin;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
            if (CTMSG_IS_IPHONEXORLATER) {
                height = [UIScreen mainScreen].bounds.size.height - kTopMargin - 21;
            }
        }
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        CGFloat w;
        CGFloat h;
        imgHeight = width / imgWidth * imgHeight;
        if (imgHeight > height) {
            w = height / self.imageSize.height * imgWidth;
            h = height;
        } else {
            w = width;
            h = imgHeight;
        }
        _endDateImageSize = CGSizeMake(w, h);
    }
    return _endDateImageSize;
}

- (CGSize)requestSize {
    if (_requestSize.width == 0 || _requestSize.height == 0) {
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 1 * self.rowCount - 1 ) / self.rowCount;
//        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 1 * 2 ) / 3;
        CGSize size;
        //        if (self.imageSize.width > self.imageSize.height / 9 * 15) {
        //            size = CGSizeMake(width, width * [UIScreen mainScreen].scale);
        //        }else if (self.imageSize.height > self.imageSize.width / 9 * 15) {
        //            size = CGSizeMake(width * [UIScreen mainScreen].scale, width);
        //        }else {
        if ([UIScreen mainScreen].bounds.size.width == 375) {
            size = CGSizeMake(width * 1.4, width * 1.4);
        } else {
            size = CGSizeMake(width * 1.7, width * 1.7);
        }
        //        }
        if ([UIScreen mainScreen].bounds.size.width == 320) {
            size = CGSizeMake(width * 0.8, width * 0.8);
        }
        _requestSize = size;
    }
    return _requestSize;
}

- (CGSize)dateBottomImageSize {
    if (_dateBottomImageSize.width == 0 || _dateBottomImageSize.height == 0) {
        CGFloat width = 0;
        CGFloat height = 50;
        CGFloat imgWidth = self.imageSize.width;
        CGFloat imgHeight = self.imageSize.height;
        if (imgHeight > height) {
            width = imgWidth * (height / imgHeight);
        }else {
            width = imgWidth * (imgHeight / height);
        }
        if (width < 50 / 16 * 9) {
            width = 50 / 16 * 9;
        }
        _dateBottomImageSize = CGSizeMake(width, height);
    }
    return _dateBottomImageSize;
}

- (NSString *)barTitle {
    if (!_barTitle) {
        if ([self.creationDate isToday]) {
            _barTitle = @"今天";
        }else if ([self.creationDate isYesterday]) {
            _barTitle = @"昨天";
        }else if ([self.creationDate isSameWeek]) {
            _barTitle = [self.creationDate getNowWeekday];
        }else if ([self.creationDate isThisYear]) {
            _barTitle = [NSString stringWithFormat:@"%@ %@",[self.creationDate dateStringWithFormat:@"MM月dd日"],[self.creationDate getNowWeekday]];
        }else {
            _barTitle = [self.creationDate dateStringWithFormat:@"yyyy年MM月dd日"];
        }
    }
    return _barTitle;
}

- (NSString *)barSubTitle {
    if (!_barSubTitle) {
        _barSubTitle = [self.creationDate dateStringWithFormat:@"HH:mm"];
    }
    return _barSubTitle;
}

- (void)dealloc {
    //    [self cancelImageRequest];
}

@end
