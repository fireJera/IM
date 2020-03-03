//
//  CTMSGVideoPreviewController.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "CTMSGVideoPreviewController.h"
#import "UIButton+CTMSG_Cat.h"
#import "CTMSGPhotoCustomNavigationBar.h"
#import "CTMSGCircleProgressView.h"
#import "CTMSGPhotoModel.h"
#import "UIView+CTMSG_Cat.h"
#import "NSBundle+CTMSG_Cat.h"
#import "CTMSGAlbumTool.h"
#import "CTMSGUtilities.h"
#import "CTMSGDatePhotoPreviewViewController.h"
#import "UIView+CTMSG_Cat.h"
#import "UIColor+CTMSG_Hex.h"

@interface CTMSGVideoPreviewController () <UICollectionViewDataSource,UICollectionViewDelegate> {
    BOOL _showBar;
}

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) CTMSGPhotoModel *currentModel;
@property (strong, nonatomic) UIView *customTitleView;
@property (strong, nonatomic) UILabel *titleLb;
@property (strong, nonatomic) UILabel *subTitleLb;
@property (strong, nonatomic) CTMSGDatePhotoPreviewViewCell *tempCell;
@property (strong, nonatomic) UIButton *selectBtn;
@property (nonatomic, strong) UIButton * selectedBtn;
@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) NSInteger beforeOrientationIndex;
@property (strong, nonatomic) CTMSGPhotoCustomNavigationBar *navBar;
@property (strong, nonatomic) UINavigationItem *navItem;
@end


@implementation CTMSGVideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _showBar = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [self setSubviewAlphaAnimate:YES];
    [self p_ctmsg_setupUI];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.orientationDidChange) {
        self.orientationDidChange = NO;
        
        [self p_ctmsg_changeSubviewFrame];
    }
}

- (void)deviceOrientationChanged:(NSNotification *)notify {
    self.orientationDidChange = YES;
}

- (void)deviceOrientationWillChanged:(NSNotification *)notify {
    
    
    self.beforeOrientationIndex = self.currentModelIndex;
}

- (CTMSGDatePhotoPreviewViewCell *)currentPreviewCell:(CTMSGPhotoModel *)model {
    
    if (!model) {
        return nil;
    }
    return (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
}


- (void)p_ctmsg_changeSubviewFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
    if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
        self.titleLb.hidden = NO;
        self.customTitleView.frame = CGRectMake(0, 0, 150, 44);
        self.titleLb.frame = CGRectMake(0, 9, 150, 14);
        self.subTitleLb.frame = CGRectMake(0, CGRectGetMaxY(self.titleLb.frame) + 4, 150, 12);
        self.titleLb.text = model.barTitle;
        self.subTitleLb.text = model.barSubTitle;
    } else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        self.customTitleView.frame = CGRectMake(0, 0, 200, 30);
        self.titleLb.hidden = YES;
        self.subTitleLb.frame = CGRectMake(0, 0, 200, 30);
        self.subTitleLb.text = [NSString stringWithFormat:@"%@  %@",model.barTitle,model.barSubTitle];
    }
    CGFloat bottomMargin = kBottomMargin;
    CGFloat width = self.view.ct_w;
    CGFloat itemMargin = 20;
    if (CTMSG_IS_IPHONEXORLATER && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        bottomMargin = 21;
    }
    self.flowLayout.itemSize = CGSizeMake(width, self.view.ct_h - kTopMargin - bottomMargin);
    self.flowLayout.minimumLineSpacing = itemMargin;
    
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    self.navBar.frame = CGRectMake(0, 0, self.view.ct_w, CTMSGNavBarHeight);
    self.collectionView.frame = CGRectMake(-(itemMargin / 2), kTopMargin, self.view.ct_w + itemMargin, self.view.ct_h - kTopMargin - bottomMargin);
    self.collectionView.contentSize = CGSizeMake(self.modelArray.count * (self.view.ct_w + itemMargin), 0);
    
    [self.collectionView setContentOffset:CGPointMake(self.beforeOrientationIndex * (self.view.ct_w + itemMargin), 0)];
    
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.beforeOrientationIndex inSection:0]]];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
    self.currentModel = model;
    CTMSGDatePhotoPreviewViewCell *cell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
    if (!cell) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CTMSGDatePhotoPreviewViewCell *tempCell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            self.tempCell = tempCell;
            [tempCell requestHDImage];
        });
    }else {
        self.tempCell = cell;
        [cell requestHDImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CTMSGDatePhotoPreviewViewCell *cell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
    [cell cancelRequest];
}

- (void)p_ctmsg_setupUI {
    self.navigationItem.titleView = self.customTitleView;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    self.beforeOrientationIndex = self.currentModelIndex;
    [self p_ctmsg_changeSubviewFrame];
    CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
    
    if (!self.outside) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
        self.selectBtn.selected = model.selected;
        [self.selectBtn setTitle:model.selectIndexStr forState:UIControlStateSelected];
    }
    if (_manager.singleSelected || _manager.maxNum == 1) {
        return;
    }
    
    [self.view addSubview:self.selectedBtn];
//    if (model.type == CTMSGPhotoModelMediaTypeVideo || model.type == CTMSGPhotoModelMediaTypeCameraVideo) {
//        BOOL canSelect = model.videoSecond <= _manager.maxVideoDuration && model.videoSecond >= _manager.minVideoDuration;
//        self.selectBtn.enabled = canSelect;
//        self.selectBtn.backgroundColor = canSelect ? [UIColor blueColor] : [UIColor color_4c4c4c];
//    }
//    else {
        self.selectBtn.enabled = YES;
        self.selectBtn.backgroundColor = [UIColor blueColor];
//    }
}

