//
//  CTMSGAlbumListViewController.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "CTMSGAlbumListViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CTMSGPhotoViewCell.h"
#import "CTMSGAlbumListView.h"
#import "CTMSGAlbumTitleButton.h"
#import "UIView+CTMSG_Cat.h"
#import "UIImage+CTMSG_Cat.h"
#import "CTMSGPhotoCustomNavigationBar.h"
#import "CTMSGAlbumModel.h"
#import "CTMSGVideoPreviewController.h"
#import "CTMSGAlbumTool.h"
#import "CTMSGPhotoModel.h"
#import "CTMSGUtilities.h"
#import "UIView+CTMSG_Cat.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGAlbumManager.h"

static NSString * const kAlbumListCell = @"albumListCell";

@interface CTMSGAlbumListViewController () <UICollectionViewDataSource,UICollectionViewDelegate,
CAAnimationDelegate,
//UIViewControllerPreviewingDelegate,
CTMSGAlbumListViewDelegate,
CTMSGPhotoViewCellDelegate,
//CTMSGPhotoEditViewControllerDelegate,
//UICollectionViewDataSourcePrefetching,
CTMSGVideoPreviewControllerDelegate> {
    CGRect _originalFrame;
}

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout * flowLayout;

@property (strong, nonatomic) UINavigationItem *navItem;                                //
@property (strong, nonatomic) UIButton *rightBtn;                                       //右边下一步
@property (strong, nonatomic) UIButton *leftBtn;                                        //左边取消
@property (strong, nonatomic) UILabel *authorizationLb;                                 //

@property (strong, nonatomic) UIView *albumsBgView;                                     //因该是相册列表灰色背景
@property (strong, nonatomic) CTMSGAlbumListView *albumView;                                 //相册列表view
@property (strong, nonatomic) CTMSGPhotoCustomNavigationBar *navBar;                       //
@property (weak, nonatomic) CTMSGAlbumTitleButton *titleBtn;                               //展开相册按钮
@property (strong, nonatomic) NSTimer *timer;                                           //开启一个计时器来监听权限的改变

@property (copy, nonatomic) NSArray<CTMSGAlbumModel *> * albums;                                            //
@property (strong, nonatomic) CTMSGAlbumModel *selectedAlbum;
@property (assign, nonatomic) NSInteger currentSelectCount;                             //
@property (strong, nonatomic) NSIndexPath *currentIndexPath;


@property (strong, nonatomic) UIActivityIndicatorView *indica;                          //系统自带菊花view
//@property (weak, nonatomic) id<UIViewControllerPreviewing> previewingContext;           //

@end

@implementation CTMSGAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self p_ctmsg_initAlbumManager];
    [self p_ctmsg_setView];
    [self p_ctmsg_getAllAlbums];
    
    // 获取当前应用对照片的访问授权状态
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [self.view addSubview:self.authorizationLb];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange:) userInfo:nil repeats:YES];
    }
    __weak typeof(self) weakSelf = self;
    [self.albumManager setPhotoLibraryDidChangeWithPhotoViewController:^(NSArray *collectionChanges){
        [weakSelf photoLibraryDidChange:collectionChanges];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillLayoutSubviews {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    const CGFloat spacing = 0.5;
    CGFloat CVwidth = (width - spacing * self.albumManager.columnCount - 1 ) / self.albumManager.columnCount;
    
    _flowLayout.itemSize = CGSizeMake(CVwidth, CVwidth);
    _flowLayout.minimumInteritemSpacing = spacing;
    _flowLayout.minimumLineSpacing = spacing;
    _collectionView.frame = (CGRect){0, 0, width, height - kBottomMargin};
    
    _albumsBgView.frame = CGRectMake(0, -340, width, 340);
}

- (void)p_ctmsg_setView {
    [self p_ctmsg_setNavBarView];
    self.view.backgroundColor = [UIColor whiteColor];

    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CTMSGPhotoViewCell class] forCellWithReuseIdentifier:kAlbumListCell];
    [self.view addSubview:self.collectionView];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    const CGFloat spacing = 0.5;
    if (self.albumManager.maxNum != 1) {
        self.collectionView.contentInset = UIEdgeInsetsMake(spacing + CTMSGNavBarHeight, 0, spacing + 50, 0);
        if (self.albumManager.selectionType == CTMSGAlbumListSelectionTypeVideo) {
            self.collectionView.contentInset = UIEdgeInsetsMake(spacing + CTMSGNavBarHeight, 0,  spacing, 0);
            self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
        }
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(spacing + CTMSGNavBarHeight, 0,  spacing, 0);
    }
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    
    [self.view addSubview:self.albumsBgView];
    _albumView = ({
        CTMSGAlbumListView *albumListView = [[CTMSGAlbumListView alloc] initWithFrame:CGRectZero manager:_albumManager];
        albumListView.delegate = self;
        [self.view addSubview:albumListView];
        albumListView;
    });
    
    [self.view addSubview:self.navBar];
}

- (void)p_ctmsg_setNavBarView {
    if (_albumManager.maxNum != 1) {
        self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
        if (self.albumManager.selectedList.count > 0) {
            self.rightBtn.enabled = YES;
            self.navItem.rightBarButtonItem.enabled = YES;
            [self.rightBtn setTitle:[NSString stringWithFormat:@"%@(%d)", @"下一步", (int)self.albumManager.selectedList.count] forState:UIControlStateNormal];
//            self.rightBtn.layer.borderWidth = 0;
//            CGFloat rightBtnH = self.rightBtn.frame.size.height;
//            CGFloat rightBtnW = [CTMSGAlbumTool getTextWidth:self.rightBtn.currentTitle height:rightBtnH fontSize:14];
//            self.rightBtn.frame = CGRectMake(0, 0, rightBtnW + 20, rightBtnH);
        } else {
            self.rightBtn.enabled = NO;
            self.navItem.rightBarButtonItem.enabled = NO;
            [self.rightBtn setTitle:@"下一步" forState:UIControlStateNormal];
//            self.rightBtn.frame = CGRectMake(0, 0, 60, 25);
//            self.rightBtn.layer.borderWidth = 0.5;
        }
    }
}

