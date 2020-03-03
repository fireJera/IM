//
//  UIView+CTMSG_Cat.h
//  微博照片选择
//
//  Created by 洪欣 on 17/2/16.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CTMSG_Cat)

@property (assign, nonatomic) CGFloat ct_x;
@property (assign, nonatomic) CGFloat ct_y;
@property (assign, nonatomic) CGFloat ct_w;
@property (assign, nonatomic) CGFloat ct_h;
@property (assign, nonatomic) CGSize ct_size;
@property (assign, nonatomic) CGPoint ct_origin;

/**
 获取当前视图的控制器
 
 @return 控制器
 */
- (UIViewController *)viewController;

- (void)showImageHUDText:(NSString *)text;
- (void)showLoadingHUDText:(NSString *)text;
- (void)handleLoading;

@end


@interface CTMSGHUD : UIView
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName text:(NSString *)text;
- (void)showloading;
@end