- (void)didSelectClick:(UIButton *)button {
    if (self.modelArray.count <= 0 || self.outside) {
        [self.view showImageHUDText:[NSBundle ctmsg_localizedStringForKey:@"没有照片可选!"]];
        return;
    }
    if (_albumManager.selectionType == CTMSGAlbumListSelectionTypeAll) {
//    if ([_albumManager.uploadType isEqualToString:@"all"]) {
        if (_manager.selectedList.count) {
            [self commitAllModels];
        } else {
            CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
            model.selected = button.selected;
            [self p_ctmsg_commitVideo:model];
        }
//        return;
    }
//    CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
//    model.selected = button.selected;
//    [self p_intct_commitVideo:model];
}

#pragma mark - right checkbox

- (void)selectClick:(UIButton *)sender {
    if (self.modelArray.count == 0) {
        [self.view showImageHUDText:[NSBundle ctmsg_localizedStringForKey:@"没有照片可选!"]];
        return;
    }
    CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
    if (!sender.selected) {
        NSString *str = [CTMSGAlbumTool maximumOfJudgment:model viewmodel:self.manager];
        if (str) {
            [self.view showImageHUDText:str];
            return;
        }
//        if (model.type != CTMSGPhotoModelMediaTypeCameraVideo && model.type != CTMSGPhotoModelMediaTypeCameraPhoto) {
            CTMSGDatePhotoPreviewViewCell *cell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            if (cell) {
                if (model.type == CTMSGPhotoModelMediaTypeGif) {
                    if (cell.imageView.image.images.count > 0) {
                        model.thumbPhoto = cell.imageView.image.images.firstObject;
                        model.previewPhoto = cell.imageView.image.images.firstObject;
                    }else {
                        model.thumbPhoto = cell.imageView.image;
                        model.previewPhoto = cell.imageView.image;
                    }
                }else {
                    model.thumbPhoto = cell.imageView.image;
                    model.previewPhoto = cell.imageView.image;
                }
            }else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CTMSGDatePhotoPreviewViewCell *cell_1 = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
                    if (model.type == CTMSGPhotoModelMediaTypeGif) {
                        //                        model.thumbPhoto = cell_1.firstImage;
                        //                        model.previewPhoto = cell_1.firstImage;
                    }else {
                        model.thumbPhoto = cell_1.imageView.image;
                        model.previewPhoto = cell_1.imageView.image;
                    }
                });
            }