- (void)p_ctmsg_initAlbumManager {
    if (!_albumManager) {
        _albumManager = [[CTMSGAlbumManager alloc] initWithSelectionType:CTMSGAlbumListSelectionTypePhoto];
    }
    _albumManager.selecting = YES;
    [_albumManager getCellIcons];
}

#pragma mark - touch event

- (void)goSetup {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 10.0, *)) {
        //        NSDictionary * options = @{UIApplicationOpenURLOptionUniversalLinksOnly : @YES}
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#pragma clang diagnostic pop
    }
}

/**
 点击取消按钮 清空所有操作
 */
- (void)cancelClick {
    self.albumManager.selecting = NO;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.albumManager.selectedList removeAllObjects];
//    [self.albumManager.selectedPhotos removeAllObjects];
//    [self.albumManager.selectedVideos removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(albumListViewControllerDidCancel:)]) {
        [self.delegate albumListViewControllerDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 展开/收起 相册列表
 
 @param button 按钮
 */
- (void)pushAlbumList:(UIButton *)button {
    button.selected = !button.selected;
    button.userInteractionEnabled = NO;
    if (button.selected) {
        if (self.albumManager.selectedList.count > 0) {
            for (CTMSGAlbumModel *albumMd in self.albums) {
                albumMd.selectCount = 0;
            }
            for (CTMSGPhotoModel *photoModel in self.albumManager.selectedList) {
                for (CTMSGAlbumModel *albumMd in self.albums) {
                    if ([albumMd.result containsObject:photoModel.asset]) {
                        albumMd.selectCount++;
                    }
                }
            }
        }
        else {
            for (CTMSGAlbumModel *albumMd in self.albums) {
                albumMd.selectCount = 0;
            }
        }
        self.albumView.list = self.albums;
        self.currentSelectCount = self.selectedAlbum.selectCount;
        
        self.albumsBgView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.albumView.frame = CGRectMake(0, CTMSGNavBarHeight, self.view.frame.size.width, 340);
            self.albumView.tableView.frame = CGRectMake(0, 15, self.view.frame.size.width, 340);
            button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                self.albumView.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 340);
            } completion:^(BOOL finished) {
                button.userInteractionEnabled = YES;
            }];
        }];
        [UIView animateWithDuration:0.45 animations:^{
            self.albumsBgView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.45 animations:^{
            self.albumsBgView.alpha = 0;
        } completion:^(BOOL finished) {
            self.albumsBgView.hidden = YES;
            button.userInteractionEnabled = YES;
        }];
        [UIView animateWithDuration:0.25 animations:^{
            self.albumView.tableView.frame = CGRectMake(0, 15, self.view.frame.size.width, 340);
            button.imageView.transform = CGAffineTransformMakeRotation(M_PI * 2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.albumView.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 340);
                self.albumView.frame = CGRectMake(0, -340, self.view.frame.size.width, 340);
            }];
        }];
    }
}

/**
 点击下一步执行的方法
 
 @param button 下一步按钮
 */
#pragma mark - 下一步
- (void)didNextClick:(UIButton *)button {
//    [self cleanSelectedList];
    self.albumManager.selecting = NO;
//    if (self.navigationController.topViewController != self) {
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    int totalCount = (int)(_albumManager.selectedList.count);
//    NSString * str = [NSString stringWithFormat:@"0/%d", totalCount];
//    MBProgressHUD * hud = [self.view customProgressHUDTitle:str];
//    button.enabled = NO;
//    [_albumManager intct_uploadImages:_albumManager.selectedList progress:^(float singleProgress, float totalProgress) {
//        NSString * proStr = [NSString stringWithFormat:@"%f", totalProgress];
//        hud.detailsLabel.text = proStr;
//    } result:^(int sendCount, int failCount, NSArray * _Nonnull sendResults, NSArray<CTMSGPhotoModel *> * _Nonnull failModel) {
//        [hud hideAnimated:YES];
//        button.enabled = YES;
//        if (sendCount == failCount) {
////            if ([msg isEqualToString:@"end"]) {
//            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
////            }
////            else {
////                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
////            }
//        } else {
////            [weakSelf.view showTextHUD:msg];
////            if (msg.length > 0) {
////                [weakSelf.view showTextHUD:msg];
////            }
//        }
//    }];
    if ([_delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
        [_delegate albumListViewControllerDidFinish:self];
    }
}

/**
 点击背景时
 */
- (void)didalbumsBgViewClick {
    [self pushAlbumList:self.titleBtn];
}

#pragma mark - private func

- (void)p_ctmsg_getAllAlbums {
    [self.view showLoadingHUDText:@"加载中"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL isShow = _albumManager.selectedList.count;
        __weak typeof(self) weakSelf = self;
        [_albumManager fetchAllAlbum:^(NSArray<CTMSGAlbumModel *> * _Nonnull albums) {
            weakSelf.albums = albums;
            [weakSelf p_ctmsg_getAlbumPhotos];
        } showSelectTag:isShow];
    });
}

