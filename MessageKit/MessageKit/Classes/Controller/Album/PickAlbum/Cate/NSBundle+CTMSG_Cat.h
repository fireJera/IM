//
//  NSBundle+CTMSG_Cat.h
//  微博照片选择
//
//  Created by 洪欣 on 2017/7/25.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (CTMSG_Cat)
+ (instancetype)ctmsg_photoPickerBundle;
+ (NSString *)ctmsg_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)ctmsg_localizedStringForKey:(NSString *)key;
@end
