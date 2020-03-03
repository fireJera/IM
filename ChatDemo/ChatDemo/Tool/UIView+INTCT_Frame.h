//
//  UIView+INTCT_Frame.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (INTCT_Frame)

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

//@property (nonatomic, copy) NSString * intct_text;

@end

@interface UIView (INTCT_Custom)

@property (nonatomic, assign, readonly) UIViewController * _Nullable viewController;
@property (nonatomic, copy) NSString * logActionName;

- (void)bringToFront;
- (void)sendToBack;
- (void)removeAllSubViews;

@end

@interface UIView (INTCTCorner)

- (void)addCorner:(CGFloat)radius;

- (void)addCorner:(CGFloat)radius
      borderWidth:(CGFloat)width
          bgColor:(UIColor * _Nullable)bgColor
      borderColor:(UIColor * _Nullable)color;

#if !TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) CGFloat layerCornerRadius;
@property (nonatomic, assign) UIColor * _Nullable layerBorderColor;
@property (nonatomic, assign) CGFloat layerBorderWidth;
#else
@property (nonatomic, assign) IBInspectable CGFloat layerCornerRadius;
@property (nonatomic, assign) IBInspectable UIColor * layerBorderColor;
@property (nonatomic, assign) IBInspectable CGFloat layerBorderWidth;
#endif

@end

@interface UIView (INTCTImage)

- (UIImage *)snapImage;

@end

#if __has_include (<MBProgressHUD.h>) || __has_include ("MBProgressHUD.h")
@class MBProgressHUD;

@interface UIView (TextHUD)

- (void)showTextHUD:(nullable NSString *)text;
- (void)showTextHUD:(nullable NSString *)text
        withEnabled:(BOOL)userInteractionEnabled
              dealy:(NSInteger)second;
/**
 显示toast
 
 @param text 文本内容
 @param userInteractionEnabled 是否支持手势
 @param x x偏移
 @param y y偏移
 @param second 多少秒后消失
 */
- (void)showTextHUD:(nullable NSString *)text
            enabled:(BOOL)userInteractionEnabled
            xOffset:(CGFloat)x
            yOffset:(CGFloat)y
              dealy:(NSInteger)second;

@end

@interface UIView (loadingHUD)

- (nonnull MBProgressHUD *)showIndeterminateHUD:(BOOL)userInteractionEnabled;

/**
 自定义动画过程
 
 @param title title
 @return MBProgressHUD
 */
- (nonnull MBProgressHUD *)customProgressHUDTitle:(nullable NSString *)title;

@end

#endif
NS_ASSUME_NONNULL_END
