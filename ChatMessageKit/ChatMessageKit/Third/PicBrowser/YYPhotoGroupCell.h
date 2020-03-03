//
//  YYPhotoGroupCell.h
//  Orange
//
//  Created by JerRen on 28/01/2018.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYAnimatedImageView;
@class YYPhotoGroupItem;

@protocol YYPhotoScrolleDelegate <NSObject>

- (void)letad_cellScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)letad_cellScrollViewDidEndScroll:(UIScrollView *)scrollView;

@end

@interface YYPhotoGroupCell : UIScrollView

@property (nonatomic, strong) UIView *imageContainerFace;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) YYPhotoGroupItem *item;

@property (nonatomic, weak) id<YYPhotoScrolleDelegate> scrollDelegate;

- (void)playVideo;
- (void)resumePlayVideo;
- (void)pauseVideo;
- (void)stopVideo;
- (void)reverPlayerStatus;

- (void)resizeSubviewSize;

@end
