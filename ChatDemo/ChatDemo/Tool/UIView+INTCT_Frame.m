//
//  UIView+INTCT_Frame.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "UIView+INTCT_Frame.h"
#import "UIColor+INTCT_App.h"
#import "UIColor+INTCT_Hex.h"
#import <objc/runtime.h>

#if __has_include (<MBProgressHUD/MBProgressHUD.h>)
#import <MBProgressHUD/MBProgressHUD.h>
#else
#import "MBProgressHUD/MBProgressHUD.h"
#endif

@implementation UIView (INTCT_Frame)

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)centerX {
    CGRect frame = self.frame;
    frame.origin.x = centerX - frame.size.width / 2;
    self.frame = frame;
}

- (void)setCenterY:(CGFloat)centerY {
    CGRect frame = self.frame;
    frame.origin.y = centerY - frame.size.height / 2;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - self.frame.size.height;
    self.frame = frame;
}

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - self.frame.size.width;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (CGSize)size {
    return self.frame.size;
}

- (CGFloat)centerX {
    return self.frame.origin.x + self.frame.size.width / 2;
}

- (CGFloat)centerY {
    return self.frame.origin.y + self.frame.size.height / 2;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.height;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return self.frame.origin.x + self.width;
}

//- (void)setintct_text:(NSString *)intct_text {
//    if ([self isKindOfClass:[UILabel class]]) {
//        ((UILabel *)self).text = intct_text;
//    }
//    else if ([self isKindOfClass:[UIButton class]]) {
//        [((UIButton *)self) setTitle:intct_text forState:UIControlStateNormal];
//    }
//    else if ([self isKindOfClass:[UITextField class]]) {
//        ((UITextField *)self).text = intct_text;
//    }
//    else if ([self isKindOfClass:[UITextView class]]) {
//        ((UITextView *)self).text = intct_text;
//    }
//}

@end

static void * kLogActionKey;

@implementation UIView (INTCT_Custom)

- (UIViewController *)viewController {
    UIResponder *nextResponder =  self;
    do
    {
        nextResponder = [nextResponder nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;
    } while (nextResponder != nil);
    return nil;
}

- (void)setLogActionName:(NSString *)logActionName {
    objc_setAssociatedObject(self, kLogActionKey, logActionName, OBJC_ASSOCIATION_COPY);
}

- (NSString *)logActionName {
    NSString * name = objc_getAssociatedObject(self, kLogActionKey);
    return name;
}

- (void)removeAllSubViews {
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

- (void)bringToFront {
    [self.superview bringSubviewToFront:self];
}

- (void)sendToBack {
    [self.superview sendSubviewToBack:self];
}

@end

@implementation UIView (INTCTCorner)

@dynamic layerBorderColor, layerBorderWidth, layerCornerRadius;

- (void)addCorner:(CGFloat)radius {
    [self addCorner:radius borderWidth:1 bgColor:[UIColor clearColor] borderColor:[UIColor blackColor]];
}

- (void)addCorner:(CGFloat)radius borderWidth:(CGFloat)borderWidth bgColor:(UIColor *)bgColor borderColor:(UIColor *)borderColor {
    UIImage * image = [self p_intct_drawRectCorner:radius borderWidth:borderWidth bgColor:bgColor borderColor:borderColor];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [self insertSubview:imageView atIndex:0];
}


- (UIImage *)p_intct_drawRectCorner:(CGFloat)radius borderWidth:(CGFloat)borderWidth bgColor:(UIColor *)bgColor borderColor:(UIColor *)borderColor {
    CGSize sizeToFit = CGSizeMake([self pixel:self.bounds.size.width], self.bounds.size.width);
    CGFloat halfBorderWidth = borderWidth / 2.0;
    UIGraphicsBeginImageContextWithOptions(sizeToFit, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    
    CGFloat width = sizeToFit.width;
    CGFloat height = sizeToFit.height;
    CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth);
    CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius);
    CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius);
    CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius);
    CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (double)pixel:(double)num {
    double unit = 0;
    unit = 1 / (int)[UIScreen mainScreen].scale;
    return [self p_intct_roundByUnit:num with:unit];
}

- (double)p_intct_roundByUnit:(double)num with:(double)unit {
    double remain = modf(num, &unit);
    if (remain > unit / 2.0) {
        return [self p_intct_ceilUnit:num with:unit];
    } else {
        return [self p_intct_floorUnit:num with:unit];
    }
}

- (double)p_intct_ceilUnit:(double)num with:(double)unit {
    return num - modf(num, &unit) + unit;
}

- (double)p_intct_floorUnit :(double)num with:(double)unit{
    return num - modf(num, &unit);
}

- (void)setLayerCornerRadius:(CGFloat)layerCornerRadius {
    self.layer.cornerRadius = layerCornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setLayerBorderWidth:(CGFloat)layerBorderWidth {
    self.layer.borderWidth = layerBorderWidth;
}

- (void)setLayerBorderColor:(UIColor *)layerBorderColor {
    self.layer.borderColor = layerBorderColor.CGColor;
}

@end

@implementation UIView (INTCTImage)

- (UIImage *)snapImage {
    UIImage * imageRet = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    //获取图像
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageRet;
}

@end


#if __has_include (<MBProgressHUD.h>) || __has_include ("MBProgressHUD.h")

@implementation UIView (TextHUD)

- (void)showTextHUD:(NSString *)text {
    [self showTextHUD:text withEnabled:YES dealy:1];
}

- (void)showTextHUD:(nullable NSString *)text
        withEnabled:(BOOL)userInteractionEnabled
              dealy:(NSInteger)second {
    [self showTextHUD:text enabled:userInteractionEnabled xOffset:0 yOffset:self.height * 0.2 dealy:second];
}

- (void)showTextHUD:(NSString *)text
            enabled:(BOOL)userInteractionEnabled
            xOffset:(CGFloat)x
            yOffset:(CGFloat)y
              dealy:(NSInteger)second {
    if (text.length == 0 || text == nil) {
        return;
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.minShowTime = 1;
    hud.offset = CGPointMake(x, y);
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:13];
    hud.detailsLabel.text = text;
    [hud showAnimated:true];
    [hud hideAnimated:true afterDelay:second];
}

@end

@implementation UIView (loadingHUD)

- (MBProgressHUD *)showIndeterminateHUD:(BOOL)userInteractionEnabled {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self animated:true];
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    hud.userInteractionEnabled = userInteractionEnabled;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.alpha = 0.5;
    
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.label.textColor = [UIColor whiteColor];
    return hud;
}

#pragma mark - 自定义MBProgressHUD动画
- (MBProgressHUD *)customProgressHUDTitle:(NSString *)title {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    
//    LOTAnimationView * animationView = [LOTAnimationView animationNamed:@"loading"];
//    animationView.frame = CGRectMake(0, 0, 80, 80);
////    animationView.contentMode = UIViewContentModeScaleAspectFill;
//    [animationView setNeedsLayout];
//    [animationView layoutIfNeeded];
//    animationView.loopAnimation = YES;
//    [animationView play];
//    hud.customView = animationView;
    hud.label.text = @"1";
    hud.label.hidden = YES;
    hud.detailsLabel.text = title;
    hud.detailsLabel.textColor = [UIColor intct_colorWithRGB:0x212121];
    hud.detailsLabel.font = [UIFont systemFontOfSize:13];
    hud.bezelView.color = [UIColor intct_colorWithRGB:0xf7f7f7];
    hud.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.51];
    hud.minSize = CGSizeMake(80, 80);
    return hud;
}

@end

#endif
