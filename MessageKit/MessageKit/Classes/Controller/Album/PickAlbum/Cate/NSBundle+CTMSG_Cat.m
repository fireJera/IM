//
//  NSBundle+CTMSG_Cat.m
//  微博照片选择
//
//  Created by 洪欣 on 2017/7/25.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "NSBundle+CTMSG_Cat.h"

@implementation NSBundle (CTMSG_Cat)
+ (instancetype)ctmsg_photoPickerBundle {
    static NSBundle *tzBundle = nil;
    if (tzBundle == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CTMSGWeiboPhotoPicker" ofType:@"bundle"];
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:@"CTMSGWeiboPhotoPicker" ofType:@"bundle" inDirectory:@"Frameworks/CTMSGWeiboPhotoPicker.framework/"];
        }
        tzBundle = [NSBundle bundleWithPath:path];
    }
    return tzBundle;
}
+ (NSString *)ctmsg_localizedStringForKey:(NSString *)key
{
    return [self ctmsg_localizedStringForKey:key value:nil];
}

+ (NSString *)ctmsg_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
         
        bundle = [NSBundle bundleWithPath:[[NSBundle ctmsg_photoPickerBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
@end
