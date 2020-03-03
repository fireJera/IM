//
//  CTMSGPhotoViewCell.h
//  微博照片选择
//
//  Created by 洪欣 on 17/2/8.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class CTMSGPhotoModel;

@protocol CTMSGPhotoViewCellDelegate;

@interface CTMSGPhotoViewCell : UICollectionViewCell

@property (weak, nonatomic) id<CTMSGPhotoViewCellDelegate> delegate;

//@property (weak, nonatomic) id<UIViewControllerPreviewing> previewingContext;
@property (assign, nonatomic) BOOL firstRegisterPreview;
@property (assign, nonatomic) BOOL singleSelected;
@property (strong, nonatomic) CTMSGPhotoModel *model;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIButton *selectBtn;
@property (assign, nonatomic) PHImageRequestID requestID;
@property (copy, nonatomic) NSDictionary *iconDic;

@property (nonatomic, assign) NSInteger maxTime;
@property (nonatomic, assign) NSInteger minTime;

- (void)startLivePhoto;
- (void)stopLivePhoto;

- (void)cancelRequest;

@end

@protocol CTMSGPhotoViewCellDelegate <NSObject>

//- (void)didCameraClick;
- (void)cellDidSelectedBtnClick:(CTMSGPhotoViewCell *)cell Model:(CTMSGPhotoModel *)model;
- (void)cellChangeLivePhotoState:(CTMSGPhotoModel *)model;

@end
