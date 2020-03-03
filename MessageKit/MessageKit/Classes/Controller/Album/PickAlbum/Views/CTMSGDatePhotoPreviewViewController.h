//
//  CTMSGDatePhotoPreviewViewController.h
//  微博照片选择
//
//  Created by 洪欣 on 2017/10/14.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import "CTMSGAlbumManager.h"

//@class CTMSGDatePhotoPreviewViewController,CTMSGDatePhotoPreviewBottomView,CTMSGDatePhotoPreviewViewCell,CTMSGPhotoView;
//@protocol CTMSGDatePhotoPreviewViewControllerDelegate <NSObject>
//@optional
//- (void)datePhotoPreviewControllerDidSelect:(CTMSGDatePhotoPreviewViewController *)previewController model:(CTMSGPhotoModel *)model;
//- (void)datePhotoPreviewControllerDidDone:(CTMSGDatePhotoPreviewViewController *)previewController;
//@end

@interface CTMSGDatePhotoPreviewViewCell : UICollectionViewCell
@property (strong, nonatomic) CTMSGPhotoModel *model;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic, readonly) UIImage *gifImage;
@property (assign, nonatomic) BOOL dragging;
@property (nonatomic, copy) void (^cellTapClick)(void);
@property (nonatomic, copy) void (^cellDidPlayVideoBtn)(BOOL play);

- (void)resetScale;
- (void)requestHDImage;
- (void)cancelRequest;
@end
