//
//  UIFont+CTMSG_Font.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CTMSGPINGFANGSCREGULAR;

@interface UIFont (CTMSG_Font)

+ (UIFont *)ctmsg_PingFangMediumWithSize:(CGFloat)size;
+ (UIFont *)ctmsg_PingFangSemboldWithSize:(CGFloat)size;
+ (UIFont *)ctmsg_PingFangBoldWithSize:(CGFloat)size NS_UNAVAILABLE;

+ (UIFont *)ctmsg_PingFangMedium10;
+ (UIFont *)ctmsg_PingFangMedium11;
+ (UIFont *)ctmsg_PingFangMedium12;
+ (UIFont *)ctmsg_PingFangMedium13;
+ (UIFont *)ctmsg_PingFangMedium14;
+ (UIFont *)ctmsg_PingFangMedium15;
+ (UIFont *)ctmsg_PingFangMedium16;
+ (UIFont *)ctmsg_PingFangMedium18;
//+ (UIFont *)ctmsg_PingFangMedium20;
+ (UIFont *)ctmsg_PingFangMedium24;
//+ (UIFont *)ctmsg_PingFangMedium25;
//+ (UIFont *)ctmsg_PingFangMedium30;
//+ (UIFont *)ctmsg_PingFangMedium35;
//+ (UIFont *)ctmsg_PingFangMedium50;

@end

NS_ASSUME_NONNULL_END
