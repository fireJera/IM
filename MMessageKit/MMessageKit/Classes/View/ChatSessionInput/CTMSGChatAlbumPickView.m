//
//  CTMSGChatAlbumPickView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatAlbumPickView.h"
#import "CTMSGChatAlbumCell.h"
#import "CTMSGAlbumManager.h"
#import "CTMSGAlbumTool.h"
#import "CTMSGPhotoModel.h"
#import "CTMSGAlbumModel.h"
#import "CTMSGChatAlbumCell.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGUtilities.h"

static NSString * const kAlbumCell = @"albumCell";

@interface CTMSGChatAlbumPickView () <UICollectionViewDelegateFlowLayout, CTMSGChatAlbumCellDelegate
, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) CTMSGAlbumManager * albumManager;
@property (nonatomic, strong) NSMutableArray<CTMSGPhotoModel *> *objs;
@property (nonatomic, strong) CTMSGAlbumModel * allPhotoModel;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CTMSGChatAlbumPickView

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat selfWidth = self.frame.size.width, selfHeight = self.frame.size.height;
    CGFloat bottomHeight = 44, collectionHeight = selfHeight - bottomHeight;
    _collectionView.frame = (CGRect){0, 0, selfWidth, collectionHeight};
    _bottomView.frame = (CGRect){0, collectionHeight, selfWidth, bottomHeight};
    CGFloat albumLeft = 14, albumWidth = 80, albumHeight = 22, albumTop = (bottomHeight - albumHeight) /2;
    _albumBtn.frame = (CGRect){albumLeft, albumTop, albumWidth, albumHeight};
    CGFloat sendWidth = 52, sendHeight = 26, sendLeft = selfWidth - albumLeft - sendWidth, sendTop = (bottomHeight - sendHeight) /2;
    _sendBtn.frame = (CGRect){sendLeft, sendTop, sendWidth, sendHeight};
}

#pragma mark - UICollectionViewDataSource

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return _objs.count;
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _objs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _objs.count) {
        CTMSGPhotoModel * model = _objs[indexPath.row];
        CTMSGChatAlbumCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumCell forIndexPath:indexPath];
//        __weak typeof(self) weakSelf = self;
        cell.delegate = self;
        cell.model = model;
//        PHImageRequestID requestId =
        [CTMSGAlbumTool getImageWithModel:model completion:^(UIImage *image, CTMSGPhotoModel *model) {
//            if (weakSelf.model == model) {
            cell.imageView.image = image;
//            }
        }];
        cell.pickBtn.selected = model.selected;
        if (model.selected) {
            [cell.pickBtn setTitle:[NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] forState:UIControlStateNormal];
        } else {
            [cell.pickBtn setTitle:@"" forState:UIControlStateNormal];
        }
