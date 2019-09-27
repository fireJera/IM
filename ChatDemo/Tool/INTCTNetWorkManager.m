//
//  INTCTNetWorkManager.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "INTCTNetWorkManager.h"
//#import "INTCTViewmodelHeader.h"
#import <CoreTelephony/CTCellularData.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "sys/utsname.h"
#import "NSString+INTCT_Custom.h"
#import "Header.h"
#import "INTCTUser.h"
//#import "INTCTAppData.h"


#if __has_include (<AFNetworking.h>)
#import <AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import "INTCTKeyChain.h"
//#import "INTCTRequest.h"
//#import "INTCTControllerHeader.h"
//#import "INTCTHUDPopHelper.h"
//#import "INTCTOpenPageHelper.h"
#import <objc/message.h>

#if DEBUG
static NSString * const INTCTBaseUrlString = @"https://newdev-api.imdsk.com/";
#else
static NSString * const INTCTBaseUrlString = @"https://api.zchat001.com/";
#endif

static CTCellularData * _cellularData = nil;

@interface INTCTNetWorkManager()

@property (class, nonatomic, strong) CTCellularData * cellularData;

@end

@implementation INTCTNetWorkManager

@dynamic cellularData;

+ (BOOL)netReachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

+ (BOOL)wifiRachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}

+ (void)intct_startMonitoringNet:(void (^)(BOOL isSuccess))resultBlock {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (resultBlock) {
            resultBlock(YES);
        }
    }];
}

+ (AFHTTPSessionManager*) manager
{
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *manager = nil;
    dispatch_once(&onceToken, ^{
        [self checkInitNetAuth];
        manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[self intct_defaultUserAgentString:NO] forHTTPHeaderField:@"User-Agent"];
    });
    
    return manager;
}

+ (AFHTTPSessionManager *)intct_get:(NSString *)string withParameters:(NSDictionary *)parameters success:(INTCTNetSuccessBlock)succeess failed:(INTCTNetFailBlock)failed {
    [self p_intct_checkNetAuth];
    NSString * urlString = [self p_intct_checkUrlString:string];
    AFHTTPSessionManager * manager = [self manager];
    //    manager.requestSerializer.timeoutInterval=10;
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id nonNullDic = processDictionaryIsNSNull(responseObject);
//        NSLog(@"net get response: %@", responseObject);
        if (IsDictionaryWithItems(nonNullDic)) {
            if ([nonNullDic[@"ok"] intValue] == 1) {
                if (succeess) {
                    succeess(nonNullDic);
                }
            } else {
                NSString * str = nonNullDic[@"msg"];
                if (!str || str.length == 0) {
                    str = INTCTNetWorkErrorNoteString;
                }
                if (failed) {
                    failed([[self class] netReachable], str, nonNullDic);
                }
            }
        }
        [INTCTNetWorkManager p_intct_judgeOk:nonNullDic];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary * dic = error.userInfo;
        NSString * str = dic[NSLocalizedDescriptionKey];
        if (failed) {
            failed([[self class] netReachable], str, nil);
        }
//        [INTCTHUDPopHelper showTextHUD:str];
    }];
    return manager;
}

+ (AFHTTPSessionManager *)intct_post:(NSString *)string
                      withParameters:(NSDictionary *)parameters
                             success:(INTCTNetSuccessBlock)succeess
                              failed:(INTCTNetFailBlock)failed {
    [self p_intct_checkNetAuth];
    NSString * urlString = [self p_intct_checkUrlString:string];
    AFHTTPSessionManager * manager = [self manager];
    [manager.requestSerializer setValue:[INTCTNetWorkManager intct_defaultUserAgentString:NO] forHTTPHeaderField:@"User-Agent"];
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"net post response: %@", responseObject);
        NSString * str;
        id failPara;
        id nonNullDic = processDictionaryIsNSNull(responseObject);
        if (IsDictionaryWithItems(nonNullDic)) {
            if ([nonNullDic[@"ok"] intValue] == 1) {
                if (succeess) {
                    succeess(nonNullDic);
                }
            } else {
                str = nonNullDic[@"msg"];
                failPara = nonNullDic;
                if (failed) {
                    failed([[self class] netReachable], str, failPara);
                }
            }
        }
//        [INTCTHUDPopHelper showTextHUD:str];
        [INTCTNetWorkManager p_intct_judgeOk:nonNullDic];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary * dic = error.userInfo;
        NSString * str = dic[NSLocalizedDescriptionKey];
        if (failed) {
            failed([[self class] netReachable], str, nil);
        }