//        }
//        if (model.type == CTMSGPhotoModelMediaTypePhoto ||
//            (model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive)) {
//            [self.manager.selectedPhotos addObject:model];
//        } else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
//            [self.manager.selectedVideos addObject:model];
//        }
//        else if (model.type == CTMSGPhotoModelMediaTypeCameraPhoto) {
//            [self.manager.selectedPhotos addObject:model];
//            [self.manager.selectedCameraPhotos addObject:model];
//            [self.manager.selectedCameraList addObject:model];
//        }
//        else if (model.type == CTMSGPhotoModelMediaTypeCameraVideo) {
//            [self.manager.selectedVideos addObject:model];
//            [self.manager.selectedCameraVideos addObject:model];
//            [self.manager.selectedCameraList addObject:model];
//        }
        [self.manager.selectedList addObject:model];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim.duration = 0.25;
        anim.values = @[@(1.2),@(0.8),@(1.1),@(0.9),@(1.0)];
        [sender.layer addAnimation:anim forKey:@""];
    } else {
//        if (model.type != CTMSGPhotoModelMediaTypeCameraVideo && model.type != CTMSGPhotoModelMediaTypeCameraPhoto) {
//            model.thumbPhoto = nil;
//            model.previewPhoto = nil;
//        }
//        if ((model.type == CTMSGPhotoModelMediaTypePhoto || model.type == CTMSGPhotoModelMediaTypeGif) || (model.type == CTMSGPhotoModelMediaTypeVideo || model.type == CTMSGPhotoModelMediaTypeLive)) {
//            if (model.type == CTMSGPhotoModelMediaTypePhoto || model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive) {
//                [self.manager.selectedPhotos removeObject:model];
//            }else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
//                [self.manager.selectedVideos removeObject:model];
//            }
//        }
//        else if (model.type == CTMSGPhotoModelMediaTypeCameraPhoto ||
//                 model.type == CTMSGPhotoModelMediaTypeCameraVideo) {
//            if (model.type == CTMSGPhotoModelMediaTypeCameraPhoto) {
//                [self.manager.selectedPhotos removeObject:model];
//                [self.manager.selectedCameraPhotos removeObject:model];
//
//            }else if (model.type == CTMSGPhotoModelMediaTypeCameraVideo) {
//                [self.manager.selectedVideos removeObject:model];
//                [self.manager.selectedCameraVideos removeObject:model];
//            }
//            [self.manager.selectedCameraList removeObject:model];
//        }
        [self.manager.selectedList removeObject:model];
    }
    sender.selected = !sender.selected;
    model.selected = sender.selected;
    
    for (int i = 0; i < self.manager.selectedList.count; i++) {
        CTMSGPhotoModel * model = [self.manager.selectedList objectAtIndex:i];
        model.selectedPhotosIndex = i;
    }
    
    if (model.selected) {
        [sender setTitle:[NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"checkbox_act"] forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"checkbox_def"] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(allPreviewdidSelectedClick:AddOrDelete:)]) {
        [self.delegate allPreviewdidSelectedClick:model AddOrDelete:sender.selected];
    }
}

- (void)p_ctmsg_commitVideo:(CTMSGPhotoModel *)model {
    if ([_delegate respondsToSelector:@selector(previewControllerDidSelect:model:)]) {
        [_delegate previewControllerDidSelect:self model:model];
    }
//    __weak typeof(self) weakSelf = self;
//    if (_albumManager) {
//        MBProgressHUD * hud = [self.view customProgressHUDTitle:@"0%"];
//        if (_albumManager.selectionType == CTMSGAlbumListSelectionTypeAll) {
//            [_albumManager intct_uploadUnKnown:model progress:^(float progressValue) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f", progressValue];
//                });
//            } result:^(NSError * _Nullable error, id _Nullable result) {
//                [hud hideAnimated:YES];
//                if (!error) {
//                    if ([weakSelf.delegate respondsToSelector:@selector(videoPreviewUpload:success:)]) {
//                        [weakSelf.delegate videoPreviewUpload:self success:YES];
//                    }
//                } else {
////                    NSDictionary * dic = error.userInfo;
//                    [weakSelf.view showTextHUD:error.description];
//                }
//            }];
//        } else {
//            [_albumManager intct_uploadVideo:model progress:^(float progressValue) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    hud.detailsLabel.text = [NSString stringWithFormat:@"%.2f", progressValue];
//                });
//            } result:^(NSError * _Nullable error, id  _Nullable result) {
//                [hud hideAnimated:YES];
//                if (!error) {
////                    if ([msg isEqualToString:@"end"]) {
//                        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//                        if ([weakSelf.delegate respondsToSelector:@selector(videoPreviewUpload:success:)]) {
//                            [weakSelf.delegate videoPreviewUpload:self success:YES];
//                        }
////                    }
//                } else {
//                    [weakSelf.view showTextHUD:error.description];
//                }
//            }];
//            return;
//        }
//    }
}

