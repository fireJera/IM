//
//  UIColor+CTMSG_Hex.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (CTMSG_Hex)

+ (UIColor *)ctmsg_colorWithRGB:(int)rgb;
+ (UIColor *)ctmsg_colorWithRGB:(int)rgb alpha:(CGFloat)alpha;

// new  use this
+ (UIColor *)ctmsg_colorWithHexString:(NSString *)hexStr;

#pragma mark - common
+ (UIColor *)ctmsgBlackTextColor;
+ (UIColor *)ctmsg_color_f7f7f7;

+ (UIColor *)ctmsg_color4C4C4C;
+ (UIColor *)ctmsg_colorB1B1B1;
+ (UIColor *)ctmsg_colorB6B6B6;
+ (UIColor *)ctmsg_colorF4F5F8;
+ (UIColor *)ctmsg_color212121;
+ (UIColor *)ctmsg_color7F7F7F;
+ (UIColor *)ctmsg_color31A3FF;
+ (UIColor *)ctmsg_color8358D0;
+ (UIColor *)ctmsg_colorD9D9D9;
+ (UIColor *)ctmsg_colorF2F2F2;
+ (UIColor *)ctmsg_colorE4E6EA;
+ (UIColor *)ctmsg_colorffe9e7;

@end

NS_ASSUME_NONNULL_END