- (void)p_ctmsg_getAlbumPhotos {
    CTMSGAlbumModel *model = self.albums.firstObject;
    self.currentSelectCount = model.selectCount;
    self.selectedAlbum = model;
    __weak typeof(self) weakSelf = self;
    [self.albumManager fetchAllPhotoForPHFetchResult:model.result index:model.index result:^(NSArray<CTMSGPhotoModel *> * _Nonnull photos, NSArray<CTMSGPhotoModel *> * _Nonnull videos, NSArray<CTMSGPhotoModel *> * _Nonnull objs) {
        weakSelf.photos = [NSMutableArray arrayWithArray:photos];
        weakSelf.videos = [NSMutableArray arrayWithArray:videos];
        weakSelf.objs = [NSMutableArray arrayWithArray:objs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view handleLoading];
            weakSelf.albumView.list = weakSelf.albums;
            if (model.albumName.length == 0) {
                model.albumName = @"相机胶卷";
            }
            [weakSelf.titleBtn setTitle:model.albumName forState:UIControlStateNormal];
            weakSelf.title = model.albumName;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionPush;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.fillMode = kCAFillModeForwards;
            transition.duration = 0.05;
            transition.subtype = kCATransitionFade;
            [[weakSelf.collectionView layer] addAnimation:transition forKey:@""];
            [weakSelf.collectionView reloadData];
            [weakSelf.view handleLoading];
        });
    }];
}

/**
 改变 预览、原图 按钮的状态

 @param model 选中的模型
 */
- (void)changeButtonClick:(CTMSGPhotoModel *)model isPreview:(BOOL)isPreview {
    if (self.albumManager.selectedList.count > 0) { // 选中数组已经有值时
        if (self.albumManager.selectionType != CTMSGAlbumListSelectionTypeVideo) {
            BOOL isVideo = NO, isPhoto = NO;
            for (CTMSGPhotoModel *model in self.albumManager.selectedList) {
                // 循环判断选中的数组中有没有视频或者图片
                if (model.type == CTMSGPhotoModelMediaTypePhoto ||
                    (model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive)) {
                    isPhoto = YES;
                }
                else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
                    isVideo = YES;
                }
            }
//            // 当数组中有图片时 原图按钮变为可操作状态
//            if ((isPhoto && isVideo) || isPhoto) {
//
//            } else { // 否则回复成初始状态
//                [self changeOriginalState:NO IsChange:NO];
//            }
        }
        
        self.rightBtn.enabled = YES;
        self.navItem.rightBarButtonItem.enabled = YES;
//        [self.rightBtn setBackgroundColor:[UIColor blueColor]];
//        CGFloat rightBtnH = self.rightBtn.frame.size.height;
//        CGFloat rightBtnW = [CTMSGAlbumTool getTextWidth:self.rightBtn.currentTitle height:rightBtnH fontSize:14];
//        self.rightBtn.ct_w = rightBtnW + 20;
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            if (isPreview) {
                self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
            }
        }
#endif
    } else {
        // 没有选中时 全部恢复成初始状态
//        [self changeOriginalState:NO IsChange:NO];
        self.rightBtn.enabled = NO;
        self.navItem.rightBarButtonItem.enabled = NO;
        [self.rightBtn setTitle:[NSBundle ctmsg_localizedStringForKey:@"下一步"] forState:UIControlStateNormal];
//        self.rightBtn.frame = CGRectMake(0, 0, 60, 25);
    }
}

- (void)p_goCameraVC {
    NSAssert(NO, @"暂不支持打开相机，自己集成");
    if (!_albumManager.showCamera) {
        return;
    }
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.view showImageHUDText:@"无法使用相机!"];
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return;
    }
}

- (void)p_goCameraViewController {
    NSAssert(NO, @"暂不支持打开相机，自己集成");
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.view showImageHUDText:@"无法使用相机!"];
        return;
    }
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return;
    }
    //    CTMSGCameraType type = 0;
    if (self.albumManager.selectionType == CTMSGAlbumListSelectionTypeAll) {
        //        if (self.photos.count > 0 && self.videos.count > 0) {
        //            type = CTMSGCameraTypePhotoAndVideo;
        //        }
        //        else if (self.videos.count > 0) {
        //            type = CTMSGCameraTypeVideo;
        //        }
        //        else {
        //            type = CTMSGCameraTypePhotoAndVideo;
        //        }
    }
    else if (self.albumManager.selectionType == CTMSGAlbumListSelectionTypePhoto) {
        //        type = CTMSGCameraTypePhoto;
    }
    else if (self.albumManager.selectionType == CTMSGAlbumListSelectionTypeVideo) {
        //        type = CTMSGCameraTypeVideo;
    }
}

#pragma mark - timer

- (void)observeAuthrizationStatusChange:(NSTimer *)timer {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [timer invalidate];
        [self.timer invalidate];
        self.timer = nil;
        [self.authorizationLb removeFromSuperview];
        
        if (self.albumManager.albums.count > 0) {
            if (self.albumManager.cacheAlbum) {
                self.albums = self.albumManager.albums.mutableCopy;
                [self p_ctmsg_getAllAlbums];
            }
        } else {
            [self p_ctmsg_getAllAlbums];
        }
    }
}

