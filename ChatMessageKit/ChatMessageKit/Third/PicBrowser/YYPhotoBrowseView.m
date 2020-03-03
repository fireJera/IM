//
//  YYPhotoGroupView.m
//
//  Created by ibireme on 14/3/9.
//  Copyright (C) 2014 ibireme. All rights reserved.
//

#import "YYPhotoBrowseView.h"
#import "YYWebImage.h"
#include <sys/sysctl.h>
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "YYCGUtilities.h"
//#import "LETADViewHelper.h"
#import "LETADYYPhotoBrowseViewmodel.h"
//#import "LETADVHeader.h"
//#import "LETADAlbum.h"

#define kPadding 20
#define kSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]

#ifndef YY_CLAMP
#define YY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

@interface YYPhotoBrowseView() <UIScrollViewDelegate, UIGestureRecognizerDelegate, YYPhotoScrolleDelegate> {
    YYPhotoGroupCell * _beforCell;
}

@property (nonatomic, weak) UIView *fromFace;                               //动效开始的view
@property (nonatomic, weak) UIView *toContainerView;                        //wo teme ye bu zhidao

@property (nonatomic, strong) UIImage *snapshotImage;                       //snap
@property (nonatomic, strong) UIImage *snapshorImageHidefromFace;           //

@property (nonatomic, strong) UIImageView *background;                      //
@property (nonatomic, strong) UIImageView *blurBackground;                  //

@property (nonatomic, strong) UIView *contentView;                          //
@property (nonatomic, strong) UIScrollView *scrollView;                     //
@property (nonatomic, strong) NSMutableArray *cells;                        //
@property (nonatomic, strong) UIPageControl *pager;                         //
@property (nonatomic, assign) CGFloat pagerCurrentPage;                     //
@property (nonatomic, assign) BOOL fromNavigationBarHidden;                 //

@property (nonatomic, assign) NSInteger fromItemIndex;                      //
@property (nonatomic, assign) BOOL isPresented;                             //

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;           //
@property (nonatomic, assign) CGPoint panGestureBeginPoint;                 //

@property (nonatomic, strong) UIButton * editBtn;                          //delete btn

@property (nonatomic, strong) LETADYYPhotoBrowseViewmodel * viewmodel;

@end

@implementation YYPhotoBrowseView

#pragma mark - btn function
- (void)cancelAllImageLoad {
    [_cells enumerateObjectsUsingBlock:^(YYPhotoGroupCell *cell, NSUInteger idx, BOOL *stop) {
        [cell.imageView yy_cancelCurrentImageRequest];
    }];
}

- (void)reloadItem {
    if (_viewmodel.groupItems.count == 0) {
        [self removeFromSuperview];
        [UIApplication sharedApplication].statusBarHidden = _fromNavigationBarHidden;
    } else {
        self.pager.numberOfPages = _viewmodel.groupItems.count;
        _pager.currentPage = _viewmodel.selectedIndex;
        for (YYPhotoGroupCell * cell in _cells) {
            cell.item = nil;
        }
        [self p_letad_jumpPageanimated:NO completion:nil];
    }
}

//- (void)letad_removeAlbum:(LETADAlbum *)album {
//    [_viewmodel p_letad_removeAlbum:album];
//    [self reloadItem];
//}

- (void)letad_dismiss {
    [self letad_dismissAnimated:YES completion:nil];
}

- (void)p_letad_hidePager {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        _pager.alpha = 0;
    } completion:nil];
}

- (void)p_letad_showPager {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        _pager.alpha = 1;
    } completion:nil];
}

