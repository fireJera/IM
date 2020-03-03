//
//  CTMSGPhotoViewCell.m
//  微博照片选择
//
//  Created by 洪欣 on 17/2/8.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "CTMSGPhotoViewCell.h"
#import "CTMSGAlbumTool.h"
#import "UIButton+CTMSG_Cat.h"
#import <PhotosUI/PhotosUI.h>
#import "CTMSGPhotoModel.h"
//#import "CTMSGPhotoPreviewViewController.h"

@interface CTMSGPhotoViewCell ()
// <UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *cameraBtn;
@property (strong, nonatomic) UIImageView *videoIcon;
@property (strong, nonatomic) UILabel *videoTime;
@property (strong, nonatomic) UIImageView *gifIcon;
@property (strong, nonatomic) UIImageView *liveIcon;
@property (strong, nonatomic) UIButton *liveBtn;
@property (strong, nonatomic) PHLivePhotoView *livePhotoView NS_AVAILABLE_IOS(9.1);
@property (copy, nonatomic) NSString *localIdentifier;
@property (strong, nonatomic) UIImageView *previewImg;
@property (assign, nonatomic) PHImageRequestID liveRequestID;
@property (assign, nonatomic) BOOL addImageComplete;
@property (strong, nonatomic) UIButton *iCloudBtn;
@property (strong, nonatomic) UIImageView *iCloudIcon;

@end

@implementation CTMSGPhotoViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.requestID = 0; 
        [self p_ctmsg_setup];
    }
    return self;
}

- (void)p_ctmsg_setup {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.videoIcon];
    [self.bottomView addSubview:self.videoTime];
    [self.contentView addSubview:self.gifIcon];
    [self.contentView addSubview:self.liveIcon];
    [self.contentView addSubview:self.maskView];
    [self.contentView addSubview:self.liveBtn];
    [self.contentView addSubview:self.iCloudBtn];
    [self.iCloudBtn addSubview:self.iCloudIcon];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.cameraBtn];
}

- (void)setIconDic:(NSDictionary *)iconDic {
    _iconDic = iconDic;
    if (self.addImageComplete) {
        return;
    }
    if (!self.videoIcon.image) {
        self.videoIcon.image = iconDic[@"videoIcon"];
    }
    if (!self.gifIcon.image) {
        self.gifIcon.image = iconDic[@"gifIcon"];
    }
    if (!self.liveIcon.image) {
        self.liveIcon.image = iconDic[@"liveIcon"];
    }
    if (!self.liveBtn.currentImage) {
        [self.liveBtn setImage:iconDic[@"liveBtnImageNormal"] forState:UIControlStateNormal];
        [self.liveBtn setImage:iconDic[@"liveBtnImageSelected"] forState:UIControlStateSelected];
    }
    if (!self.liveBtn.currentBackgroundImage) {
        [self.liveBtn setBackgroundImage:iconDic[@"liveBtnBackgroundImage"] forState:UIControlStateNormal];
    }
    if (!self.selectBtn.currentImage) {
        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_def"] forState:UIControlStateNormal];
        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_act"] forState:UIControlStateSelected];
    }
    if (!self.iCloudIcon.image) {
        self.iCloudIcon.image = iconDic[@"icloudIcon"];
        self.iCloudIcon.ct_size = self.iCloudIcon.image.size;
        self.iCloudIcon.center = self.selectBtn.center;
    }
    self.addImageComplete = YES;
}

- (void)setSingleSelected:(BOOL)singleSelected {
    _singleSelected = singleSelected;
    if (singleSelected) {
        [self.maskView removeFromSuperview];
        [self.selectBtn removeFromSuperview];
    }
}