//        [INTCTHUDPopHelper showTextHUD:str];
    }];
    return manager;
}

+ (AFHTTPSessionManager *)intct_postManulCallback:(NSString *)string withParameters:(NSDictionary *)parameters success:(INTCTNetSuccessBlock)succeess failed:(INTCTNetFailBlock)failed {
    [self p_intct_checkNetAuth];
    NSString * urlString = [self p_intct_checkUrlString:string];
    AFHTTPSessionManager * manager = [self manager];
    [manager.requestSerializer setValue:[INTCTNetWorkManager intct_defaultUserAgentString:NO] forHTTPHeaderField:@"User-Agent"];
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSLog(@"net post response: %@", responseObject);
        NSString * str;
        id failPara;
        id nonNullDic = processDictionaryIsNSNull(responseObject);
        if (IsDictionaryWithItems(nonNullDic)) {
            if ([nonNullDic[@"ok"] intValue] == 1) {
                if (succeess) {
                    succeess(nonNullDic);
                }
            } else {
                str = nonNullDic[@"msg"];
                failPara = nonNullDic;
                if (failed) {
                    failed([[self class] netReachable], str, failPara);
                }
            }
        }
//        [INTCTHUDPopHelper showTextHUD:str];
//        [INTCTNetWorkManager p_intct_judgeOk:nonNullDic];5
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSDictionary * dic = error.userInfo;
        NSString * str = dic[NSLocalizedDescriptionKey];
        if (failed) {
            failed([[self class] netReachable], str, nil);
        }
//        [INTCTHUDPopHelper showTextHUD:str];
    }];
    return manager;
}

+ (void)intct_sendRequest:(NSMutableDictionary *)postData
                  reqData:(NSDictionary *)reqData
                   method:(NSString *)method
             successBlock:(void (^)(BOOL isSuccess, id result))successBlock
             failureBlock:(HttpRequestFailBlock)failureBlock {
    NSString *urlString = method;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSArray * headers = reqData[@"header"];
    for (NSString * header in headers) {
        NSArray * headerFields = [header componentsSeparatedByString:@":"];
        if (headerFields.count > 1) {
            [request addValue:headerFields[1] forHTTPHeaderField:headerFields.firstObject];
        }
    }
    
    NSString * dataStr = reqData[@"data"];
    NSDictionary * dataDic = [dataStr convertToObject];
    NSArray * keys = dataDic.allKeys;
    for (NSString * key in keys) {
        [postData setValue:dataDic[key] forKey:key];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"body.dat"];
    [data writeToFile:path atomically:YES];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (((NSHTTPURLResponse *)response).statusCode != 200) {
                NSError * error = [NSError errorWithDomain:@"com.intctNetworkmanager.youtuerror" code:((NSHTTPURLResponse *)response).statusCode userInfo:@{NSLocalizedDescriptionKey : @"error"}];
                if (failureBlock) {
                    failureBlock(error);
                }
            } else {
                if (successBlock) {
                    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    successBlock(YES, str);
                }
            }
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }] resume];
}

+ (void)intct_conductRequest:(INTCTRequest *)request {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:0];
//    for (NSDictionary * dataDic in request.postData) {
//        if (IsDictionaryWithItems(dataDic)) {
//            [parameters setValue:dataDic[@"value"] forKey:dataDic[@"key"]];
//        }
//    }
////    MBProgressHUD * hud = [INTCTHUDPopHelper customProgressHUDTitle:nil];
//    //    NSString * urlString = [NSString stringWithFormat:@"%@?token=%@", request.url, INTCTINSTANCE_USER.token];
//    [self intct_post:request.url withParameters:parameters success:^(id result) {
////        dispatch_async(dispatch_get_main_queue(), ^{
////            [hud hideAnimated:YES];
////        });
//    } failed:^(BOOL netReachable, NSString *msg, id result) {
////        dispatch_async(dispatch_get_main_queue(), ^{
////            [hud hideAnimated:YES];
////        });
//    }];
}

