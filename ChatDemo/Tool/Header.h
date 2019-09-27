//
//  Header.h
//  ChatDemo
//
//  Created by Jeremy on 2019/9/26.
//  Copyright © 2019 ChatDemo. All rights reserved.
//

#ifndef Header_h
#define Header_h

typedef void(^INTCTVoidBlock)(void);
typedef void(^INTCTNetProgressBlock)(float progressValue);
// 返回信息结果
typedef void(^INTCTNetRessultMessageBlock)(BOOL isSuccess, id result, NSString * msg);
// 返回信息结果
typedef void(^INTCTNetMessageBlock)(BOOL isSuccess, NSString * msg);
// 返回输出结果
typedef void(^INTCTNetResultBlock)(BOOL isSuccess, id result);

static NSString * const INTCTNetWorkErrorNoteString = @"网络错误，请稍后重试";
static NSString * const INTCTBundleIdentifier = @"com.LetDate.LetDate";

#pragma mark singleInstance

//#define LCINSTANCE_PROPERTY                 ([LCProperty CurrentProperty])
//#define LCINSTANCE_AUTHTOOL                 LCAuthTool
//#define LCCURRENTCONTROLLER                 (LCINSTANCE_AppDelegate.currentController)

/* other  */
#define kEmptyPlaceholderImage          ([UIImage imageNamed:@"picture_empty"])
#define kEmptyIconPlaceHolderImage      ([UIImage imageNamed:@"somebody_icon"])
#define kFacePlaceholderImage           ([UIImage imageNamed:@"profile_default"])

#define SAFESTRING(str)  ( ( ((str)!=nil)&&![(str) isKindOfClass:[NSNull class]])?[NSString stringWithFormat:@"%@",(str)]:@"" )

#define INTCTMajorVersion         [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];            //APP版本
#define INTCTMinorVersion         [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
//#define INTCTBundleIdentifier     [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];

#ifdef DEBUG
#define NSLog(format, ...) NSLog(@"\n内容: %@", [NSString stringWithFormat:format, ##__VA_ARGS__]);
#define NSDetailLog(format, ...) NSLog(@"\n文件: %@ \n方法: %s \n内容: %@ \n行数: %d",[[[NSString stringWithFormat:@"%s",__FILE__] componentsSeparatedByString:@"/"] lastObject], __FUNCTION__,[NSString stringWithFormat:format, ##__VA_ARGS__],__LINE__);
#else
#define NSLog(format, ...)
#define NSDetailLog(format, ...)
#endif


#define INTCTSCREENWIDTH     ([UIScreen mainScreen].bounds.size.width)
#define INTCTSCREENSIZE      ([UIScreen mainScreen].bounds.size)
#define INTCTSCREENHEIGHT    ([UIScreen mainScreen].bounds.size.height)
#define INTCTSCREENBOUNDS    ([UIScreen mainScreen].bounds)

#define INTCT_IS_IPAD            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTCT_IS_IPHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define INTCT_IS_IPHONEXORLATER       (INTCT_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height > 736.0)

#define INTCTNavBarHeight      (INTCTIs5_8InchScreen ? (88) : (64))
#define INTCTLargeTitleHeight  (INTCTIs5_8InchScreen ? (140) : (116))
#define INTCTStateBarHeight    ([INTCTINSTANCE_Application statusBarFrame].size.height)
#define kIphoneXBottomHeight   (INTCT_IS_IPHONEXORLATER ? 34 : 0)
#define kTabbarHeight       (49)

#define INTCTIs5_8InchScreen    (CGSizeEqualToSize(INTCTSCREENSIZE, CGSizeMake(375, 812)))

#define INTCTIOSFLoatSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

#define IOS9_OR_LATER (INTCTIOSFLoatSystemVersion >= 9.0)
#define IOS910_OR_LATER (INTCTIOSFLoatSystemVersion >= 10.0)
#define IOS11_OR_LATER (INTCTIOSFLoatSystemVersion >= 11.0)


NS_INLINE BOOL IsArrayWithItems(id object) {
    return (object && [object isKindOfClass:[NSArray class]] &&
            [(NSArray *)object count] > 0);
}

/* 判断类型 c funcs */
NS_INLINE BOOL IsStringWithAnyText(id object) {
    return (object && [object isKindOfClass:[NSString class]] &&
            ![(NSString *)object isEqualToString:@""] &&
            ![(NSString *)object isEqualToString:@"<null>"]);
}

NS_INLINE BOOL IsStringLengthGreaterThanZero(NSString * string) {
    return (string != nil && string.length > 0);
}

NS_INLINE BOOL IsDictionaryWithItems(id object) {
    return (object && [object isKindOfClass:[NSDictionary class]] &&
            [(NSDictionary *)object count] > 0);
}

//替换字典里的null
NS_INLINE id processDictionaryIsNSNull(id obj) {
    const NSString *blank = @"";
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dt = [(NSMutableDictionary*)obj mutableCopy];
        for(NSString *key in [dt allKeys]) {
            id object = [dt objectForKey:key];
            if([object isKindOfClass:[NSNull class]]) {
                [dt setObject:blank
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSString class]]){
                NSString *strobj = (NSString*)object;
                if ([strobj isEqualToString:@"<null>"]) {
                    [dt setObject:blank
                           forKey:key];
                }
            }
            else if ([object isKindOfClass:[NSArray class]]){
                NSArray *da = (NSArray*)object;
                da = processDictionaryIsNSNull(da);
                [dt setObject:da
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSDictionary class]]){
                NSDictionary *ddc = (NSDictionary*)object;
                ddc = processDictionaryIsNSNull(object);
                [dt setObject:ddc forKey:key];
            }
        }
        return [dt copy];
    }
    else if ([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *da = [(NSMutableArray*)obj mutableCopy];
        for (int i=0; i<[da count]; i++) {
            NSDictionary *dc = [obj objectAtIndex:i];
            dc = processDictionaryIsNSNull(dc);
            [da replaceObjectAtIndex:i withObject:dc];
        }
        return [da copy];
    }
    else{
        return obj;
    }
}

#endif /* Header_h */
