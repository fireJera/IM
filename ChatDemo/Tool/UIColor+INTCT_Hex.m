//
//  UIColor+INTCT_Hex.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "UIColor+INTCT_Hex.h"

@implementation UIColor (INTCT_Hex)

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
+ (UIColor *)intct_colorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

+ (UIColor *)intct_colorWithRGB:(int)rgb {
    return [UIColor intct_colorWithRGB:rgb alpha:1];
}

+ (UIColor *)intct_colorWithRGB:(int)rgb alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(((rgb & 0xFF0000) >> 16)) / 255.0
                           green:(((rgb & 0xFF00) >> 8)) / 255.0
                            blue:((rgb & 0xFF)) / 255.0
                           alpha: alpha];
}

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