- (void)photoLibraryDidChange:(NSArray *)list {
    for (int i = 0; i < list.count ; i++) {
        NSDictionary *dic = list[i];
        PHFetchResultChangeDetails *collectionChanges = dic[@"collectionChanges"];
        CTMSGAlbumModel *albumModel = dic[@"model"];
        if (collectionChanges) {
            if ([collectionChanges hasIncrementalChanges]) {
                PHFetchResult *result = collectionChanges.fetchResultAfterChanges;
                
                if (collectionChanges.insertedObjects.count > 0) {
                    albumModel.asset = nil;
                    albumModel.result = result;
                    albumModel.photoCount = result.count;
                    if (self.selectedAlbum.index == albumModel.index) {
                        [self collectionChangeWithInseterData:collectionChanges.insertedObjects];
                    }
                }
                if (collectionChanges.removedObjects.count > 0) {
                    albumModel.asset = nil;
                    albumModel.result = result;
                    albumModel.photoCount = result.count;
                    
                    BOOL select = NO;
                    NSMutableArray *indexPathList = [NSMutableArray array];
                    for (PHAsset *asset in collectionChanges.removedObjects) {
                        NSString *property = @"asset";
                        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", property, asset];
                        if (i == 0) {
                            NSArray *newArray = [self.albumManager.selectedList filteredArrayUsingPredicate:pred];
                            if (newArray.count > 0) {
                                select = YES;
                                CTMSGPhotoModel *photoModel = newArray.firstObject;
                                photoModel.selected = NO;
//                                if ((photoModel.type == CTMSGPhotoModelMediaTypePhoto || photoModel.type == CTMSGPhotoModelMediaTypeGif) || photoModel.type == CTMSGPhotoModelMediaTypeLive) {
//                                    [self.albumManager.selectedPhotos removeObject:photoModel];
//                                } else {
//                                    [self.albumManager.selectedVideos removeObject:photoModel];
//                                }
                                [self.albumManager.selectedList removeObject:photoModel];
                            }
                        }
                        if (self.selectedAlbum.index == albumModel.index) {
                            CTMSGPhotoModel *photoModel;
                            if (asset.mediaType == PHAssetMediaTypeImage) {
                                NSArray *photoArray = [self.photos filteredArrayUsingPredicate:pred];
                                photoModel = photoArray.firstObject;
                                [self.photos removeObject:photoModel];
                            }else if (asset.mediaType == PHAssetMediaTypeVideo) {
                                NSArray *videoArray = [self.videos filteredArrayUsingPredicate:pred];
                                photoModel = videoArray.firstObject;
                                [self.videos removeObject:photoModel];
                            }
                            [indexPathList addObject:[NSIndexPath indexPathForItem:[self.objs indexOfObject:photoModel] inSection:0]];
                            [self.objs removeObject:photoModel];
                        }
                    }
                    if (select) {
                        [self changeButtonClick:self.albumManager.selectedList.lastObject isPreview:NO];
                    }
                    if (indexPathList.count > 0) {
                        [self.collectionView deleteItemsAtIndexPaths:indexPathList];
                    }
                }
//                if (collectionChanges.changedObjects.count > 0) {
//
//                }
//                if ([collectionChanges hasMoves]) {
//
//                }
            }
        }
    }
    self.albumView.list = self.albums;
}

- (void)collectionChangeWithInseterData:(NSArray *)array {
    NSInteger insertedCount = array.count;
    NSInteger cameraIndex = self.albumManager.showCamera ? 1 : 0;
    NSMutableArray *indexPathList = [NSMutableArray array];
    for (int i = 0; i < insertedCount; i++) {
        PHAsset *asset = array[i];
        CTMSGPhotoModel *photoModel = [[CTMSGPhotoModel alloc] init];
        photoModel.asset = asset;
        if (asset.mediaType == PHAssetMediaTypeImage) {
            photoModel.subType = CTMSGPhotoModelMediaSubTypePhoto;
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
                if (self.albumManager.singleSelected && self.albumManager.singleSelectedClip) {
                    photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                } else {
                    photoModel.type = self.albumManager.showGif ? CTMSGPhotoModelMediaTypeGif : CTMSGPhotoModelMediaTypePhoto;
                }
            } else {
                photoModel.type = CTMSGPhotoModelMediaTypePhoto;
                if (IOS9_1_OR_LATER && [CTMSGAlbumTool platform]) {
                    if (@available(iOS 9.1, *)) {
                        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            if (!self.albumManager.singleSelected) {
                                photoModel.type = self.albumManager.showLive ? CTMSGPhotoModelMediaTypeLive : CTMSGPhotoModelMediaTypePhoto;
                            }
                        }
                    }
                }
            }
            [self.photos insertObject:photoModel atIndex:0];
        }
        else if (asset.mediaType == PHAssetMediaTypeVideo) {
            photoModel.subType = CTMSGPhotoModelMediaSubTypeVideo;
            photoModel.type = CTMSGPhotoModelMediaTypeVideo;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                photoModel.avAsset = asset;
            }];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f",asset.duration];
            photoModel.videoTime = [CTMSGAlbumTool getNewTimeFromDurationSecond:timeLength.integerValue];
            [self.videos insertObject:photoModel atIndex:0];
        }
        photoModel.currentAlbumIndex = self.selectedAlbum.index;
        
        [self.objs insertObject:photoModel atIndex:cameraIndex];
        [indexPathList addObject:[NSIndexPath indexPathForItem:i + cameraIndex inSection:0]];
    }
    [self.collectionView insertItemsAtIndexPaths:indexPathList];
}

- (void)sortSelectList {
    int i = 0, j = 0, k = 0;
    for (CTMSGPhotoModel *model in self.albumManager.selectedList) {
        if (model.type == CTMSGPhotoModelMediaTypePhoto ||
            model.type == CTMSGPhotoModelMediaTypeGif ||
            model.type == CTMSGPhotoModelMediaTypeLive) {
            model.endIndex = i++;
        }
        else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
            model.videoIndex = j++;
        }
        model.endCollectionIndex = k++;
    }
}