// enqueue invisible cells for reuse
- (void)updateCellsForReuse {
    for (YYPhotoGroupCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > _scrollView.contentOffset.x + _scrollView.width * 2||
                cell.right < _scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

/// dequeue a reusable cell
- (YYPhotoGroupCell *)dequeueReusableCell {
    YYPhotoGroupCell *cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [YYPhotoGroupCell new];
    cell.item = nil;
    cell.frame = self.bounds;
    cell.imageContainerFace.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.scrollDelegate = self;
    cell.page = -1;
    [_cells addObject:cell];
    return cell;
}

- (YYPhotoGroupCell *)cellForPage:(NSInteger)page {
    for (YYPhotoGroupCell *cell in _cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

- (NSInteger)currentPage {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    if (page >= _viewmodel.groupItems.count) page = (NSInteger)_viewmodel.groupItems.count - 1;
    page = MAX(0, page);
    return page;
}

//- (void)showHUD:(NSString *)msg {
//    if (!msg.length) return;
//    UIFont *font = [UIFont systemFontOfSize:17];
//    CGSize size = [msg boundingRectWithSize:CGSizeMake(200, 200) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size;
//
//    UILabel *label = [UILabel new];
//    label.textColor = [UIColor whiteColor];
//    label.numberOfLines = 0;
//    label.size = CGSizePixelCeil(size);
//    label.font = font;
//    label.text = msg;
//
//    UIView *hud = [UIView new];
//    hud.size = CGSizeMake(label.width + 20, label.height + 20);
//    hud.clipsToBounds = YES;
//    hud.layer.cornerRadius = 8;
//    hud.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
//
//    label.center = CGPointMake(hud.width / 2, hud.height / 2);
//    [hud addSubview:label];
//
//    hud.alpha = 0;
//    hud.center = CGPointMake(self.width / 2, self.height / 2);
//    [self addSubview:hud];
//
//    [UIView animateWithDuration:0.4 animations:^{
//        hud.alpha = 1;
//    }];
//    double delayInSeconds = 1.5;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [UIView animateWithDuration:0.4 animations:^{
//            hud.alpha = 0;
//        } completion:^(BOOL finished) {
//            [hud removeFromSuperview];
//        }];
//    });
//}

#pragma mark - uigesturerecognizer
- (void)p_letad_tapView {
    YYPhotoGroupCell *cell = [self cellForPage:self.currentPage];
    if (self.currentPage < _viewmodel.groupItems.count) {
        YYPhotoGroupItem * item = _viewmodel.groupItems[self.currentPage];
//        if (item.album.isVideo) {
//            [cell reverPlayerStatus];
//            return;
//        }
    }
    
    [self letad_dismissAnimated:YES completion:nil];
}

- (void)edit:(UIButton *)sender {
    if (self.currentPage < _viewmodel.groupItems.count) {
        YYPhotoGroupItem * item = _viewmodel.groupItems[self.currentPage];
        if ([_delegate respondsToSelector:@selector(letad_editPhoto:index:item:)]) {
            [_delegate letad_editPhoto:self index:(int)self.currentPage item:item];
        }
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)g {
    if (!_isPresented) return;
    
    YYPhotoGroupItem * item = _viewmodel.groupItems[self.currentPage];
//    if (item.album.isVideo) {
//        return;
//    }
    YYPhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (tile) {
        if (tile.zoomScale > 1) {
            [tile setZoomScale:1 animated:YES];
        } else {
            CGFloat newZoomScale = tile.maximumZoomScale;
            CGFloat ysize = self.height / newZoomScale;
            CGFloat xsize = self.width / newZoomScale;
            CGPoint touchPoint = [g locationInView:tile.imageView];
            [tile zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)panGes:(UIPanGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateBegan) {
        _panGestureBeginPoint = _isPresented ? [g locationInView:self] : CGPointZero;
    }
    else if (g.state == UIGestureRecognizerStateChanged) {
        if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
        CGPoint p = [g locationInView:self];
        CGFloat deltaY = p.y - _panGestureBeginPoint.y;
        
        CGFloat alphaDelta = 160;
        CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
        alpha = YY_CLAMP(alpha, 0, 1);
        _scrollView.top = deltaY;
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
            _pager.alpha = alpha;
            _blurBackground.alpha = alpha;
        } completion:nil];
    }
    else if (g.state == UIGestureRecognizerStateEnded) {
        if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
        CGPoint p = [g locationInView:self];
        CGPoint v = [g velocityInView:self];
        CGFloat deltaY = p.y - _panGestureBeginPoint.y;
        
        if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
            [UIApplication sharedApplication].statusBarHidden = _fromNavigationBarHidden;
            _isPresented = NO;
            [self cancelAllImageLoad];
            BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
            CGFloat vy = fabs(v.y);
            vy = MAX(1, vy);
            CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy * 0.8;
            duration = YY_CLAMP(duration, 0.05, 0.3);
            [self letad_dismissAnimated:YES completion:nil];
        } else {
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                _scrollView.top = 0;
                _blurBackground.alpha = 1;
            } completion:nil];
        }
    }
    else if (g.state == UIGestureRecognizerStateCancelled) {
        _scrollView.top = 0;
        _blurBackground.alpha = 1;
    }
}

#pragma mark - uiscorllviewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat floatPage = _scrollView.contentOffset.x / _scrollView.width;
    NSInteger page = _scrollView.contentOffset.x / _scrollView.width + 0.5;
    [self updateCellsForReuse];
    
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i >= 0 && i < _viewmodel.groupItems.count) {
            YYPhotoGroupCell *cell = [self cellForPage:i];
            if (!cell) {
                YYPhotoGroupCell *cell = [self dequeueReusableCell];
                cell.left = (self.width + kPadding) * i + kPadding / 2;
                cell.page = i;
                if (_isPresented) {
                    cell.item = _viewmodel.groupItems[i];
                }
                [self.scrollView addSubview:cell];
            } else {
                if (_isPresented && !cell.item) {
                    cell.item = _viewmodel.groupItems[i];
                }
            }
            if (i == page) {
                //TODO: - 在这里改变每个要展示的cell的内容
                [cell playVideo];
//                if (_showEdit) {
//                    if (!cell.item) {
//                        _editBtn.hidden = YES;
//                    } else {
//                        _editBtn.hidden = cell.item.album.type == 3;
//                    }
//                }
            }
        }
    }
    [self p_letad_showPager];
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : intPage >= _viewmodel.groupItems.count ? (int)_viewmodel.groupItems.count - 1 : intPage;
    _pager.currentPage = intPage;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        _pager.alpha = 1;
    } completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self p_letad_hidePager];
        _viewmodel.selectedIndex = (int)(self.currentPage);
        YYPhotoGroupCell *cell = [self cellForPage:self.currentPage];
        _beforCell = cell;
        if (_beforCell) [_beforCell stopVideo];
        [cell playVideo];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //TODO: - here Update view or update cell when scroll cell
    YYPhotoGroupCell *cell = [self cellForPage:self.currentPage];
    if (_beforCell) [_beforCell stopVideo];
    [cell playVideo];
    _viewmodel.selectedIndex = (int)(self.currentPage);
    _beforCell = cell;