- (void)commitAllModels {
    if ([_delegate respondsToSelector:@selector(previewControllerDidDone:)]) {
        [_delegate previewControllerDidDone:self];
    }
//    __weak typeof(self) weakSelf = self;
//    int totalCount = (int)(_manager.selectedList.count);
//    NSString * str = [NSString stringWithFormat:@"0/%d", totalCount];
//    MBProgressHUD * hud = [self.view customProgressHUDTitle:str];
    
//    [_albumManager intct_uploadImages:_manager.selectedList progress:^(float singleProgress, float totalProgress) {
//        NSString * proStr = [NSString stringWithFormat:@"%f", totalProgress];
//        hud.detailsLabel.text = proStr;
//    } result:^(int sendCount, int failCount, NSArray * _Nonnull sendResults, NSArray<CTMSGPhotoModel *> * _Nonnull failModel) {
//        if (totalCount == sendCount) {
//            [hud hideAnimated:YES];
//            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
//            if ([weakSelf.delegate respondsToSelector:@selector(mixUploadFromAlbumPreview:sendCount:failCount:sendResults:)]) {
//                [weakSelf.delegate mixUploadFromAlbumPreview:weakSelf sendCount:sendCount failCount:failCount sendResults:sendResults];
//            }
//        }
//    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.modelArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CTMSGDatePhotoPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DatePreviewCellId" forIndexPath:indexPath];
    CTMSGPhotoModel *model = self.modelArray[indexPath.item];
    cell.model = model;
    __weak typeof(self) weakSelf = self;
    [cell setCellDidPlayVideoBtn:^(BOOL play) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_showBar = !play;
        [weakSelf setSubviewAlphaAnimate:YES];
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CTMSGPhotoModel *model = self.modelArray[indexPath.item];
    if (model.type != CTMSGPhotoModelMediaTypeVideo) {
        [self setSubviewAlphaAnimate:YES];
    }
}

- (void)setSubviewAlphaAnimate:(BOOL)animate {
    BOOL hide = NO;
    hide = !_showBar;
    if (!hide) {
        [self.navigationController setNavigationBarHidden:hide animated:NO];
    }
    
    if (animate) {
        [UIView animateWithDuration:0.15 animations:^{
            self.navigationController.navigationBar.alpha = hide ? 0 : 1;
            if (self.outside) {
                self.navBar.alpha = hide ? 0 : 1;
            }
            self.view.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
            self.collectionView.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
        } completion:^(BOOL finished) {
            if (hide) {
                [self.navigationController setNavigationBarHidden:hide animated:NO];
            }
        }];
    } else {
        self.navigationController.navigationBar.alpha = hide ? 0 : 1;
        if (self.outside) {
            self.navBar.alpha = hide ? 0 : 1;
        }
        self.view.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
        self.collectionView.backgroundColor = hide ? [UIColor blackColor] : [UIColor whiteColor];
        if (hide) {
            [self.navigationController setNavigationBarHidden:hide];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(CTMSGDatePhotoPreviewViewCell *)cell resetScale];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(CTMSGDatePhotoPreviewViewCell *)cell cancelRequest];
}

#pragma mark - < UICollectionViewDelegate >

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat offsetx = self.collectionView.contentOffset.x;
    NSInteger currentIndex = (offsetx + (width + 20) * 0.5) / (width + 20);
    if (currentIndex > self.modelArray.count - 1) {
        currentIndex = self.modelArray.count - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    if (self.modelArray.count > 0) {
        CTMSGPhotoModel *model = self.modelArray[currentIndex];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationPortrait == UIInterfaceOrientationPortraitUpsideDown) {
            self.titleLb.text = model.barTitle;
            self.subTitleLb.text = model.barSubTitle;
        } else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
            self.subTitleLb.text = [NSString stringWithFormat:@"%@  %@", model.barTitle, model.barSubTitle];
        }
        self.selectBtn.selected = model.selected;
        [self.selectBtn setTitle:model.selectIndexStr forState:UIControlStateSelected];
    }
    self.currentModelIndex = currentIndex;
    CTMSGPhotoModel *model = self.modelArray[currentIndex];
    
    if (model.type == CTMSGPhotoModelMediaTypeVideo) {
        BOOL canSelect = model.videoSecond <= _manager.maxVideoDuration && model.videoSecond >= _manager.minVideoDuration;
        self.selectBtn.enabled = canSelect;
        self.selectBtn.backgroundColor = canSelect ? [UIColor blueColor] : [UIColor ctmsg_color4C4C4C];
    } else {
        self.selectBtn.enabled = YES;
        self.selectBtn.backgroundColor = [UIColor blueColor];
    }
    
    self.selectedBtn.selected = model.selected;
    [self.selectedBtn setBackgroundImage:[UIImage imageNamed:model.selected ? @"checkbox_act" : @"checkbox_def"] forState:UIControlStateNormal];
    NSString * str = model.selected ? [NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] : @"";
    [self.selectedBtn setTitle:str forState:UIControlStateNormal];
    if (!_showBar) {
        _showBar = YES;
        [self setSubviewAlphaAnimate:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.modelArray.count > 0) {
        CTMSGDatePhotoPreviewViewCell *cell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
        CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
        self.currentModel = model;
        [cell requestHDImage];
    }
}