//- (void)cleanSelectedList {
//    [self sortSelectList];
//    if (!self.albumManager.singleSelected) {
//        if ([self.delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//            [_delegate albumListViewControllerDidFinish:self];
//        }
//    } else {
//        if ([self.delegate respondsToSelector:@selector(albumListViewControllerDidCancel:)]) {
//            [self.delegate albumListViewControllerDidCancel:self];
//        }
//    }
//}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _objs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CTMSGPhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumListCell forIndexPath:indexPath];
    if (!self.albumManager.singleSelected) {
        cell.iconDic = self.albumManager.albumListCellIcon;
    }
    CTMSGPhotoModel *model = self.objs[indexPath.item];
    model.rowCount = self.albumManager.columnCount;
    cell.delegate = self;
    cell.maxTime = _albumManager.maxVideoDuration;
    cell.minTime = _albumManager.minVideoDuration;
    cell.delegate = self;
    cell.model = model;
    cell.singleSelected = _albumManager.maxNum == 1;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.navigationController.topViewController != self) {
        return;
    }
    CTMSGPhotoViewCell *cell = (CTMSGPhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.currentIndexPath = indexPath;
    CTMSGPhotoModel *model = self.objs[indexPath.item];
    //单选
    if (self.albumManager.singleSelected) {
        //视频
        if (model.type == CTMSGPhotoModelMediaTypeCamera) {
            [self p_goCameraViewController];
        }
        else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
            if (model.videoSecond > _albumManager.maxVideoDuration) {
                NSString * msg = [NSString stringWithFormat:@"最长%d秒", (int)_albumManager.maxVideoDuration];
                [self.view showLoadingHUDText:msg];
//                [self.view showTextHUD:msg];
                return;
            } else if (model.videoSecond < _albumManager.minVideoDuration) {
                NSString * msg = [NSString stringWithFormat:@"最短%d秒", (int)_albumManager.minVideoDuration];
                [self.view showLoadingHUDText:msg];
                return;
            }
            if (cell.model.isIcloud) {
                [self.view showImageHUDText:[NSBundle ctmsg_localizedStringForKey:@"尚未从iCloud上下载，请至相册下载完毕后选择"]];
                return;
            }
            CTMSGVideoPreviewController *previewVC = [[CTMSGVideoPreviewController alloc] init];
            previewVC.delegate = self;
            previewVC.modelArray = self.objs;
            previewVC.manager = self.albumManager;
            previewVC.currentModelIndex = self.currentIndexPath.row;
            previewVC.albumManager = _albumManager;
            [self.navigationController pushViewController:previewVC animated:NO];
        }
        else {
            if (_albumManager.selectionType == CTMSGAlbumListSelectionTypePhoto) {
                if (_albumManager.singleSelectedClip) {
//                    [INTCTVideoCompressHelper fetchImage:model.asset image:^(UIImage *images) {
//                        if (images.size.width < _albumManager.minWidth || images.size.height < _albumManager.minHeight) {
//                            [self.view showTextHUD:@"图片太小"];
//                            return ;
//                        }
//                        if (images) {
//                            [self pushEdit:images];
//                        }
//                    }];
//                    return;
                } else {
                    
                }
                //                INTCTAlbumPreviewViewController *vc = [[INTCTAlbumPreviewViewController alloc] init];
                //                vc.modelList = self.photos;
                //                vc.index = [self.photos indexOfObject:model];
                //                vc.delegate = self;
                //                vc.manager = self.albumManager;
                //                vc.albumManager = _albumManager;
                //                self.navigationController.delegate = vc;
                //                [self.navigationController pushViewController:vc animated:YES];
                //                return;
            }
            CTMSGVideoPreviewController *previewVC = [[CTMSGVideoPreviewController alloc] init];
            previewVC.delegate = self;
            previewVC.modelArray = self.objs;
            previewVC.manager = self.albumManager;
            previewVC.currentModelIndex = self.currentIndexPath.row;
            previewVC.albumManager = _albumManager;
            [self.navigationController pushViewController:previewVC animated:NO];
        }
        return;
    }
    if (_albumManager.selectionType == CTMSGAlbumListSelectionTypeAll) {
        if (model.type == CTMSGPhotoModelMediaTypeVideo) {
            if (model.videoSecond > _albumManager.maxVideoDuration) {
                return;
            }
            if (model.videoSecond < _albumManager.minVideoDuration) {
                return;
            }
        }
        CTMSGVideoPreviewController *previewVC = [[CTMSGVideoPreviewController alloc] init];
        previewVC.delegate = self;
        previewVC.modelArray = self.objs;
        previewVC.manager = self.albumManager;
        previewVC.currentModelIndex = self.currentIndexPath.row;
        previewVC.albumManager = _albumManager;
        [self.navigationController pushViewController:previewVC animated:NO];
        return;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    CTMSGPhotoViewCell *myCell = (CTMSGPhotoViewCell *)cell;
    [myCell cancelRequest];
    if (!myCell.model.selected && myCell.model.thumbPhoto) {
        if (myCell.model.type != CTMSGPhotoModelMediaTypeCamera) {
            //            && myCell.model.type != CTMSGPhotoModelMediaTypeCameraPhoto &&
            //            myCell.model.type != CTMSGPhotoModelMediaTypeCameraVideo
            myCell.model.thumbPhoto = nil;
        }
    }
}

#pragma mark - CTMSGPhotoViewCellDelegate
/**
 cell选中代理 右上角选择方框
 */