- (void)setModel:(CTMSGPhotoModel *)model {
    _model = model;
    self.iCloudBtn.hidden = YES;
    self.selectBtn.hidden = NO;
    if (model.isIcloud) {
        self.iCloudBtn.hidden = NO;
        self.selectBtn.hidden = YES;
    }
    if (model.type == CTMSGPhotoModelMediaTypeCamera) {
        self.imageView.image = model.thumbPhoto;
    } else {
        __weak typeof(self) weakSelf = self;
        PHImageRequestID requestId = [CTMSGAlbumTool getImageWithModel:model completion:^(UIImage *image, CTMSGPhotoModel *model) {
            if (weakSelf.model == model) {
                weakSelf.imageView.image = image;
            }
        }];
        self.requestID = requestId;
    }

    self.videoTime.text = model.videoTime;
    self.liveIcon.hidden = YES;
    self.liveBtn.hidden = YES;
    self.gifIcon.hidden = YES;
    self.cameraBtn.hidden = YES;
    if (model.type == CTMSGPhotoModelMediaTypeVideo) {
        self.bottomView.hidden = NO;
        if (model.videoSecond > _maxTime || model.videoSecond < _minTime) {
            _bottomView.frame = self.bounds;
            _bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        } else  {
            _bottomView.frame = CGRectMake(0, self.ct_h - 25, self.ct_w, 25);
            _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        }
        _videoTime.frame = CGRectMake(0, self.bottomView.frame.size.height - 25, self.bottomView.frame.size.width - 5, 25);
    } else if (model.type == CTMSGPhotoModelMediaTypePhoto || (model.type == CTMSGPhotoModelMediaTypeGif || model.type == CTMSGPhotoModelMediaTypeLive)){
        self.bottomView.hidden = YES;
        if (model.type == CTMSGPhotoModelMediaTypeGif) {
            self.gifIcon.hidden = NO;
        } else if (model.type == CTMSGPhotoModelMediaTypeLive) {
            self.liveIcon.hidden = NO;
            if (model.selected) {
                self.liveIcon.hidden = YES;
                self.liveBtn.hidden = NO;
                self.liveBtn.selected = model.isCloseLivePhoto;
            }
        }
    } else if (model.type == CTMSGPhotoModelMediaTypeCamera){
        [self.cameraBtn setImage:model.thumbPhoto forState:UIControlStateNormal];
        self.cameraBtn.hidden = NO;
    }
    self.maskView.hidden = !model.selected;
    self.selectBtn.selected = model.selected;
    if (model.selected) {
        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_act"] forState:UIControlStateSelected];
        [self.selectBtn setTitle:[NSString stringWithFormat:@"%d", model.selectedPhotosIndex + 1] forState:UIControlStateNormal];
    } else {
        [self.selectBtn setTitle:@"" forState:UIControlStateNormal];
        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_def"] forState:UIControlStateNormal];
    }
}

#pragma mark - touch event

- (void)didICloudBtnCLick {
    [[self viewController].view showImageHUDText:[NSBundle ctmsg_localizedStringForKey:@"尚未从iCloud上下载，请至相册下载完毕后选择"]];
}

- (void)didLivePhotoBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    self.model.isCloseLivePhoto = button.selected;
    if (button.selected) {
        if (@available(iOS 9.1, *)) {
            [self.livePhotoView stopPlayback];
            [self.livePhotoView removeFromSuperview];
        }
        
    } else {
        [self startLivePhoto];
    }
    if ([self.delegate respondsToSelector:@selector(cellChangeLivePhotoState:)]) {
        [self.delegate cellChangeLivePhotoState:self.model];
    }
}

- (void)didSelectClick:(UIButton *)button {
    if (self.model.type == CTMSGPhotoModelMediaTypeCamera) {
        return;
    }
    if (self.model.isIcloud) {
        [self didICloudBtnCLick];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(cellDidSelectedBtnClick:Model:)]) {
        [self.delegate cellDidSelectedBtnClick:self Model:self.model];
    }
}


#pragma mark - public func

- (void)startLivePhoto {
    self.liveIcon.hidden = YES;
    self.liveBtn.hidden = NO;
    if (self.model.isCloseLivePhoto) {
        return;
    }
    if (@available(iOS 9.1, *)) {
        [self.contentView insertSubview:self.livePhotoView aboveSubview:self.imageView];
    } else {
        // Fallback on earlier versions
    }
    CGFloat width = self.frame.size.width;
    __weak typeof(self) weakSelf = self;
    CGSize size;
    if (self.model.imageSize.width > self.model.imageSize.height / 9 * 15) {
        size = CGSizeMake(width, width * 1.5);
    }else if (self.model.imageSize.height > self.model.imageSize.width / 9 * 15) {
        size = CGSizeMake(width * 1.5, width);
    }else {
        size = CGSizeMake(width, width);
    }
    if (@available(iOS 9.1, *)) {
        self.liveRequestID = [CTMSGAlbumTool fetchLivePhotoForPHAsset:self.model.asset size:size completion:^(PHLivePhoto * _Nonnull livePhoto, NSDictionary * _Nonnull info) {
            weakSelf.livePhotoView.livePhoto = livePhoto;
            [weakSelf.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)stopLivePhoto {
    [[PHCachingImageManager defaultManager] cancelImageRequest:self.liveRequestID];
    self.liveIcon.hidden = NO;
    self.liveBtn.hidden = YES;
    if (@available(iOS 9.1, *)) {
        [self.livePhotoView stopPlayback];
        [self.livePhotoView removeFromSuperview];
    }
}

- (void)cancelRequest {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
}
#pragma mark - lazy property

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.ct_h - 25, self.ct_w, 25)];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _bottomView.hidden = YES;
    }
    return _bottomView;
}

