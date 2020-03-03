//
//  UIFont+CTMSG_Font.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "UIFont+CTMSG_Font.h"

static NSString * const kLETADPINGFANGSCLIGHT = @"PingFangSC-Light";
static NSString * const kLETADPINGFANGSCMEDIUM = @"PingFangSC-Medium";
NSString * const kLETADPINGFANGSCREGULAR = @"PingFangSC-Regular";
static NSString * const kLETADPINGFANGSCSemibold = @"PingFangSC-Semibold";
static NSString * const kLETADPINGFANGSCBold = @"PingFangSC-Bold";

@implementation UIFont (CTMSG_Font)

+ (UIFont *)ctmsg_PingFangMediumWithSize:(CGFloat)size {
    return [UIFont fontWithName:kLETADPINGFANGSCMEDIUM size:size];
}
//
//+ (UIFont *)ctmsg_PingFangRegularWithSize:(CGFloat)size {
//    return [UIFont fontWithName:kLETADPINGFANGSCREGULAR size:size];
//}
//
+ (UIFont *)ctmsg_PingFangSemboldWithSize:(CGFloat)size {
    return [UIFont fontWithName:kLETADPINGFANGSCSemibold size:size];
}

+ (UIFont *)ctmsg_PingFangBoldWithSize:(CGFloat)size {
    return [UIFont fontWithName:kLETADPINGFANGSCBold size:size];
}

+ (UIFont *)ctmsg_PingFangMedium10 {
    return [self ctmsg_PingFangMediumWithSize:10];
}

+ (UIFont *)ctmsg_PingFangMedium11 {
    return [self ctmsg_PingFangMediumWithSize:11];
}

+ (UIFont *)ctmsg_PingFangMedium12 {
    return [self ctmsg_PingFangMediumWithSize:12];
}

+ (UIFont *)ctmsg_PingFangMedium13 {
    return [self ctmsg_PingFangMediumWithSize:13];
}

+ (UIFont *)ctmsg_PingFangMedium14 {
    return [self ctmsg_PingFangMediumWithSize:14];
}

+ (UIFont *)ctmsg_PingFangMedium15 {
    return [self ctmsg_PingFangMediumWithSize:15];
}

+ (UIFont *)ctmsg_PingFangMedium16 {
    return [self ctmsg_PingFangMediumWithSize:16];
}

+ (UIFont *)ctmsg_PingFangMedium18 {
    return [self ctmsg_PingFangMediumWithSize:18];
}

+ (UIFont *)ctmsg_PingFangMedium20 {
    return [self ctmsg_PingFangMediumWithSize:20];
}

+ (UIFont *)ctmsg_PingFangMedium24 {
    return [self ctmsg_PingFangMediumWithSize:24];
}

+ (UIFont *)ctmsg_PingFangMedium25 {
    return [self ctmsg_PingFangMediumWithSize:25];
}

+ (UIFont *)ctmsg_PingFangMedium30 {
    return [self ctmsg_PingFangMediumWithSize:30];
}

+ (UIFont *)ctmsg_PingFangMedium35 {
    return [self ctmsg_PingFangMediumWithSize:35];
}

+ (UIFont *)ctmsg_PingFangMedium50 {
    return [self ctmsg_PingFangMediumWithSize:50];
}

@end