- (void)cellDidSelectedBtnClick:(CTMSGPhotoViewCell *)cell Model:(CTMSGPhotoModel *)model {
    if (!cell.selectBtn.selected) { // 弹簧果冻动画效果
        NSString *str = [CTMSGAlbumTool maximumOfJudgment:model viewmodel:self.albumManager];
        if (str) {
            [self.view showImageHUDText:str];
            return;
        }
        [cell.maskView.layer removeAllAnimations];
        cell.maskView.hidden = NO;
        cell.maskView.alpha = 0;
        [UIView animateWithDuration:0.15 animations:^{
            cell.maskView.alpha = 1;
        }];
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim.duration = 0.25;
        anim.values = @[@(1.2),@(0.8),@(1.1),@(0.9),@(1.0)];
        [cell.selectBtn.layer addAnimation:anim forKey:@""];
    } else {
        cell.maskView.hidden = YES;
    }
    cell.selectBtn.selected = !cell.selectBtn.selected;
    cell.model.selected = cell.selectBtn.selected;
    BOOL selected = cell.selectBtn.selected;
    
    if (selected) { // 选中之后需要做的
        model.thumbPhoto = cell.imageView.image;
        if (model.type == CTMSGPhotoModelMediaTypeLive) {
            [cell startLivePhoto];
        }
//        if (model.type == CTMSGPhotoModelMediaTypePhoto ||
//            (model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive)) { // 为图片时
//            [self.albumManager.selectedPhotos addObject:model];
//        }
//        else if (model.type == CTMSGPhotoModelMediaTypeVideo) { // 为视频时
//            [self.albumManager.selectedVideos addObject:model];
//        }
        [self.albumManager.selectedList addObject:model];
        self.selectedAlbum.selectCount++;
    } else { // 取消选中之后的
        model.selectedPhotosIndex = 0;
        model.thumbPhoto = nil;
        model.previewPhoto = nil;
        if (model.type == CTMSGPhotoModelMediaTypeLive) {
            [cell stopLivePhoto];
        }
//        if (model.type == CTMSGPhotoModelMediaTypePhoto ||
//            model.type == CTMSGPhotoModelMediaTypeGif ||
//            model.type == CTMSGPhotoModelMediaTypeLive) {
//            [self.albumManager.selectedPhotos removeObject:model];
//        } else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
//            [self.albumManager.selectedVideos removeObject:model];
//        }
        self.selectedAlbum.selectCount--;
        [self.albumManager.selectedList removeObject:model];
    }
    // 改变 预览、原图 按钮的状态
    [self changeButtonClick:model isPreview:NO];
    //    NSMutableArray * models = [NSMutableArray arrayWithCapacity:self.albumManager.selectedPhotos.count];
    
    for (int i = 0; i < self.albumManager.selectedList.count; i++) {
        CTMSGPhotoModel * model = [self.albumManager.selectedList objectAtIndex:i];
        model.selectedPhotosIndex = i;
        NSIndexPath * indexpath = [NSIndexPath indexPathForItem:[self.objs indexOfObject:model] inSection:0];
        CTMSGPhotoViewCell * cell = (CTMSGPhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
        [cell.selectBtn setTitle:[NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] forState:UIControlStateNormal];
    }
    
    if (model.selected) {
        [cell.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_act"] forState:UIControlStateSelected];
    } else {
        [cell.selectBtn setTitle:@"" forState:UIControlStateNormal];
        [cell.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_def"] forState:UIControlStateSelected];
    }
}

/**
 cell改变livephoto的状态
 
 @param model 模型
 */
- (void)cellChangeLivePhotoState:(CTMSGPhotoModel *)model {
    CTMSGPhotoModel *PHModel = [self.albumManager.selectedList objectAtIndex:[self.albumManager.selectedList indexOfObject:model]];
    PHModel.isCloseLivePhoto = model.isCloseLivePhoto;
    
//    CTMSGPhotoModel *PHModel1 = [self.albumManager.selectedPhotos objectAtIndex:[self.albumManager.selectedPhotos indexOfObject:model]];
//    PHModel1.isCloseLivePhoto = model.isCloseLivePhoto;
}

#pragma mark - CTMSGAlbumListViewDelegate
/**
 点击相册列表的代理
 
 @param model 点击的相册模型
 @param anim 是否需要展开动画
 */
- (void)didTableViewCellClick:(CTMSGAlbumModel *)model animate:(BOOL)anim {
    if (anim) {
        [self pushAlbumList:self.titleBtn];
    }
    if ([self.selectedAlbum.result isEqual:model.result]) {
        return;
    }
    // 当前相册选中的个数
    self.currentSelectCount = model.selectCount;
    self.selectedAlbum = model;
    self.title = model.albumName;
    [self.titleBtn setTitle:model.albumName forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    // 获取指定相册的所有图片
    [self.albumManager fetchAllPhotoForPHFetchResult:model.result index:model.index result:^(NSArray<CTMSGPhotoModel *> * _Nonnull photos, NSArray<CTMSGPhotoModel *> * _Nonnull videos, NSArray<CTMSGPhotoModel *> * _Nonnull objs) {
        weakSelf.photos = [NSMutableArray arrayWithArray:photos];
        weakSelf.videos = [NSMutableArray arrayWithArray:videos];
        weakSelf.objs = [NSMutableArray arrayWithArray:objs];
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionPush;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.fillMode = kCAFillModeForwards;
        transition.duration = 0.2;
        transition.delegate = weakSelf;
        transition.subtype = kCATransitionFade;
        [[weakSelf.collectionView layer] addAnimation:transition forKey:@""];
        //        weakSelf.selectOtherAlbum = YES;
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }];
}

#pragma mark - CTMSGVideoPreviewControllerDelegate

/**
 查看图片时 选中或取消选中时的代理
 
 @param model 当前操作的模型
 @param state 状态
 */
- (void)allPreviewdidSelectedClick:(CTMSGPhotoModel *)model AddOrDelete:(BOOL)state {
    if (state) { // 选中
        self.selectedAlbum.selectCount++;
    }else { // 取消选中
        self.selectedAlbum.selectCount--;
    }
    model.selected = state;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.objs indexOfObject:model] inSection:0]]];
    // 改变 预览、原图 按钮的状态
    [self changeButtonClick:model isPreview:YES];
    
    for (int i = 0; i < self.albumManager.selectedList.count; i++) {
        CTMSGPhotoModel * model = [self.albumManager.selectedList objectAtIndex:i];
        model.selectedPhotosIndex = i;
        NSIndexPath * indexpath = [NSIndexPath indexPathForItem:[self.objs indexOfObject:model] inSection:0];
        CTMSGPhotoViewCell * cell = (CTMSGPhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
        [cell.selectBtn setTitle:[NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] forState:UIControlStateNormal];
        [cell.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_act"] forState:UIControlStateNormal];
    }
}

- (void)previewControllerDidSelect:(CTMSGVideoPreviewController *)previewController model:(CTMSGPhotoModel *)model {
    
}

- (void)previewControllerDidDone:(CTMSGVideoPreviewController *)previewController {
    
}

//- (void)videoPreviewUpload:(CTMSGVideoPreviewController *)previewController success:(BOOL)isSuccess {
//    if (isSuccess) {
//        if ([_delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//            [_delegate albumListViewControllerDidFinish:self];
//        }
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
//}
//
//- (void)imageUploadFromVideo:(UIImage *)originImage clipImage:(UIImage *)clipImage success:(BOOL)isSuccess {
//    if ([_delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//        [_delegate albumListViewControllerDidFinish:self];
//        if (isSuccess) {
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
//}
//
//- (void)mixUploadFromAlbumPreview:(CTMSGVideoPreviewController *)previewController
//                           source:(id)albums
//                          success:(BOOL)isSuccess
//                           result:(id)result {
//    if (isSuccess) {
//        if ([self.delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//            [self.delegate albumListViewControllerDidFinish:self];
//        }
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
//}

//#pragma mark - INTCTAlbumPreviewViewControllerDelegate
//
//- (void)imageUploadFromPhoto:(UIImage *)originImage
//                   clipImage:(UIImage *)clipImage
//                     success:(BOOL)isSuccess
//                      result:(id)result {
//    if ([_delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//        [_delegate albumListViewControllerDidFinish:self];
//    }
//    if (isSuccess) {
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
//}
//
//- (void)previewUpload:(INTCTAlbumPreviewViewController *)controller source:(id)albums success:(BOOL)isSuccess result:(id)result {
//    if (isSuccess) {
//        if ([_delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//            [_delegate albumListViewControllerDidFinish:self];
//        }
//    }
//}

//#pragma mark - INTCTImageClipDelegate
//- (void)imageUploadFromClip:(UIImage *)originImage
//                  clipImage:(UIImage *)clipImage
//                    success:(BOOL)isSuccess
//                     result:(id)result
//                 originPath:(NSString *)originPath
//                   clipPath:(NSString *)clipPath {
//    if (isSuccess) {
//        if ([_delegate respondsToSelector:@selector(albumListViewControllerDidFinish:)]) {
//            [_delegate albumListViewControllerDidFinish:self];
//        }
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
//}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self.collectionView.layer removeAllAnimations];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

/**
 查看图片时 选中或取消选中时的代理
 
 @param model 当前操作的模型
 @param state 状态
 */
//- (void)didSelectedClick:(CTMSGPhotoModel *)model AddOrDelete:(BOOL)state {
//    if (state) { // 选中
//        self.selectedAlbum.selectCount++;
//    }else { // 取消选中
//        self.selectedAlbum.selectCount--;
//    }
//    model.selected = state;
//    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.objs indexOfObject:model] inSection:0]]];
//    // 改变 预览、原图 按钮的状态
//    [self changeButtonClick:model isPreview:YES];
//    for (int i = 0; i < self.albumManager.selectedPhotos.count; i++) {
//        CTMSGPhotoModel * model = [self.albumManager.selectedPhotos objectAtIndex:i];
//        model.selectedPhotosIndex = i;
//        NSIndexPath * indexpath = [NSIndexPath indexPathForItem:[self.objs indexOfObject:model] inSection:0];
//        CTMSGPhotoViewCell * cell = (CTMSGPhotoViewCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
//        [cell.selectBtn setTitle:[NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] forState:UIControlStateNormal];
//        [cell.selectBtn setBackgroundImage:[UIImage imageNamed:@"intct_album_1"] forState:UIControlStateNormal];
//    }
//}

/**
 查看视频时 选中/取消选中 的代理
 
 @param model 模型
 */

//- (void)previewVideoDidSelectedClick:(CTMSGPhotoModel *)model
//{
//    [self.collectionView reloadData];
//    // 改变 预览、原图 按钮的状态
//    [self changeButtonClick:model isPreview:YES];
//}

/**
 查看视频时点击下一步按钮的代理
 */
//- (void)previewVideoDidNextClick {
//    [self didNextClick:self.rightBtn];
//}

#pragma mark - lazy property
- (UILabel *)authorizationLb {
    if (!_authorizationLb) {
        _authorizationLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)];
        _authorizationLb.text = [NSBundle ctmsg_localizedStringForKey:@"无法访问照片\n请点击这里前往设置中允许访问照片"];
        _authorizationLb.textAlignment = NSTextAlignmentCenter;
        _authorizationLb.numberOfLines = 0;
        _authorizationLb.textColor = [UIColor blackColor];
        _authorizationLb.font = [UIFont systemFontOfSize:15];
        _authorizationLb.userInteractionEnabled = YES;
        [_authorizationLb addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSetup)]];
    }
    return _authorizationLb;
}

