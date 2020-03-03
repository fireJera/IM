//
//  CTMSGAlbumListViewController.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CTMSGAlbumListViewControllerDelegate;

@class CTMSGAlbumManager, CTMSGPhotoViewCell, CTMSGPhotoModel;

@interface CTMSGAlbumListViewController : UIViewController

@property (strong, nonatomic) CTMSGAlbumManager *albumManager; // 照片管理类必须在跳转前赋值
@property (weak, nonatomic) id<CTMSGAlbumListViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray<CTMSGPhotoModel *> *videos;
@property (strong, nonatomic) NSMutableArray<CTMSGPhotoModel *> *objs;
@property (strong, nonatomic) NSMutableArray<CTMSGPhotoModel *> *photos;

@end

@protocol CTMSGAlbumListViewControllerDelegate <NSObject>

@optional

- (void)albumListViewControllerDidCancel:(CTMSGAlbumListViewController *)albumListViewController;
- (void)albumListViewControllerDidFinish:(CTMSGAlbumListViewController *)albumListViewController;

@end

NS_ASSUME_NONNULL_END
