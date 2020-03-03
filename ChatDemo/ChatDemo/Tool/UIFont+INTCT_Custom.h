//
//  UIFont+INTCT_Custom.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kINTCTPINGFANGSCREGULAR;

//@interface UIFont (JER_Custom)
//
//@property (nonatomic, readonly) BOOL isBold NS_AVAILABLE_IOS(7_0);
//@property (nonatomic, readonly) BOOL isItalic NS_AVAILABLE_IOS(7_0);
//@property (nonatomic, readonly) BOOL isMonoSpace NS_AVAILABLE_IOS(7_0);
//@property (nonatomic, readonly) BOOL isColorGlyphs NS_AVAILABLE_IOS(7_0);
//@property (nonatomic, readonly) CGFloat fontWeight NS_AVAILABLE_IOS(7_0);
//
//- (nullable UIFont *)fontWithBold NS_AVAILABLE_IOS(7_0);
//
//- (nullable UIFont *)fontWithItalic NS_AVAILABLE_IOS(7_0);
//
//- (nullable UIFont *)fontWithBoldItalic NS_AVAILABLE_IOS(7_0);
//
//- (nullable UIFont *)fontWithNormal NS_AVAILABLE_IOS(7_0);
//
//#pragma mark - creat font
//+ (nullable UIFont *)fontWithCTFont:(CTFontRef)CTFont;
//
//+ (nullable UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size;
//
//- (nullable CTFontRef)CTFontRef CF_RETURNS_RETAINED;
//
//- (nullable CGFontRef)CGFontRef CF_RETURNS_RETAINED;
//
////+ (BOOL)loadFontFromPath:(NSString *)path;
//
////+ (void)unloadFontFromPath:(NSString *)path;
//
////+ (nullable UIFont *)loadFontFromData:(NSData *)data;
//
////+ (BOOL)unloadFontFromData:(UIFont *)font;
//
////+ (nullable NSData *)dataFromFont:(UIFont *)font;
//
////+ (nullable NSData *)dataFromCGFont:(CGFontRef)cgFont;
//
//@end


@interface UIFont (INTCT_Common)

+ (UIFont *)intct_PingFangMediumWithSize:(CGFloat)size;
//+ (UIFont *)intct_PingFangRegularWithSize:(CGFloat)size;
+ (UIFont *)intct_PingFangSemboldWithSize:(CGFloat)size;
+ (UIFont *)intct_PingFangBoldWithSize:(CGFloat)size NS_UNAVAILABLE;

+ (UIFont *)intct_PingFangMedium10;
+ (UIFont *)intct_PingFangMedium11;
+ (UIFont *)intct_PingFangMedium12;
+ (UIFont *)intct_PingFangMedium13;
+ (UIFont *)intct_PingFangMedium14;
+ (UIFont *)intct_PingFangMedium15;
+ (UIFont *)intct_PingFangMedium16;
+ (UIFont *)intct_PingFangMedium17;
+ (UIFont *)intct_PingFangMedium18;
+ (UIFont *)intct_PingFangMedium20;
+ (UIFont *)intct_PingFangMedium24;
+ (UIFont *)intct_PingFangMedium25;
+ (UIFont *)intct_PingFangMedium30;
+ (UIFont *)intct_PingFangMedium35;
+ (UIFont *)intct_PingFangMedium50;

//+ (UIFont *)PingFangRegular13;
//+ (UIFont *)PingFangRegular15;
//+ (UIFont *)PingFangRegular18;

@end

NS_ASSUME_NONNULL_END