- (CTMSGPhotoCustomNavigationBar *)navBar {
    if (!_navBar) {
        _navBar = [[CTMSGPhotoCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.ct_w, CTMSGNavBarHeight)];
        [_navBar pushNavigationItem:self.navItem animated:NO];
        _navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _navBar.tintColor = [UIColor whiteColor];
        [_navBar setBackgroundColor:[UIColor whiteColor]];
    }
    return _navBar;
}

- (UINavigationItem *)navItem {
    if (!_navItem) {
        _navItem = [[UINavigationItem alloc] init];
        _navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
        
        CTMSGAlbumTitleButton *titleBtn = [CTMSGAlbumTitleButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
        //        [titleBtn setTitleColor:self.albumManager.UIManager.navTitleColor forState:UIControlStateNormal];
        [titleBtn setImage:[CTMSGAlbumTool ctmsg_imageNamed:@"headlines_icon_arrow"] forState:UIControlStateNormal];
        titleBtn.frame = CGRectMake(0, 0, 150, 30);
        [titleBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(pushAlbumList:) forControlEvents:UIControlEventTouchUpInside];
        [titleBtn setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        self.titleBtn = titleBtn;
        _navItem.title = @"相机胶卷";
        _navItem.titleView = self.titleBtn;
    }
    return _navItem;
}

/**
 下一步按钮
 
 @return 按钮
 */
- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setTitle:[NSBundle ctmsg_localizedStringForKey:@"下一步"] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor ctmsg_colorB1B1B1] forState:UIControlStateDisabled];
        _rightBtn.backgroundColor = [UIColor clearColor];
        [_rightBtn addTarget:self action:@selector(didNextClick:) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _rightBtn.frame = CGRectMake(0, 0, 60, 25);
    }
    return _rightBtn;
}