//    if (_showEdit) {
//        if (!cell.item) {
//            _editBtn.hidden = YES;
//        } else {
//            _editBtn.hidden = cell.item.album.type == 3;
//        }
//    }
}

#pragma mark - YYScrollViewDelegate
- (void)letad_cellScrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -10 || scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height + 10) {
        CGFloat deltaY;
        if (scrollView.contentOffset.y > 0) {
            deltaY = scrollView.contentOffset.y - scrollView.contentSize.height;
        } else {
            deltaY =  -scrollView.contentOffset.y;
        }
        
        CGFloat alphaDelta = 160;
        CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
        alpha = YY_CLAMP(alpha, 0, 1);
        _pager.alpha = alpha;
        _blurBackground.alpha = alpha;
    } else {
        _blurBackground.alpha = 1;
    }
}

- (void)letad_cellScrollViewDidEndScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -120 || scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.height + 120) {
        [self letad_dismissAnimated:YES completion:nil];
    }
}

#pragma mark - setView
- (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

- (instancetype)initWithGroupItems:(NSArray *)groupItems {
    self = [super init];
    if (groupItems.count == 0) return nil;
    _showEdit = NO;
    _blurEffectBackground = YES;
    _viewmodel = [[LETADYYPhotoBrowseViewmodel alloc] initWithItems:groupItems];
    
    NSString *model = [self machineModel];
    static NSMutableSet *oldDevices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        oldDevices = [NSMutableSet new];
        
        [oldDevices addObject:@"iPad1,1"];
        [oldDevices addObject:@"iPad2,1"];
        [oldDevices addObject:@"iPad2,2"];
        [oldDevices addObject:@"iPad2,3"];
        [oldDevices addObject:@"iPad2,4"];
        [oldDevices addObject:@"iPad2,5"];
        [oldDevices addObject:@"iPad2,6"];
        [oldDevices addObject:@"iPad2,7"];
        [oldDevices addObject:@"iPad3,1"];
        [oldDevices addObject:@"iPad3,2"];
        [oldDevices addObject:@"iPad3,3"];
        
        [oldDevices addObject:@"iPhone1,1"];
        [oldDevices addObject:@"iPhone1,1"];
        [oldDevices addObject:@"iPhone1,2"];
        [oldDevices addObject:@"iPhone2,1"];
        [oldDevices addObject:@"iPhone3,1"];
        [oldDevices addObject:@"iPhone3,2"];
        [oldDevices addObject:@"iPhone3,3"];
        [oldDevices addObject:@"iPhone4,1"];
    });
    if ([oldDevices containsObject:model]) {
        _blurEffectBackground = NO;
    }
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_letad_tapView)];
    tap.delegate = self;
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    tap2.delegate = self;
    [tap requireGestureRecognizerToFail: tap2];
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:tap2];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
    [self addGestureRecognizer:pan];
    _panGesture = pan;
    
    _background = UIImageView.new;
    _background.frame = self.bounds;
    _background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_background];
    
    _blurBackground = UIImageView.new;
    _blurBackground.frame = self.bounds;
    _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_blurBackground];
    
    _contentView = UIView.new;
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_contentView];
    
    _scrollView = UIScrollView.new;
    _scrollView.frame = CGRectMake(-kPadding / 2, 0, self.width + kPadding, self.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.alwaysBounceHorizontal = groupItems.count > 1;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_contentView addSubview:_scrollView];
    
    _pager = [[UIPageControl alloc] init];
    _pager.hidesForSinglePage = YES;
    _pager.width = self.width - 36;
    _pager.height = 10;
    _pager.center = CGPointMake(self.width / 2, self.height - 18);
    _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _pager.userInteractionEnabled = NO;
    [_contentView addSubview:_pager];
    
    _cells = @[].mutableCopy;
    [self p_letad_addEditBtn];
    return self;
}

