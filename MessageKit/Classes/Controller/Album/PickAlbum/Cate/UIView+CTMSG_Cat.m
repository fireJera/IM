//
//  UIView+CTMSG_Cat.m
//  微博照片选择
//
//  Created by 洪欣 on 17/2/16.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "UIView+CTMSG_Cat.h"
#import "CTMSGAlbumTool.h"

@implementation UIView (CTMSG_Cat)
- (void)setCt_x:(CGFloat)ct_x
{
    CGRect frame = self.frame;
    frame.origin.x = ct_x;
    self.frame = frame;
}

- (CGFloat)ct_x
{
    return self.frame.origin.x;
}

- (void)setCt_y:(CGFloat)ct_y
{
    CGRect frame = self.frame;
    frame.origin.y = ct_y;
    self.frame = frame;
}

- (CGFloat)ct_y
{
    return self.frame.origin.y;
}

- (void)setCt_w:(CGFloat)ct_w
{
    CGRect frame = self.frame;
    frame.size.width = ct_w;
    self.frame = frame;
}

- (CGFloat)ct_w
{
    return self.frame.size.width;
}

- (void)setCt_h:(CGFloat)ct_h
{
    CGRect frame = self.frame;
    frame.size.height = ct_h;
    self.frame = frame;
}

- (CGFloat)ct_h
{
    return self.frame.size.height;
}

- (void)setCt_size:(CGSize)ct_size
{
    CGRect frame = self.frame;
    frame.size = ct_size;
    self.frame = frame;
}

- (CGSize)ct_size
{
    return self.frame.size;
}

- (void)setCt_origin:(CGPoint)ct_origin
{
    CGRect frame = self.frame;
    frame.origin = ct_origin;
    self.frame = frame;
}

- (CGPoint)ct_origin
{
    return self.frame.origin;
}

/**
 获取当前视图的控制器
 
 @return 控制器
 */
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)showImageHUDText:(NSString *)text
{
    CGFloat hudW = [CTMSGAlbumTool getTextWidth:text height:15 fontSize:14];
    if (hudW > self.frame.size.width - 60) {
        hudW = self.frame.size.width - 60;
    }
    CGFloat hudH = [CTMSGAlbumTool getTextHeight:text width:hudW fontSize:14];
    if (hudW < 100) {
        hudW = 100;
    }
    CTMSGHUD *hud = [[CTMSGHUD alloc] initWithFrame:CGRectMake(0, 0, hudW + 20, 110 + hudH - 15) imageName:@"alert_failed_icon@2x.png" text:text];
    hud.alpha = 0;
    hud.tag = 1008611;
    [self addSubview:hud];
    hud.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [UIView animateWithDuration:0.25 animations:^{
        hud.alpha = 1;
    }];
    [UIView cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(handleGraceTimer) withObject:nil afterDelay:1.5f inModes:@[NSRunLoopCommonModes]];
}

- (void)showLoadingHUDText:(NSString *)text
{
    CGFloat hudW = [CTMSGAlbumTool getTextWidth:text height:15 fontSize:14];
    if (hudW > self.frame.size.width - 60) {
        hudW = self.frame.size.width - 60;
    }
    CGFloat hudH = [CTMSGAlbumTool getTextHeight:text width:hudW fontSize:14];
    
    CTMSGHUD *hud = [[CTMSGHUD alloc] initWithFrame:CGRectMake(0, 0, 110, 110 + hudH - 15) imageName:@"alert_failed_icon@2x.png" text:text];
    [hud showloading];
    hud.alpha = 0;
    hud.tag = 10086;
    [self addSubview:hud];
    hud.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [UIView animateWithDuration:0.25 animations:^{
        hud.alpha = 1;
    }];
}

- (void)handleLoading
{
    [UIView cancelPreviousPerformRequestsWithTarget:self];
    for (UIView *view in self.subviews) {
        if (view.tag == 10086) {
            [UIView animateWithDuration:0.2f animations:^{
                view.alpha = 0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }
    }
}

- (void)handleGraceTimer
{
    [UIView cancelPreviousPerformRequestsWithTarget:self];
    for (UIView *view in self.subviews) {
        if (view.tag == 1008611) {
            [UIView animateWithDuration:0.2f animations:^{
                view.alpha = 0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }
    }
}

@end

@interface CTMSGHUD ()
@property (copy, nonatomic) NSString *imageName;
@property (copy, nonatomic) NSString *text;
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation CTMSGHUD

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = text;
        self.imageName = imageName;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        [self p_ctmsg_setup];
    }
    return self;
}

- (void)p_ctmsg_setup
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[CTMSGAlbumTool ctmsg_imageNamed:self.imageName]];
    [self addSubview:imageView];
    CGFloat imgW = imageView.image.size.width;
    CGFloat imgH = imageView.image.size.height;
    CGFloat imgCenterX = self.frame.size.width / 2;
    imageView.frame = CGRectMake(0, 20, imgW, imgH);
    imageView.center = CGPointMake(imgCenterX, imageView.center.y);
    self.imageView = imageView;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = self.text;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    [self addSubview:label];
    CGFloat labelX = 10;
    CGFloat labelY = CGRectGetMaxY(imageView.frame) + 10;
    CGFloat labelW = self.frame.size.width - 20;
    CGFloat labelH = [CTMSGAlbumTool getTextHeight:self.text width:labelW fontSize:14];
    label.frame = CGRectMake(labelX, labelY, labelW, labelH);
}

- (void)showloading
{
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loading startAnimating];
    [self addSubview:loading];
    loading.frame = self.imageView.frame;
    self.imageView.hidden = YES;
}
@end
