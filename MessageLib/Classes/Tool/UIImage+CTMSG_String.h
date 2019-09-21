//
//  UIImage+CTMSG_String.h
//  MessageLib
//
//  Created by Jeremy on 2019/5/27.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CTMSG_String)
+ (UIImage *)ctmsg_libImageInLocalPath:(NSString *)videoPath;
- (NSString *)ctmsg_imageBase64String;

@end

NS_ASSUME_NONNULL_END