+ (NSString *)p_intct_checkUrlString:(NSString *)originStr {
    NSString * urlString;
    if ([originStr hasPrefix:@"https://"] || [originStr hasPrefix:@"http://"]) {
        urlString = originStr;
    } else {
        urlString = [NSString stringWithFormat:@"%@%@", INTCTBaseUrlString, originStr];
    }
    NSString * suffixStr = [[INTCTNetWorkManager intct_urlStringSuffix:NO] URLEncode];
    if ([urlString containsString:@"?"]) {
        urlString = [NSString stringWithFormat:@"%@&token=%@&_ua=%@", urlString, INTCTINSTANCE_USER.token, suffixStr];
    } else {
        urlString = [NSString stringWithFormat:@"%@?token=%@&_ua=%@", urlString, INTCTINSTANCE_USER.token, suffixStr];
    }
    return urlString;
}

+ (NSString *)intct_defaultUserAgentString:(BOOL)isBlockRequest {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString * bundleIdentifier = INTCTBundleIdentifier;
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSUTF8StringEncoding];
    if (!appName) return nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = nil;
    if (marketingVersionNumber && developmentVersionNumber) {
        appVersion = marketingVersionNumber;
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    // 这个是系统设置中的语言 应服务器要求改为语言
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    // 这个是系统设置中的地区 原本使用的是地区 现在注释掉
    //    NSString *locale = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
    UIDevice *device = [UIDevice currentDevice];
    deviceName = [self intct_getCurrentDeviceModelName];
    OSName = [device systemName];
    OSVersion = [device systemVersion];
    NSString *networkInfo = @"unknow" ;
    if ([INTCTNetWorkManager p_intct_wifiSSID]) {
        networkInfo = [INTCTNetWorkManager p_intct_wifiSSID];
    } else if ([INTCTNetWorkManager netReachable]) {
        networkInfo = [INTCTNetWorkManager p_intct_coperationBrand];
    }
    NSString * uuid = [INTCTKeyChain UUId];
    NSString * httpUserAgent = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%d|%@|%@|%@|%@", OSName, OSVersion, appVersion, @"appstore", uuid, language, isBlockRequest, INTCTINSTANCE_USER.token, bundleIdentifier, [networkInfo base64String], deviceName];
    
    return [NSString stringWithFormat:@"%@/%@ (%@; %@ %@; %@)/%@", appName, appVersion, deviceName, OSName, OSVersion, language, httpUserAgent];
}

+ (NSString *)intct_urlStringSuffix:(BOOL)isBlockRequest {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSUTF8StringEncoding];
    if (!appName) return nil;
    NSString * bundleIdentifier = INTCTBundleIdentifier;
    NSString * marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersion = nil;
    if (marketingVersionNumber && developmentVersionNumber) {
        appVersion = marketingVersionNumber;
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    // 这个是系统设置中的语言 应服务器要求改为语言
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    // 这个是系统设置中的地区 原本使用的是地区 现在注释掉
//    NSString *locale = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
    UIDevice *device = [UIDevice currentDevice];
    deviceName = [self intct_getCurrentDeviceModelName];
    OSName = [device systemName];
    OSVersion = [device systemVersion];
    NSString * uuidStr = [INTCTKeyChain UUId];
    NSString *networkInfo = @"unknow" ;
    if ([INTCTNetWorkManager p_intct_wifiSSID]) {
        networkInfo = [INTCTNetWorkManager p_intct_wifiSSID];
    } else if ([INTCTNetWorkManager netReachable]) {
        networkInfo = [INTCTNetWorkManager p_intct_coperationBrand];
    }
    NSAssert(uuidStr != nil, @"can't get uuid, uuid is nil");
    return [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%d|%@|%@|%@|%@", @"ios", OSVersion, appVersion, @"appstore", uuidStr, language, isBlockRequest, INTCTINSTANCE_USER.token, bundleIdentifier, [networkInfo base64String], deviceName];
}

+ (void)p_intct_judgeOk:(id)dictionary {
    if (IsDictionaryWithItems(dictionary)) {
        int ok = [dictionary[@"ok"] intValue];
        if (ok == -1) {
            [INTCTINSTANCE_USER intct_signOut];
            [self p_intct_showLogin:SAFESTRING(dictionary[@"msg"])];
        }
        NSDictionary * dic = dictionary[@"callback"];
        if (dic) {
            [self intct_dealCallbackWithJson:dic];
        }
    }
}

+ (void)p_intct_showLogin:(NSString *)msg {
    //    @"您的账号在别的设备上登录，您已被迫下线"
    [INTCTINSTANCE_USER intct_signOut];
    SEL selector = NSSelectorFromString(@"netLogout");
    if ([self respondsToSelector:selector]) {
//        [self performSelector:selector];
        ((void(*)(id, SEL))(void *)objc_msgSend)(self, selector);
    }
//    [INTCTOpenPageHelper intct_showCustomAlertWithTitle:msg block:^(INTCTOpenAlert * _Nonnull alert) {
//        alert.title(@"知道了").defaultStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//            SEL selector = NSSelectorFromString(@"openLogin");
////            if ([INTCTOpenPageHelper respondsToSelector:selector]) {
////                [INTCTOpenPageHelper performSelector:selector];
////            }
//        };
//    }];
//    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
//    //    [INTCTINSTANCE_AppDelegate INTCT_rootSign];
//    [INTCTINSTANCE_Application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)intct_dealCallbackWithJson:(NSDictionary *)dic {
//    INTCTNetCallback * callback = [INTCTNetCallback new];
//    callback.intct_deal(dic);
}

+ (void)checkInitNetAuth {
    if (!_cellularData) {
        _cellularData = [[CTCellularData alloc] init];
    }
    _cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        //获取联网状态
        if (state == kCTCellularDataRestricted) {
            
        }
        else if (state == kCTCellularDataNotRestricted) {
            
        }
        else if (state == kCTCellularDataRestrictedStateUnknown) {
            
        }
    };
}

