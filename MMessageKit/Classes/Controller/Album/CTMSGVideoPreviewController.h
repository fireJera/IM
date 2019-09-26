//
//  CTMSGVideoPreviewController.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import "CTMSGAlbumManager.h"

@class CTMSGPhotoModel;
NS_ASSUME_NONNULL_BEGIN

@class CTMSGVideoPreviewController, CTMSGDatePhotoPreviewViewCell, CTMSGPhotoView, CTMSGAlbumManager;

@protocol CTMSGVideoPreviewControllerDelegate <NSObject>

@optional

//复选框选中
- (void)allPreviewdidSelectedClick:(CTMSGPhotoModel *)model AddOrDelete:(BOOL)state;
//右上角完成按钮
- (void)previewControllerDidSelect:(CTMSGVideoPreviewController *)previewController model:(CTMSGPhotoModel *)model;
//原来的bootomview 底部点击完成
- (void)previewControllerDidDone:(CTMSGVideoPreviewController *)previewController;
////上传视频 单个
//- (void)videoPreviewUpload:(CTMSGVideoPreviewController *)previewController success:(BOOL)isSuccess;
////上传图片
//- (void)imageUploadFromVideo:(UIImage *)originImage clipImage:(UIImage *)clipImage success:(BOOL)isSuccess;
//
////混合上传
//- (void)mixUploadFromAlbumPreview:(CTMSGVideoPreviewController *)previewController
//                        sendCount:(NSInteger)sendCount
//                        failCount:(NSInteger)failCount
//                      sendResults:(NSArray *)sendResults;

@end

@interface CTMSGVideoPreviewController : UIViewController
<UIViewControllerTransitioningDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) id<CTMSGVideoPreviewControllerDelegate> delegate;
@property (strong, nonatomic) CTMSGAlbumManager *manager;
@property (strong, nonatomic) NSMutableArray *modelArray;
@property (assign, nonatomic) NSInteger currentModelIndex;
@property (assign, nonatomic) BOOL outside;
@property (assign, nonatomic) BOOL selectPreview;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) CTMSGPhotoView *photoView;

@property (nonatomic, strong) CTMSGAlbumManager * albumManager;

- (CTMSGDatePhotoPreviewViewCell *)currentPreviewCell:(CTMSGPhotoModel *)model;
- (void)setSubviewAlphaAnimate:(BOOL)animete;
@end

NS_ASSUME_NONNULL_END
