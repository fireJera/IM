//
//  UIColor+CTMSG_Hex.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "UIColor+CTMSG_Hex.h"

@implementation UIColor (CTMSG_Hex)

static inline NSUInteger hexStrToInt(NSString * str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString * str, CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0;
        if (length == 4) *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0;
        else *a = 1;
    }
    return YES;
}
/*
 * 根据字符串类型的16进制的色值返回相应的颜色
 * 传入参数  "0xFF0000"或者 "FFFFFF"
 * 返回     UIColor
 */
+ (UIColor *)ctmsg_colorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

+ (UIColor *)ctmsg_colorWithRGB:(int)rgb {
    return [UIColor ctmsg_colorWithRGB:rgb alpha:1];
}

+ (UIColor *)ctmsg_colorWithRGB:(int)rgb alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(((rgb & 0xFF0000) >> 16)) / 255.0
                           green:(((rgb & 0xFF00) >> 8)) / 255.0
                            blue:((rgb & 0xFF)) / 255.0
                           alpha: alpha];
}

//#pragma mark - common
+ (UIColor *)ctmsg_themeGrayColor {
    return [UIColor ctmsg_colorWithRGB:0xF7F7F7];
}

+ (UIColor *)ctmsg_color4C4C4C {
    return [UIColor ctmsg_colorWithRGB:0x4C4C4C];
}

+ (UIColor *)ctmsg_colorB1B1B1 {
    return [UIColor ctmsg_colorWithRGB:0xB1B1B1];
}

+ (UIColor *)ctmsg_colorB6B6B6 {
    return [UIColor ctmsg_colorWithRGB:0xB6B6B6];
}

+ (UIColor *)ctmsg_colorF4F5F8 {
    return [UIColor ctmsg_colorWithRGB:0xF4F5F8];
}

+ (UIColor *)ctmsg_color212121 {
    return [UIColor ctmsg_colorWithRGB:0x212121];
}

+ (UIColor *)ctmsg_color7F7F7F {
    return [UIColor ctmsg_colorWithRGB:0x7F7F7F];
}

+ (UIColor *)ctmsg_color31A3FF {
    return [UIColor ctmsg_colorWithRGB:0x31A3FF];
}

+ (UIColor *)ctmsg_color8358D0 {
    return [UIColor ctmsg_colorWithRGB:0x8358D0];
}

+ (UIColor *)ctmsg_colorD9D9D9 {
    return [UIColor ctmsg_colorWithRGB:0xD9D9D9];
}

+ (UIColor *)ctmsg_colorF2F2F2 {
    return [UIColor ctmsg_colorWithRGB:0xF2F2F2];
}

+ (UIColor *)ctmsg_colorE4E6EA {
    return [UIColor ctmsg_colorWithRGB:0xE4E6EA];
}

//#pragma mark - date
//+ (UIColor *)menuSelectedColor {
//    return [UIColor ctmsg_colorWithRGB:0x567aff];
//}
//
//+ (UIColor *)btnGreenColor {
//    return [UIColor ctmsg_colorWithRGB:0x58cb83];
//}
//
//+ (UIColor *)graySixEColor {
//    return [UIColor ctmsg_colorWithRGB:0xEEEEEE alpha:1];
//}
//
//+ (UIColor *)cameraGrayColor {
//    return [UIColor ctmsg_colorWithRGB:0xdddddd];
//}
//
////#pragma mark - Home
////头部的黑色
//+ (UIColor *)blackTextColor {
//    return [UIColor ctmsg_colorWithRGB:0x43424a];
//}
////
////也是主题蓝
//+ (UIColor *)femaleBlueColor {
//    return [UIColor ctmsg_colorWithRGB:0x5474ff];
//}
//
////灰字
//+ (UIColor *)grayTextColor {
//    return [UIColor ctmsg_colorWithRGB:0xc2c2c2];
//}
////// 女神的红
//+ (UIColor *)maleRedColor {
//    return [UIColor ctmsg_colorWithRGB:0xff477b];
//}
//
//+ (UIColor *)HomeTagTextColor {
//    return [UIColor ctmsg_colorWithRGB:0x7d7b86];
//}
//
//+ (UIColor *)seperatorLineColor {
//    return [UIColor ctmsg_colorWithRGB:0xe2e2e2];
//}
//
//+ (UIColor *)orangeBtnColor {
//    return [UIColor ctmsg_colorWithHexString:@"ff8847"];
//}
//
//+ (UIColor *)btnDisableColor {
//    return [UIColor ctmsg_colorWithRGB:0xdddddd];
//}
//
////
////weekGrayColor
//+ (UIColor *)weekGrayColor {
//    return [UIColor ctmsg_colorWithHexString:@"7F8FA4"];
//}

- (NSString *)description {
    return [self debugDescription];
}

- (NSString *)debugDescription {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSString stringWithFormat:@"<Person: %p> {\n\tred=%f,\n\tgreen=%f,\n\tblue=%f,\n\talpha=%f\n}", self, red, green, blue, alpha];
}

@end
