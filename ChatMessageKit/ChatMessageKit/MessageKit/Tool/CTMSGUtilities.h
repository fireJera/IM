//
//  CTMSGUtilities.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CTMSGSCREENWIDTH     ([UIScreen mainScreen].bounds.size.width)
#define CTMSGSCREENSIZE      ([UIScreen mainScreen].bounds.size)
#define CTMSGSCREENHEIGHT    ([UIScreen mainScreen].bounds.size.height)

#define CTMSG_IS_IPAD            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define CTMSG_IS_IPHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define CTMSG_IS_IPHONEXORLATER       (CTMSG_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height > 736.0)

#define CTMSGNavBarHeight       (CTMSGIs5_8InchScreen ? (88) : (64))

#define CTMSGIs5_8InchScreen    (CGSizeEqualToSize(CTMSGSCREENSIZE, CGSizeMake(375, 812)))
#define CTMSGNavBarHeight       (CTMSGIs5_8InchScreen ? (88) : (64))
#define CTMSGTabbarHeight       (49)
#define CTMSGBottomHeight       (CTMSGTabbarHeight + ((CTMSG_IS_IPHONEXORLATER) ? 34 : 0))

#define CTMSGIOSFLoatSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IOS9_OR_LATER (CTMSGIOSFLoatSystemVersion >= 9.0)
#define IOS11_OR_LATER (CTMSGIOSFLoatSystemVersion >= 11.0)

#define CTMSGIphoneXBottomH (CTMSG_IS_IPHONEXORLATER ? 34 : 0)

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CTMSGDefaultAvatar;

typedef void(^CTMSGImagesFetchBlock)(NSArray<UIImage *> * images);
typedef void(^CTMSGImageFetchBlock)(UIImage * images);

@class PHAsset;

@interface CTMSGUtilities : NSObject

+ (NSString *)timeStrConvetedByMiseSeconds:(long long)timeSecond;

+ (UIImage *)imageForNameInBundle:(NSString *)imageName;
+ (NSURL *)voiceUrlForName:(NSString *)fileName;

+ (void)creatDirPath:(NSString *)path;

+ (void)fetchImage:(PHAsset *)asset image:(CTMSGImageFetchBlock)image;

+ (void)fetchImages:(NSArray<PHAsset *> *)assets images:(CTMSGImagesFetchBlock)images;

@end

NS_ASSUME_NONNULL_END