- (void)p_letad_addEditBtn {
//    _editBtn = [LETADViewHelper letad_buttonWithFrame:CGRectMake(self.width - 80 - 20, 30, 80, 40)
//                                      bgImage:nil
//                                        image:@"letad_user_12"
//                                        title:nil
//                                    textColor:[UIColor whiteColor]
//                                       method:@selector(edit:)
//                                       target:self];
//    _editBtn.backgroundColor = [UIColor blackColor];
//    _editBtn.layer.cornerRadius = 4;
//    _editBtn.layer.masksToBounds = YES;
//    [self addSubview:_editBtn];
}

#pragma mark - set func

- (void)setShowEdit:(BOOL)showEdit {
    _showEdit = showEdit;
    _editBtn.hidden = !showEdit;
}

#pragma mark - showView & dismissview
- (void)letad_presentFromImageView:(UIView *)fromFace
                 toContainer:(UIView *)toContainer
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion {
    if (!toContainer) return;
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    _toContainerView = toContainer;
    _fromFace = fromFace;
    
    _snapshotImage = [_toContainerView snapshotImageAfterScreenUpdates:NO];
    BOOL fromFaceHidden = fromFace.hidden;
//    fromFace.hidden = YES;
    _snapshorImageHidefromFace = _snapshotImage;
    
    fromFace.hidden = fromFaceHidden;
    //设置背景为上个view的截图
    _background.image = _snapshorImageHidefromFace;
    _blurBackground.image = _blurEffectBackground ? [_snapshorImageHidefromFace yy_imageByBlurDark] : [UIImage yy_imageWithColor:[UIColor blackColor]];
    
    //获取当前page
    NSInteger page = -1;
    for (NSUInteger i = 0; i < _viewmodel.groupItems.count; i++) {
        if([fromFace isEqual:((YYPhotoGroupItem *)_viewmodel.groupItems[i]).thumbView]){
            page = (int)i;
            break;
        }
    }
    if (page == -1) page = 0;
    _fromItemIndex = page;
    
    self.pager.alpha = 0;
    self.pager.numberOfPages = _viewmodel.groupItems.count;
    self.pager.currentPage = page;
    self.size = _toContainerView.size;
    self.blurBackground.alpha = 0;
    [_toContainerView addSubview:self];

    [self p_letad_jumpPageanimated:animated completion:completion];
}