- (UIImageView *)videoIcon {
    if (!_videoIcon) {
        _videoIcon = [[UIImageView alloc] init];
        _videoIcon.frame = CGRectMake(5, 0, 17, 17);
        _videoIcon.center = CGPointMake(_videoIcon.center.x, 25 / 2);
    }
    return _videoIcon;
}

- (UILabel *)videoTime {
    if (!_videoTime) {
        _videoTime = [[UILabel alloc] init];
        _videoTime.textColor = [UIColor whiteColor];
        _videoTime.textAlignment = NSTextAlignmentRight;
        _videoTime.font = [UIFont systemFontOfSize:10];
        _videoTime.frame = CGRectMake(CGRectGetMaxX(_videoTime.frame), 0, self.ct_w - CGRectGetMaxX(_videoTime.frame) - 5, 25);
    }
    return _videoTime;
}

- (UIImageView *)gifIcon {
    if (!_gifIcon) {
        _gifIcon = [[UIImageView alloc] init];
        _gifIcon.frame = CGRectMake(self.ct_w - 28, self.ct_h - 18, 28, 18);
    }
    return _gifIcon;
}

- (UIImageView *)liveIcon {
    if (!_liveIcon) {
        _liveIcon = [[UIImageView alloc] init];
        _liveIcon.frame = CGRectMake(7, 5, 18, 18);
    }
    return _liveIcon;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (UIButton *)liveBtn {
    if (!_liveBtn) {
        _liveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_liveBtn setTitle:@"LIVE" forState:UIControlStateNormal];
        [_liveBtn setTitle:[NSBundle ctmsg_localizedStringForKey:@"关闭"] forState:UIControlStateSelected];
        [_liveBtn setTitleColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1] forState:UIControlStateNormal];
        _liveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        _liveBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
        _liveBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _liveBtn.frame = CGRectMake(5, 5, 55, 24);
        [_liveBtn addTarget:self action:@selector(didLivePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _liveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _liveBtn.hidden = YES;
    }
    return _liveBtn;
}

- (UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"checkbox_def"] forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(didSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        _selectBtn.frame = CGRectMake(self.ct_w - 31, self.ct_w - 38, 30, 30);
//        _selectBtn.center = CGPointMake(_selectBtn.center.x, self.liveBtn.center.y);
        self.liveIcon.center = CGPointMake(self.liveIcon.center.x, self.liveBtn.center.y);
        [_selectBtn ctmsg_setEnlargeEdgeWithTop:0 right:0 bottom:20 left:20];
    }
    return _selectBtn;
}

- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setBackgroundColor:[UIColor whiteColor]];
        _cameraBtn.userInteractionEnabled = NO;
        _cameraBtn.frame = self.bounds;
    }
    return _cameraBtn;
}

- (UIButton *)iCloudBtn {
    if (!_iCloudBtn) {
        _iCloudBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iCloudBtn setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4]];
        [_iCloudBtn addTarget:self action:@selector(didICloudBtnCLick) forControlEvents:UIControlEventTouchUpInside];
        _iCloudBtn.frame = self.bounds;
    }
    return _iCloudBtn;
}
- (UIImageView *)iCloudIcon {
    if (!_iCloudIcon) {
        _iCloudIcon = [[UIImageView alloc] init];
    }
    return _iCloudIcon;
}

- (PHLivePhotoView *)livePhotoView NS_AVAILABLE_IOS(9.1) {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.clipsToBounds = YES;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
        _livePhotoView.frame = self.bounds;
    }
    return _livePhotoView;
}

- (void)dealloc {
    if (self.requestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
        self.requestID = -1;
    }
}

@end
