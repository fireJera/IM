////
////  CTMSGNaviTransition.m
////  微博照片选择
////
////  Created by 洪欣 on 17/2/9.
////  Copyright © 2017年 洪欣. All rights reserved.
////
//
//#import "CTMSGTransition.h"
////#import "CTMSGPhotoViewController.h"
//#import "CTMSGPhotoViewCell.h"
//#import "CTMSGPhotoPreviewViewController.h"
//#import "CTMSGPhotoPreviewViewCell.h"
//#import "CTMSGVideoPreviewViewController.h"
//#import "CTMSGAlbumTool.h"
//
//@interface CTMSGTransition ()
//@property (assign, nonatomic) CTMSGTransitionType type;
//@property (assign, nonatomic) CTMSGTransitionVcType vcType;
//@end
//
//@implementation CTMSGTransition
//
//+ (instancetype)transitionWithType:(CTMSGTransitionType)type VcType:(CTMSGTransitionVcType)vcType {
//    return [[self alloc] initWithTransitionType:type VcType:vcType];
//}
//
//- (instancetype)initWithTransitionType:(CTMSGTransitionType)type VcType:(CTMSGTransitionVcType)vcType
//{
//    if (self = [super init]) {
//        self.type = type;
//        self.vcType = vcType;
//    }
//    return self;
//}
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    return 0.25f;
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    switch (self.type) {
//        case CTMSGTransitionTypePush:
//            [self pushAnimation:transitionContext];
//            break;
//        default:
//            [self popAnimation:transitionContext];
//            break;
//    }
//}
//
//- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    CTMSGPhotoViewController *fromVC = (CTMSGPhotoViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    CTMSGPhotoModel *model;
//    if (self.vcType == CTMSGTransitionVcTypePhoto) {
//        if ([toVC isKindOfClass:[CTMSGPhotoPreviewViewController class]]) {
//            CTMSGPhotoPreviewViewController *vc = (CTMSGPhotoPreviewViewController *)toVC;
//            model = vc.modelList[vc.index];
//        }
//    } else {
//        CTMSGVideoPreviewViewController *vc = (CTMSGVideoPreviewViewController *)toVC;
//        model = vc.model;
//    }
//    if (model.previewPhoto) {
//    [self pushAnim:transitionContext Image:model.previewPhoto Model:model FromVC:fromVC ToVC:toVC];
//    } else {
//    __weak typeof(self) weakSelf = self;
//    [CTMSGAlbumTool getHighQualityFormatPhotoForPHAsset:model.asset size:CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8) completion:^(UIImage *image, NSDictionary *info) {
//        [weakSelf pushAnim:transitionContext Image:image Model:model FromVC:fromVC ToVC:toVC];
//    } error:^(NSDictionary *info) {
//        [weakSelf pushAnim:transitionContext Image:model.thumbPhoto Model:model FromVC:fromVC ToVC:toVC];
//    }];
//}
//
//- (void)pushAnim:(id<UIViewControllerContextTransitioning>)transitionContext Image:(UIImage *)image Model:(CTMSGPhotoModel *)model FromVC:(CTMSGPhotoViewController *)fromVC ToVC:(UIViewController *)toVC
//{
//    UIView *containerView = [transitionContext containerView];
//
//    if (!model) {
//        [containerView addSubview:toVC.view];
//        [transitionContext completeTransition:YES];
//        return;
//    }
//    model.tempImage = image;
//    CTMSGPhotoViewCell *fromCell = (CTMSGPhotoViewCell *)[fromVC.collectionView cellForItemAtIndexPath:fromVC.currentIndexPath];
//    CGFloat imgWidht = model.endImageSize.width;
//    CGFloat imgHeight = model.endImageSize.height;
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//    UIImageView *tempView = [[UIImageView alloc] initWithImage:image];
//    if (!image) {
//        tempView.image = fromCell.imageView.image;
//    }
//    tempView.clipsToBounds = YES;
//    tempView.contentMode = UIViewContentModeScaleAspectFill;
//    tempView.frame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView: containerView];
//    if (fromVC.isPreview) {
//        tempView.center = CGPointMake(width / 2, height / 2);
//    }
//    [containerView addSubview:toVC.view];
//    [containerView addSubview:tempView];
//    if (self.vcType == CTMSGTransitionVcTypePhoto) {
//        CTMSGPhotoPreviewViewController *vc = (CTMSGPhotoPreviewViewController *)toVC;
//        vc.collectionView.hidden = YES;
//    }
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        tempView.frame = CGRectMake((width - imgWidht) / 2, (height - imgHeight) / 2 + (kNavigationBarHeight / 2), imgWidht, imgHeight);
//    } completion:^(BOOL finished) {
//        if (self.vcType == CTMSGTransitionVcTypePhoto) {
//            CTMSGPhotoPreviewViewController *vc = (CTMSGPhotoPreviewViewController *)toVC;
//            vc.collectionView.hidden = NO;
//        }else {
//            CTMSGVideoPreviewViewController *vc = (CTMSGVideoPreviewViewController *)toVC;
//            [vc.maskView removeFromSuperview];
//        }
//        tempView.hidden = YES;
//        [transitionContext completeTransition:YES];
//    }];
//}
//
//- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    CTMSGPhotoViewController *toVC = (CTMSGPhotoViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    CTMSGPhotoModel *model;
//    UIImageView *tempView;
//    if (self.vcType == CTMSGTransitionVcTypePhoto) {
//        CTMSGPhotoPreviewViewController *vc = (CTMSGPhotoPreviewViewController *)fromVC;
//        if (![vc isKindOfClass:[CTMSGPhotoPreviewViewController class]]) {
//            [transitionContext completeTransition:YES];
//            return;
//        }
//        if (vc.modelList.count > 0 && !vc.isPreview) {
//            model = vc.modelList[vc.index];
//        } else {
//            model = vc.currentModel;
//        }
//        CTMSGPhotoPreviewViewCell *previewCell = (CTMSGPhotoPreviewViewCell *)[vc.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:vc.index inSection:0]];
//        if (model.type == CTMSGPhotoModelMediaTypeGif) {
//            [previewCell stopGifImage];
//            //            tempView = [[UIImageView alloc] initWithImage:previewCell.imageView.image];
//        }
//        //        else {
//        tempView = [[UIImageView alloc] initWithImage:previewCell.imageView.image];
//        //        }
//    }else {
//        CTMSGVideoPreviewViewController *vc = (CTMSGVideoPreviewViewController *)fromVC;
//        model = vc.model;
//        if (!vc.coverImage) {
//            if (model.previewPhoto) {
//                tempView = [[UIImageView alloc] initWithImage:model.previewPhoto];
//            }else if (model.thumbPhoto) {
//                tempView = [[UIImageView alloc] initWithImage:model.thumbPhoto];
//            }
//        }else {
//            tempView = [[UIImageView alloc] initWithImage:vc.coverImage];
//        }
//    }
//    tempView.clipsToBounds = YES;
//    tempView.contentMode = UIViewContentModeScaleAspectFill;
//    BOOL contains = [toVC.objs containsObject:model];
//    NSInteger index = [toVC.objs indexOfObject:model];
//
//    CTMSGPhotoViewCell *cell = (CTMSGPhotoViewCell *)[toVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//
//    if (!cell) {
//        if (model.currentAlbumIndex == toVC.albumModel.index && contains) {
//            [toVC.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//            [toVC.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
//            cell = (CTMSGPhotoViewCell *)[toVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//        }
//    }
//    if (tempView.image == nil) {
//        tempView = [[UIImageView alloc] initWithImage:cell.imageView.image];
//    }
//    tempView.clipsToBounds = YES;
//    tempView.contentMode = UIViewContentModeScaleAspectFill;
//    CGFloat height = [UIScreen mainScreen].bounds.size.height;
//    UIView *containerView = [transitionContext containerView];
//    [containerView insertSubview:toVC.view atIndex:0];
//    [containerView addSubview:tempView];
//    if (model.endImageSize.width == 0 || model.endImageSize.height == 0) {
//        tempView.frame = CGRectMake(0, 0, tempView.image.size.width, tempView.image.size.height);
//    }else {
//        tempView.frame = CGRectMake(0, 0, model.endImageSize.width, model.endImageSize.height);
//    }
//    tempView.center = CGPointMake(containerView.frame.size.width / 2, (height - kNavigationBarHeight) / 2 + kNavigationBarHeight);
//    CGRect rect = [toVC.collectionView convertRect:cell.frame toView:[UIApplication sharedApplication].keyWindow];
//    if (cell) {
//        if (rect.origin.y < kNavigationBarHeight) {
//            [toVC.collectionView setContentOffset:CGPointMake(0, cell.frame.origin.y - kNavigationBarHeight)];
//            rect = CGRectMake(cell.frame.origin.x, kNavigationBarHeight + 0.5, cell.frame.size.width, cell.frame.size.height);
//        }else if (rect.origin.y + rect.size.height > height - 50.5 - kBottomMargin) {
//            [toVC.collectionView setContentOffset:CGPointMake(0, cell.frame.origin.y - height + 50.5 + kBottomMargin + rect.size.height)];
//            rect = CGRectMake(cell.frame.origin.x, height - 50.5 - kBottomMargin - cell.frame.size.height, cell.frame.size.width, cell.frame.size.height);
//        }
//    }
//    cell.hidden = YES;
//    fromVC.view.hidden = YES;
//    if (toVC.albumModel.index != model.currentAlbumIndex && toVC.isPreview) {
//        cell.hidden = NO;
//        fromVC.view.hidden = NO;
//    }
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        if (toVC.albumModel.index == model.currentAlbumIndex && contains) {
//            tempView.frame = rect;
//        }else {
//            fromVC.view.alpha = 0;
//            tempView.alpha = 0;
//            tempView.transform = CGAffineTransformMakeScale(1.3, 1.3);
//        }
//    } completion:^(BOOL finished) {
//        cell.hidden = NO;
//        toVC.isPreview = NO;
//        [tempView removeFromSuperview];
//        [transitionContext completeTransition:YES];
//    }];
//}
//
//@end
//