- (void)p_letad_jumpPageanimated:(BOOL)animated
                completion:(void (^)(void))completion {
    _scrollView.contentSize = CGSizeMake(_scrollView.width * _viewmodel.groupItems.count, _scrollView.height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * _pager.currentPage, 0, _scrollView.width, _scrollView.height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    [UIView setAnimationsEnabled:YES];
    
    YYPhotoGroupCell *cell = [self cellForPage:self.currentPage];
    _beforCell = cell;
    YYPhotoGroupItem *item = _viewmodel.groupItems[self.currentPage];
    _viewmodel.selectedIndex = (int)(self.currentPage);
    if (!item.thumbClippedToTop) {
        NSString *imageKey = [[YYWebImageManager sharedManager] cacheKeyForURL:item.largeImageURL];
        if ([[YYWebImageManager sharedManager].cache getImageForKey:imageKey withType:YYImageCacheTypeMemory]) {
            cell.item = item;
            [cell playVideo];
        }
    }
    if (!cell.item) {
        cell.imageView.image = item.thumbImage;
        [cell resizeSubviewSize];
    }
    if (item.thumbClippedToTop) {
        CGRect fromFrame = [_fromFace convertRect:_fromFace.bounds toView:cell];
        CGRect originFrame = cell.imageContainerFace.frame;
        CGFloat scale = fromFrame.size.width / cell.imageContainerFace.width;
        
        cell.imageContainerFace.centerX = CGRectGetMidX(fromFrame);
        cell.imageContainerFace.height = fromFrame.size.height / scale;
        cell.imageContainerFace.layer.transformScale = scale;
        cell.imageContainerFace.centerY = CGRectGetMidY(fromFrame);
        
        float oneTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        } completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _pager.alpha = 1;
            cell.imageContainerFace.layer.transformScale = 1;
            cell.imageContainerFace.frame = originFrame;
        } completion:^(BOOL finished) {
            _scrollView.userInteractionEnabled = YES;
            _isPresented = YES;
            [self scrollViewDidScroll:_scrollView];
            if (completion) completion();
        }];
    } else {
        CGRect fromFrame = [_fromFace convertRect:_fromFace.bounds toView:cell.imageContainerFace];
        
        cell.imageContainerFace.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float oneTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:oneTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            _blurBackground.alpha = 1;
        } completion:NULL];
        
        _scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerFace.bounds;
            cell.imageView.layer.transformScale = 1.01;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                _pager.alpha = 1;
                cell.imageView.layer.transformScale = 1.0;
            }completion:^(BOOL finished) {
                _scrollView.userInteractionEnabled = YES;
                cell.imageContainerFace.clipsToBounds = YES;
                _isPresented = YES;
                [self scrollViewDidScroll:_scrollView];
                if (completion) completion();
            }];
        }];
    }
}

- (void)letad_dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
//    if ([_delegate respondsToSelector:@selector(letad_browserViewWillClose:)]) {
//        [_delegate letad_browserViewWillClose:self];
//    }
    [UIView setAnimationsEnabled:YES];
    [UIApplication sharedApplication].statusBarHidden = _fromNavigationBarHidden;
    NSInteger currentPage = self.currentPage;
    YYPhotoGroupCell *cell = [self cellForPage:currentPage];
    [cell stopVideo];
    
    _isPresented = NO;
    [self cancelAllImageLoad];
    YYPhotoGroupItem *item = _viewmodel.groupItems[currentPage];
    UIView *fromFace = _fromItemIndex == currentPage ? _fromFace : item.thumbView;
    BOOL isFromImageClipped = fromFace.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.imageContainerFace.frame;
        cell.imageContainerFace.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.imageContainerFace.frame = frame;
    }
    cell.progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (fromFace == nil) {
        self.background.image = _snapshotImage;
        [UIView animateWithDuration:animated ? 0.4 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            self.scrollView.layer.transformScale = 0.95;
            self.scrollView.alpha = 0;
            self.pager.alpha = 0;
            self.blurBackground.alpha = 0;
        }completion:^(BOOL finished) {
            self.scrollView.layer.transformScale = 1;
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) completion();
        }];
        return;
    }
    
    if (_fromItemIndex != currentPage) {
        _background.image = _snapshotImage;
        [_background.layer addFadeAnimationWithDuration:0.25 curve:UIViewAnimationCurveEaseOut];
    } else {
        _background.image = _snapshorImageHidefromFace;
    }
    
    if (isFromImageClipped) {
        CGPoint off = cell.contentOffset;
        off.y = 0 - cell.contentInset.top;
        [cell setContentOffset:off animated:animated];
    }
    
    [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        _pager.alpha = 0.0;
        _blurBackground.alpha = 0.0;
        if (isFromImageClipped) {
            CGRect fromFrame = [fromFace convertRect:fromFace.bounds toView:cell];
            CGFloat scale = fromFrame.size.width / cell.imageContainerFace.width * cell.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.imageContainerFace.width;
            if (isnan(height)) height = cell.imageContainerFace.height;
            
            cell.imageContainerFace.height = height;
            cell.imageContainerFace.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
            cell.imageContainerFace.layer.transformScale = scale;
        } else {
            CGRect fromFrame = [fromFace convertRect:fromFace.bounds toView:cell.imageContainerFace];
            cell.imageContainerFace.clipsToBounds = NO;
            cell.imageView.contentMode = fromFace.contentMode;
            cell.imageView.frame = fromFrame;
        }
        self.alpha = 0;
    } completion:^(BOOL finished) {
        cell.imageContainerFace.layer.anchorPoint = CGPointMake(0.5, 0.5);
        [self removeFromSuperview];
        if (completion) completion();
    }];
}

@end
