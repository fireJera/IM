//
//  UIImage+INTCT_Custom.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (INTCT_Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 几乎用不到 因为是纯色 所有size没什么用 默认的{1, 1}就好了
 
 @param color UIColor
 @param size 图片的size
 @return 纯色的图
 */
+ (UIImage *)imageWithColor:(UIColor*)color size:(CGSize)size;

@end

@interface UIImage (INTCT_Custom)

// 本地
+ (UIImage *)imageInLocalVideoPath:(NSString *)videoPath;
+ (NSArray<UIImage *> *)imagesInLocalVideoPath:(NSString *)videoPath timeInterval:(NSTimeInterval)time;
// 网络
+ (UIImage *)imageInVideoUrl:(NSURL *)videoUrl;
- (UIImage *)addCornerRadius:(CGFloat)cornerRadius;
- (UIImage *)rotate:(UIImageOrientation)orient;

/**
 *  修改图片size
 *
 *  @param image      原图片
 *  @param targetSize 要修改的size
 *
 *  @return 修改后的图片
 */
+ (UIImage *)image:(UIImage *)image byScalingToSize:(CGSize)targetSize;
- (UIImage *)imageScaleToSize:(CGSize)targetSize;
- (UIImage *)scaleImage:(float)scale;

- (nullable NSData *)imageRepensationWithQuality:(float)quality;

- (UIImage *)addGaussinBlur:(CGFloat)blur;

@end

@interface UIImage (INTCT_Base64)

- (NSString *)imageBase64String;

@end

NS_ASSUME_NONNULL_END
