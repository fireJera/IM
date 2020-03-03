//
//  CTMSGChatAlbumCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CTMSGPhotoModel;

@protocol CTMSGChatAlbumCellDelegate;

@interface CTMSGChatAlbumCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIButton * pickBtn;
@property (nonatomic, strong) CTMSGPhotoModel * model;

@property (nonatomic, weak) id<CTMSGChatAlbumCellDelegate> delegate;

@end

@protocol CTMSGChatAlbumCellDelegate <NSObject>

//- (void)didCameraClick;
- (void)cellDidSelectedBtnClick:(CTMSGChatAlbumCell *)cell model:(CTMSGPhotoModel *)model;
//- (void)cellChangeLivePhotoState:(CTMSGPhotoModel *)model;
@end

NS_ASSUME_NONNULL_END
