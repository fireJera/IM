//
//  CTMSGPhotoPreviewViewCell.h
//  微博照片选择
//
//  Created by 洪欣 on 17/2/9.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMSGPhotoModel.h"
#import <PhotosUI/PhotosUI.h>
@interface CTMSGPhotoPreviewViewCell : UICollectionViewCell
@property (strong, nonatomic) CTMSGPhotoModel *model;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic, readonly) PHLivePhotoView *livePhotoView NS_AVAILABLE_IOS(9.1);
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic, readonly) PHImageRequestID requestID;
@property (assign, nonatomic, readonly) PHImageRequestID longRequestId;
@property (assign, nonatomic, readonly) PHImageRequestID liveRequestID;
@property (strong, nonatomic) UIImage *firstImage;
- (void)startLivePhoto;
- (void)stopLivePhoto;
- (void)startGifImage;
- (void)stopGifImage;
- (void)fetchLongPhoto;
@end
