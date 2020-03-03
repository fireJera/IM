//
//  CTMSGBeautyFilter.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#if __has_include(<GPUImage/GPUImage.h>)
#import <GPUImage/GPUImage.h>
#elif __has_include("GPUImage/GPUImage.h")
#import "GPUImage/GPUImage.h"
#else
#import "GPUImage.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGBeautyFilter : GPUImageFilter


/** 美颜程度 */
@property (nonatomic, assign) CGFloat beautyLevel;
/** 美白程度 */
@property (nonatomic, assign) CGFloat brightLevel;
/** 色调强度 */
@property (nonatomic, assign) CGFloat toneLevel;

@end

NS_ASSUME_NONNULL_END