- (UIButton *)leftBtn {
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor ctmsg_color212121] forState:UIControlStateNormal];
        _leftBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_leftBtn addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn.frame = CGRectMake(0, 0, 60, 25);
    }
    return _leftBtn;
}

/**
 小菊花
 
 @return 小菊花
 */
- (UIActivityIndicatorView *)indica {
    if (!_indica) {
        _indica = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indica;
}

/**
 展开相册列表时的黑色背景
 @return 视图
 */
- (UIView *)albumsBgView {
    if (!_albumsBgView) {
        _albumsBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CTMSGNavBarHeight, self.view.frame.size.width, self.view.frame.size.height - CTMSGNavBarHeight)];
        _albumsBgView.hidden = YES;
        _albumsBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _albumsBgView.alpha = 0;
        [_albumsBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didalbumsBgViewClick)]];
    }
    return _albumsBgView;
}

#pragma mark - --------
/**
 改变原图按钮的状态信息
 
 @param selected 是否选中
 @param isChange 是否改变成初始状态
 */
//- (void)changeOriginalState:(BOOL)selected IsChange:(BOOL)isChange {
//    if (selected) { // 选中时
//        if (isChange) {
//
//        }
//        [self.indica startAnimating];
//        self.indica.hidden = NO;
//
//        __weak typeof(self) weakSelf = self;
//        // 获取一组图片的大小
//        [CTMSGAlbumTool fetchPhotosBytes:self.albumManager.selectedPhotos completion:^(NSString *totalBytes) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                if (!weakself.albumManager.isOriginal) {
////                    return;
////                }
////                weakself.albumManager.photosTotalBtyes = totalBytes;
//                [weakSelf.indica stopAnimating];
//                weakSelf.indica.hidden = YES;
//            });
//        }];
//    } else {// 取消选中 恢复成初始状态
//        [self.indica stopAnimating];
//        self.indica.hidden = YES;
////        self.albumManager.photosTotalBtyes = nil;
//    }
//}

/**
 查看图片时点击下一步按钮的代理
 */
- (void)previewDidNextClick
{
    [self didNextClick:self.rightBtn];
}

//#pragma mark - < CTMSGPhotoEditViewControllerDelegate >
//- (void)editViewControllerDidNextClick:(CTMSGPhotoModel *)model {
//    [self.albumManager.selectedCameraList addObject:model];
//    [self.albumManager.selectedCameraPhotos addObject:model];
//    [self.albumManager.selectedPhotos addObject:model];
//    [self.albumManager.selectedList addObject:model];
//    [self didNextClick:self.rightBtn];
//}

- (void)pushEdit:(UIImage *)image {
//    INTCTImageClipViewController * clip = [[INTCTImageClipViewController alloc] init];
//    clip.image = image;
//    clip.delegate = self;
//    INTCTImageClipalbumManager * albumManager = [[INTCTImageClipalbumManager alloc] initWithNSDictionary:_albumManager.aliDic];
//    clip.albumManager = albumManager;
//    [self presentViewController:clip animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.albumManager.selecting = NO;
    NSLog(@"🤩🤩🤩CTMSGAlbumListViewController deallc🤩🤩🤩");
}
@end