+ (void)p_intct_checkNetAuth {
    CTCellularDataRestrictedState state = _cellularData.restrictedState;
    if (state == kCTCellularDataRestricted) {
        if (![self wifiRachable]) {
//            [INTCTOpenPageHelper intct_openNetAlert];
//            [[[INTCTNetCallback alloc] init] intct_openNetAlert];
        }
    }
}

+ (NSString *)intct_getCurrentDeviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *currentDevice = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([currentDevice isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([currentDevice isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([currentDevice isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([currentDevice isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([currentDevice isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([currentDevice isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([currentDevice isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([currentDevice isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([currentDevice isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([currentDevice isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([currentDevice isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([currentDevice isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([currentDevice isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([currentDevice isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([currentDevice isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([currentDevice isEqualToString:@"iPhone9,1"])    return @"iPhone 7";//国行、日版、港行
    if ([currentDevice isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";//港行、国行
    if ([currentDevice isEqualToString:@"iPhone9,3"])    return @"iPhone 7";//美版、台版
    if ([currentDevice isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";//美版、台版
    if ([currentDevice isEqualToString:@"iPhone10,1"])   return @"iPhone 8"; //国行(A1863)、日行(A1906)
    if ([currentDevice isEqualToString:@"iPhone10,4"])   return @"iPhone 8"; // 美版(Global/A1905)
    if ([currentDevice isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus"; // 国行(A1864)、日行(A1898)
    if ([currentDevice isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus"; // 美版(Global/A1897)
    if ([currentDevice isEqualToString:@"iPhone10,3"])   return @"iPhone X"; // 国行(A1865)、日行(A1902)
    if ([currentDevice isEqualToString:@"iPhone10,6"])   return @"iPhone X"; // 美版(Global/A1901)
    if ([currentDevice isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([currentDevice isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([currentDevice isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([currentDevice isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    
    //    if ([currentDevice isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    //    if ([currentDevice isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    //    if ([currentDevice isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    //    if ([currentDevice isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    //    if ([currentDevice isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([currentDevice containsString:@"iPad"]) {
        return @"iPad";
    }if ([currentDevice containsString:@"iPod"]) {
        return @"iPod";
    }else if ([currentDevice containsString:@"i386"] || [currentDevice containsString:@"x86_64"]) {
        return @"Simulator";
    }else if ([currentDevice containsString:@"AppleTV"]) {
        return @"AppleTV";
    }
    return @"unknow model";
}

+ (NSString *)p_intct_wifiSSID {
    NSString *wifiName = @"unknowWiFi";
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs)
    {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"])
        {
            wifiName = info[@"SSID"];
        }
    }
    return wifiName;
}

+ (NSString *)p_intct_coperationBrand {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mobileName = @"unknowCellular";
    if (!carrier || [carrier mobileNetworkCode] == nil) {
        return mobileName;
    }
    NSString *code = [carrier mobileNetworkCode];
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        mobileName = @"cmccCellular";
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        mobileName = @"cuccCellular";
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        mobileName = @"ctcCellular";
    } else if ([code isEqualToString:@"20"]) {
        mobileName = @"铁通运营商";
    }else {
        mobileName = @"unknowCellular";
    }
    return mobileName;
}


@end