- (void)datePhotoPreviewBottomViewDidItem:(CTMSGPhotoModel *)model currentIndex:(NSInteger)currentIndex beforeIndex:(NSInteger)beforeIndex {
    if ([self.modelArray containsObject:model]) {
        NSInteger index = [self.modelArray indexOfObject:model];
        if (self.currentModelIndex == index) {
            return;
        }
        self.currentModelIndex = index;
        [self.collectionView setContentOffset:CGPointMake(self.currentModelIndex * (self.view.ct_w + 20), 0) animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scrollViewDidEndDecelerating:self.collectionView];
        });
    }
}

//- (void)datePhotoPreviewBottomViewDidDone:(CTMSGDatePhotoPreviewBottomView *)bottomView {
//    if (self.outside) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//        return;
//    }
//    if (self.modelArray.count == 0) {
//        [self.view showImageHUDText:@"没有照片可选!"];
//        return;
//    }
//    CTMSGPhotoModel *model = self.modelArray[self.currentModelIndex];
//    BOOL max = NO;
//    if (self.manager.selectedList.count == self.manager.maxNum) {
//        // 已经达到最大选择数
//        max = YES;
//    }
//    if (self.manager.type == CTMSGAlbumListSelectionTypeAll) {
//        if ((model.type == CTMSGPhotoModelMediaTypePhoto || model.type == CTMSGPhotoModelMediaTypeGif) || (model.type == CTMSGPhotoModelMediaTypeCameraPhoto || model.type == CTMSGPhotoModelMediaTypeLive)) {
//            if (self.manager.videoMaxNum > 0) {
//                if (!self.manager.selectTogether) { // 是否支持图片视频同时选择
//                    if (self.manager.selectedVideos.count > 0 ) {
//                        // 已经选择了视频,不能再选图片
//                        max = YES;
//                    }
//                }
//            }
//            if (self.manager.selectedPhotos.count == self.manager.photoMaxNum) {
//                max = YES;
//                // 已经达到图片最大选择数
//            }
//        }
//    }else if (self.manager.type == CTMSGAlbumListSelectionTypePhoto) {
//        if (self.manager.selectedPhotos.count == self.manager.photoMaxNum) {
//            // 已经达到图片最大选择数
//            max = YES;
//
//        }
//    }
//    if (self.manager.selectedList.count == 0) {
//        if (!self.selectBtn.selected && !max && self.modelArray.count > 0) {
//            model.selected = YES;
//            CTMSGDatePhotoPreviewViewCell *cell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
//            if (model.type == CTMSGPhotoModelMediaTypeGif) {
//                if (cell.imageView.image.images.count > 0) {
//                    model.thumbPhoto = cell.imageView.image.images.firstObject;
//                    model.previewPhoto = cell.imageView.image.images.firstObject;
//                } else {
//                    model.thumbPhoto = cell.imageView.image;
//                    model.previewPhoto = cell.imageView.image;
//                }
//            } else {
//                model.thumbPhoto = cell.imageView.image;
//                model.previewPhoto = cell.imageView.image;
//            }
//            if (model.type == CTMSGPhotoModelMediaTypePhoto || (model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive)) { // 为图片时
//                [self.manager.selectedPhotos addObject:model];
//            } else if (model.type == CTMSGPhotoModelMediaTypeVideo) { // 为视频时
//                [self.manager.selectedVideos addObject:model];
//            } else if (model.type == CTMSGPhotoModelMediaTypeCameraPhoto) {
//                // 为相机拍的照片时
//                [self.manager.selectedPhotos addObject:model];
//                [self.manager.selectedCameraPhotos addObject:model];
//                [self.manager.selectedCameraList addObject:model];
//            } else if (model.type == CTMSGPhotoModelMediaTypeCameraVideo) {
//                // 为相机录的视频时
//                [self.manager.selectedVideos addObject:model];
//                [self.manager.selectedCameraVideos addObject:model];
//                [self.manager.selectedCameraList addObject:model];
//            }
//            [self.manager.selectedList addObject:model];
//            model.selectIndexStr = [NSString stringWithFormat:@"%ld",[self.manager.selectedList indexOfObject:model] + 1];
//        }
//    }
//    if ([self.delegate respondsToSelector:@selector(datePhotoPreviewControllerDidDone:)]) {
//        [self.delegate previewControllerDidDone:self];
//    }
//}