//        self.requestID = requestId;
//        cell.imageView.image = model.thumbPhoto;
        return cell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumCell forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _objs.count) {
        CTMSGPhotoModel * model = _objs[indexPath.row];
        if (CGSizeEqualToSize(CGSizeZero, model.cacheSize)) {
            CGFloat height = 176;
            CGFloat width = model.imageSize.width * height / model.imageSize.height;
            model.cacheSize = (CGSize){width, height};
        }
        return model.cacheSize;
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - cellDelegate

- (void)cellDidSelectedBtnClick:(CTMSGChatAlbumCell *)cell model:(CTMSGPhotoModel *)model {
    NSParameterAssert(cell && model);
    if (!model || !cell) {
        return;
    }
    if (!cell.pickBtn.selected) { // 弹簧果冻动画效果
        if (_albumManager.selectedList.count > 8) {
            [_delegate pickNumBeyondMax];
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
        [cell.pickBtn.layer addAnimation:anim forKey:@""];
    } else {
        cell.maskView.hidden = YES;
    }
    cell.pickBtn.selected = !cell.pickBtn.selected;
    cell.model.selected = cell.pickBtn.selected;
    BOOL selected = cell.pickBtn.selected;

    if (selected) { // 选中之后需要做的
        if (model.type == CTMSGPhotoModelMediaTypeLive) {
//            [cell startLivePhoto];
        }
//        if (model.type == CTMSGPhotoModelMediaTypePhoto ||
//            (model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive)) { // 为图片时
//            [self.albumManager.selectedPhotos addObject:model];
//        }
//        else if (model.type == CTMSGPhotoModelMediaTypeVideo) { // 为视频时
//            [self.albumManager.selectedVideos addObject:model];
//        }
        [self.albumManager.selectedList addObject:model];
//        self.albumManager.selectedCount++;
    } else { // 取消选中之后的
        model.selectedPhotosIndex = 0;
        if (model.type == CTMSGPhotoModelMediaTypeLive) {
//            [cell stopLivePhoto];
        }
//        if ((model.type == CTMSGPhotoModelMediaTypePhoto || model.type == CTMSGPhotoModelMediaTypeGif) ||
//            (model.type == CTMSGPhotoModelMediaTypeVideo || model.type == CTMSGPhotoModelMediaTypeLive)) {
//            if (model.type == CTMSGPhotoModelMediaTypePhoto ||
//                model.type == CTMSGPhotoModelMediaTypeGif ||
//                model.type == CTMSGPhotoModelMediaTypeLive) {
//                [self.albumManager.selectedPhotos removeObject:model];
//            }
//            else if (model.type == CTMSGPhotoModelMediaTypeVideo) {
//                [self.albumManager.selectedVideos removeObject:model];
//            }
//        }
//        self.albumModel.selectedCount--;
        [self.albumManager.selectedList removeObject:model];
    }
    // 改变 预览、原图 按钮的状态
    [self p_ctmsg_changeButtonClick:model];
    //    NSMutableArray * models = [NSMutableArray arrayWithCapacity:self.manager.selectedPhotos.count];

    for (int i = 0; i < self.albumManager.selectedList.count; i++) {
        CTMSGPhotoModel * model = [self.albumManager.selectedList objectAtIndex:i];
        model.selectedPhotosIndex = i;
        NSIndexPath * indexpath = [NSIndexPath indexPathForItem:[self.objs indexOfObject:model] inSection:0];
        CTMSGChatAlbumCell * cell = (CTMSGChatAlbumCell *)[self.collectionView cellForItemAtIndexPath:indexpath];
        [cell.pickBtn setTitle:[NSString stringWithFormat:@"%d", (int)(model.selectedPhotosIndex + 1)] forState:UIControlStateNormal];
    }

    if (model.selected) {
        cell.pickBtn.selected = YES;
//        [cell.pickBtn setBackgroundImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_checkbox_s"] forState:UIControlStateSelected];
    } else {
        [cell.pickBtn setTitle:@"" forState:UIControlStateNormal];
        cell.pickBtn.selected = NO;
//        [cell.pickBtn setBackgroundImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_checkbox_s"] forState:UIControlStateSelected];
    }
//    [_collectionView reloadData];
}

#pragma mark - touch event

- (void)sendPhoto:(UIButton *)sender {
    sender.enabled = NO;
    __block NSMutableArray<PHAsset *>* albums = [NSMutableArray array];
    [self.albumManager.selectedList enumerateObjectsUsingBlock:^(CTMSGPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == CTMSGPhotoModelMediaTypePhoto ||
            obj.type == CTMSGPhotoModelMediaTypeGif ||
            obj.type == CTMSGPhotoModelMediaTypeLive ) {
            [albums addObject:obj.asset];
        }
    }];
    [CTMSGUtilities fetchImages:albums images:^(NSArray<UIImage *> * _Nonnull images) {
        sender.enabled = YES;
        if ([_delegate respondsToSelector:@selector(sendImages:)]) {
            [_delegate sendImages:images];
        }
        [_albumManager.selectedList enumerateObjectsUsingBlock:^(CTMSGPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = NO;
            obj.selectedPhotosIndex = 0;
        }];
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [_albumManager.selectedList removeAllObjects];
        [_collectionView reloadData];
    }];
}

- (void)openAlbum:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(pickViewClickOpenAlbum)]) {
        [_delegate pickViewClickOpenAlbum];
    }
}


#pragma mark - timer

- (void)observeAuthrizationStatusChange:(NSTimer *)timer {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [timer invalidate];
        [self.timer invalidate];
        self.timer = nil;
        
        if (self.albumManager.albums.count > 0) {
            if (self.albumManager.cacheAlbum) {
                [self p_getAllAlbums];
            }
        } else {
            [self p_getAllAlbums];
        }
    }
}

#pragma mark - private

- (void)p_getAllAlbums {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __weak typeof(self) weakSelf = self;
        [self.albumManager fetchAllAlbum:^(NSArray<CTMSGAlbumModel *> * _Nonnull albums) {
            weakSelf.allPhotoModel = albums.firstObject;
            [weakSelf p_getAlbumPhotos];
        }];
    });
}

- (void)p_getAlbumPhotos {
    __weak typeof(self) weakSelf = self;
    [self.albumManager fetchPhotoForPHFetchResult:self.allPhotoModel.result limitCount:50 index:0 result:^(NSArray<CTMSGPhotoModel *> * _Nonnull photos, NSArray<CTMSGPhotoModel *> * _Nonnull videos, NSArray<CTMSGPhotoModel *> * _Nonnull objs) {
        weakSelf.objs = [NSMutableArray arrayWithArray:objs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
        });
    }];
}

- (void)p_ctmsg_changeButtonClick:(CTMSGPhotoModel *)model {
    _sendBtn.enabled = self.albumManager.selectedList.count > 0;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_collectionView];
    [_collectionView registerClass:[CTMSGChatAlbumCell class] forCellWithReuseIdentifier:kAlbumCell];
    _bottomView = [[UIView alloc] init];
    [self addSubview:_bottomView];
    _sendBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"发送" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.enabled = NO;
        button.backgroundColor = [UIColor ctmsg_color8358D0];
        button.layer.cornerRadius = 5;
        [button addTarget:self action:@selector(sendPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:button];
        button;
    });
    
    _albumBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"打开相册" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor ctmsg_color31A3FF] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(openAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:button];
        button;
    });
    _albumManager = [[CTMSGAlbumManager alloc] initWithSelectionType:CTMSGAlbumListSelectionTypePhoto];
    
    // 获取当前应用对照片的访问授权状态
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange:) userInfo:nil repeats:YES];
    } else {
        [self p_getAllAlbums];        
    }
}

@end
