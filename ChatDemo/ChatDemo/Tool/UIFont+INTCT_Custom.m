//
//  UIFont+INTCT_Custom.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "UIFont+INTCT_Custom.h"

//@implementation UIFont (JER_Custom)
//
//- (BOOL)isBold {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
//    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
//}
//
//- (BOOL)isItalic {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
//    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
//}
//
//- (BOOL)isMonoSpace {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
//    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitMonoSpace) > 0;
//}
//
//- (BOOL)isColorGlyphs {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return NO;
//    return (CTFontGetSymbolicTraits((__bridge CTFontRef)self) & kCTFontColorGlyphsTrait) != 0;
//}
//
//- (CGFloat)fontWeight {
//    NSDictionary * traits = [self.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute];
//    return [traits[UIFontWeightTrait] floatValue];
//}
//
//- (UIFont *)fontWithBold {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
//    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.pointSize];
//}
//
//- (UIFont *)fontWithItalic {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
//    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:self.pointSize];
//}
//
//- (UIFont *)fontWithBoldItalic {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
//    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic] size:self.pointSize];
//}
//
//- (UIFont *)fontWithNormal {
//    if (![self respondsToSelector:@selector(fontDescriptor)]) return self;
//    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:0] size:self.pointSize];
//}
//
//+ (UIFont *)fontWithCTFont:(CTFontRef)CTFont {
//    if (!CTFont) return nil;
//    CFStringRef name = CTFontCopyPostScriptName(CTFont);
//    if (!name) return nil;
//    CGFloat size = CTFontGetSize(CTFont);
//    UIFont * font = [UIFont fontWithName:(__bridge NSString *)name size:size];
//    CFRelease(name);
//    return font;
//}
//
//+ (UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size {
//    if (!CGFont) return nil;
//    CFStringRef name = CGFontCopyPostScriptName(CGFont);
//    if (!name) return nil;
//    UIFont * font = [UIFont fontWithName:(__bridge NSString *)name size:size];
//    CFRelease(name);
//    return font;
//}
//
//- (CTFontRef)CTFontRef {
//    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.fontName, self.pointSize, NULL);
//    return font;
//}
//
//- (CGFontRef)CGFontRef {
//    CGFontRef font = CGFontCreateWithFontName((__bridge CFStringRef)self.fontName);
//    return font;
//}
//
//@end

@implementation UIFont (INTCT_Common)

static NSString * const kINTCTPINGFANGSCLIGHT = @"PingFangSC-Light";
static NSString * const kINTCTPINGFANGSCMEDIUM = @"PingFangSC-Medium";
NSString * const kINTCTPINGFANGSCREGULAR = @"PingFangSC-Regular";
static NSString * const kINTCTPINGFANGSCSemibold = @"PingFangSC-Semibold";
static NSString * const kINTCTPINGFANGSCBold = @"PingFangSC-Bold";

+ (UIFont *)intct_PingFangMediumWithSize:(CGFloat)size {
    return [UIFont fontWithName:kINTCTPINGFANGSCMEDIUM size:size];
}
//
//+ (UIFont *)intct_PingFangRegularWithSize:(CGFloat)size {
//    return [UIFont fontWithName:kINTCTPINGFANGSCREGULAR size:size];
//}
//
+ (UIFont *)intct_PingFangSemboldWithSize:(CGFloat)size {
    return [UIFont fontWithName:kINTCTPINGFANGSCSemibold size:size];
}

+ (UIFont *)intct_PingFangBoldWithSize:(CGFloat)size {
    return [UIFont fontWithName:kINTCTPINGFANGSCBold size:size];
}

+ (UIFont *)intct_PingFangMedium10 {
    return [self intct_PingFangMediumWithSize:10];
}

+ (UIFont *)intct_PingFangMedium11 {
    return [self intct_PingFangMediumWithSize:11];
}

+ (UIFont *)intct_PingFangMedium12 {
    return [self intct_PingFangMediumWithSize:12];
}

+ (UIFont *)intct_PingFangMedium13 {
    return [self intct_PingFangMediumWithSize:13];
}

+ (UIFont *)intct_PingFangMedium14 {
    return [self intct_PingFangMediumWithSize:14];
}

+ (UIFont *)intct_PingFangMedium15 {
    return [self intct_PingFangMediumWithSize:15];
}

+ (UIFont *)intct_PingFangMedium16 {
    return [self intct_PingFangMediumWithSize:16];
}

+ (UIFont *)intct_PingFangMedium17 {
    return [self intct_PingFangMediumWithSize:17];
}

+ (UIFont *)intct_PingFangMedium18 {
    return [self intct_PingFangMediumWithSize:18];
}

+ (UIFont *)intct_PingFangMedium20 {
    return [self intct_PingFangMediumWithSize:20];
}

+ (UIFont *)intct_PingFangMedium24 {
    return [self intct_PingFangMediumWithSize:24];
}

+ (UIFont *)intct_PingFangMedium25 {
    return [self intct_PingFangMediumWithSize:25];
}

+ (UIFont *)intct_PingFangMedium30 {
    return [self intct_PingFangMediumWithSize:30];
}

+ (UIFont *)intct_PingFangMedium35 {
    return [self intct_PingFangMediumWithSize:35];
}

+ (UIFont *)intct_PingFangMedium50 {
    return [self intct_PingFangMediumWithSize:50];
}
//
//+ (UIFont *)PingFangRegular13 {
//    return [self intct_PingFangRegularWithSize:13];
//}
//
//+ (UIFont *)PingFangRegular15 {
//    return [self intct_PingFangRegularWithSize:15];
//}
//
//+ (UIFont *)PingFangRegular18 {
//    return [self intct_PingFangRegularWithSize:18];
//}

@end