#pragma mark - < 懒加载 >
- (CTMSGPhotoCustomNavigationBar *)navBar {
    if (!_navBar) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _navBar = [[CTMSGPhotoCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, CTMSGNavBarHeight)];
        _navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_navBar pushNavigationItem:self.navItem animated:NO];
    }
    return _navBar;
}

- (UINavigationItem *)navItem {
    if (!_navItem) {
        _navItem = [[UINavigationItem alloc] init];
        _navItem.titleView = self.customTitleView;
    }
    return _navItem;
}

- (UIView *)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[UIView alloc] init];
        [_customTitleView addSubview:self.titleLb];
        [_customTitleView addSubview:self.subTitleLb];
    }
    return _customTitleView;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] init];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        if (IOS8_2_OR_LATER) {
            _titleLb.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        }else {
            _titleLb.font = [UIFont systemFontOfSize:14];
        }
        _titleLb.textColor = [UIColor blackColor];
    }
    return _titleLb;
}

- (UILabel *)subTitleLb {
    if (!_subTitleLb) {
        _subTitleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLb.frame) + 4, 150, 12)];
        _subTitleLb.textAlignment = NSTextAlignmentCenter;
        if (IOS8_2_OR_LATER) {
            _subTitleLb.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        }else {
            _subTitleLb.font = [UIFont systemFontOfSize:11];
        }
        _subTitleLb.textColor = [UIColor blackColor];
    }
    return _subTitleLb;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_selectBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_selectBtn setBackgroundColor:[UIColor blueColor]];
        [_selectBtn addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.ct_size = CGSizeMake(60, 24);
        _selectBtn.layer.cornerRadius = 4;
    }
    return _selectBtn;
}

- (UIButton *)selectedBtn {
    if (!_selectedBtn) {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_def"] forState:UIControlStateNormal];
        [_selectedBtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectedBtn.frame = CGRectMake(self.view.frame.size.width - 40, 80, 30, 30);
        [_selectedBtn ctmsg_setEnlargeEdgeWithTop:0 right:0 bottom:20 left:20];
    }
    return _selectedBtn;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, kTopMargin,self.view.ct_w + 20, self.view.ct_h - kTopMargin - kBottomMargin) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[CTMSGDatePhotoPreviewViewCell class] forCellWithReuseIdentifier:@"DatePreviewCellId"];
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#else
            if ((NO)) {
#endif
            } else {
                self.automaticallyAdjustsScrollViewInsets = NO;
                
            }
        }
        return _collectionView;
    }
    
    - (UICollectionViewFlowLayout *)flowLayout {
        if (!_flowLayout) {
            _flowLayout = [[UICollectionViewFlowLayout alloc] init];
            _flowLayout.minimumInteritemSpacing = 0;
            _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            
            if (self.outside) {
                _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
            } else {
#ifdef __IPHONE_11_0
                if (@available(iOS 11.0, *)) {
#else
                    if ((NO)) {
#endif
                        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
                    } else {
                        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
                    }
                }
            }
            return _flowLayout;
        }
        - (NSMutableArray *)modelArray {
            if (!_modelArray) {
                _modelArray = [NSMutableArray array];
            }
            return _modelArray;
        }
        
        - (void)dealloc {
            CTMSGDatePhotoPreviewViewCell *cell = (CTMSGDatePhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            [cell cancelRequest];
            if ([UIApplication sharedApplication].statusBarHidden) {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
            //    NSSLog(@"dealloc");
        }
        @end
