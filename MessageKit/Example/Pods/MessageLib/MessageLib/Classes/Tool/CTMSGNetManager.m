//
//  CTMSGNetManager.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/8.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGNetManager.h"
#import "CTMSGIMClient.h"

#if __has_include (<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking/AFNetworking.h"
#endif

//替换字典里的null
NS_INLINE id processDictionaryNullValue(id obj) {
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
                da = processDictionaryNullValue(da);
                [dt setObject:da
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSDictionary class]]){
                NSDictionary *ddc = (NSDictionary*)object;
                ddc = processDictionaryNullValue(object);
                [dt setObject:ddc forKey:key];
            }
        }
        return [dt copy];
    }
    else if ([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *da = [(NSMutableArray*)obj mutableCopy];
        for (int i=0; i<[da count]; i++) {
            NSDictionary *dc = [obj objectAtIndex:i];
            dc = processDictionaryNullValue(dc);
            [da replaceObjectAtIndex:i withObject:dc];
        }
        return [da copy];
    }
    else{
        return obj;
    }
}

#if DEBUG
static NSString * const CTMSGBaseUrlString = @"https://newdev-api.imdsk.com/";
#else
static NSString * const CTMSGBaseUrlString = @"https://api.zchat001.com/";
#endif

//static NSString * const kChatList = @"immsg/list";
static NSString * const kDelMsg = @"immsg/del-msg";
static NSString * const kSendMsg = @"immsg/send";
static NSString * const kUploadMsg = @"upload/msg";

//static NSString * const kContentType = @"application/json";

@implementation CTMSGNetManager

//+ (void)ctmsg_get:(NSString *)string withParameters:(NSDictionary *)parameters success:(CTMSGNetSuccessBlock)succeess failed:(CTMSGNetFailBlock)failed {
//
//}
//
//+ (void)ctmsg_post:(NSString *)string withParameters:(NSDictionary *)parameters success:(CTMSGNetSuccessBlock)succeess failed:(CTMSGNetFailBlock)failed {
//
//}

//+ (instancetype)shareInstance {
//    static CTMSGNetManager *instance = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        instance = [[[self class] alloc] init];
//    });
//    return instance;
//}

//+ (AFHTTPSessionManager*)manager
//{
//    static dispatch_once_t onceToken;
//    static AFHTTPSessionManager *manager = nil;
//    dispatch_once(&onceToken, ^{
//        //before
//        //        manager = [AFHTTPSessionManager manager];
//        //after
//        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:CTMSGBaseUrlString]];
////        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""]];
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:kContentType];
//        manager.requestSerializer.HTTPShouldHandleCookies = YES;
//    });
//
//    return manager;
//}

+ (BOOL)netReachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

+ (BOOL)wifiReachable {
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}

+ (void)startMonitoringNet:(void (^)(void))resultBlock {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (resultBlock) {
            resultBlock();
        }
    }];
}


+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
    //获得请求管理者
//    NSURL * baseUrl = [NSURL URLWithString:CTMSGBaseUrlString];
//    if (![self netReachable]) {
//        NSString *domain = @"com.MessageLib.CTMSGNetWorkManager.ErrorDomain";
//        NSString *desc = @"当前网络无法连接";
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//        NSError *netError = [NSError errorWithDomain:domain
//                                                code:-1011
//                                            userInfo:userInfo];
//        if (failure) {
//            failure(netError);
//        }
//        return;
//    }
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //[[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    [mgr.requestSerializer setValue:[CTMSGIMClient sharedCTMSGIMClient].userAgent forHTTPHeaderField:@"User-Agent"];
    url = [self p_intct_checkUrlString:url];
    switch (methodType) {
        case RequestMethodTypeGet: {
            // GET请求
            [mgr GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                id nonNullDic = processDictionaryNullValue(responseObject);
                if ([nonNullDic[@"ok"] intValue] == 1) {
                    if (success) {
                        success(nonNullDic);
                    }
                } else {
                    NSString *domain = @"com.MessageLib.CTMSGNetWorkManager.ErrorDomain";
                    NSString *desc = nonNullDic[@"msg"];
                    if (!desc) {
                        desc = @"net error";
                    }
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                    NSError *netError = [NSError errorWithDomain:domain
                                                            code:-1011
                                                        userInfo:userInfo];
                    if (failure) {
                        failure(netError);
                    }
                    if ([nonNullDic[@"ok"] intValue] == -1) {
                        if ([[CTMSGIMClient sharedCTMSGIMClient].connectDelegate respondsToSelector:@selector(requireNewNetToken)]) {
                            [[CTMSGIMClient sharedCTMSGIMClient].connectDelegate requireNewNetToken];
                        }
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        } break;
            
        case RequestMethodTypePost: {
            // POST请求
            [mgr POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                id nonNullDic = processDictionaryNullValue(responseObject);
                if ([nonNullDic[@"ok"] intValue] == 1) {
                    if (success) {
                        success(nonNullDic);
                    }
                }
                else {
                    NSString *domain = @"com.MessageLib.CTMSGNetWorkManager.ErrorDomain";
                    NSString *desc = nonNullDic[@"msg"];
                    if (!desc) {
                        desc = @"net error";
                    }
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
                    NSError *netError = [NSError errorWithDomain:domain
                                                            code:-1011
                                                        userInfo:userInfo];
                    if (failure) {
                        failure(netError);
                    }
                    if ([nonNullDic[@"ok"] intValue] == -1) {
                        if ([[CTMSGIMClient sharedCTMSGIMClient].connectDelegate respondsToSelector:@selector(requireNewNetToken)]) {
                            [[CTMSGIMClient sharedCTMSGIMClient].connectDelegate requireNewNetToken];
                        }
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSString *domain = @"com.BanteaySrei.BanteaySrei.ErrorDomain";
//                NSString *desc = @"网络故障";
//                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc };
//                NSError *netError = [NSError errorWithDomain:domain
//                                                        code:-1011
//                                                    userInfo:userInfo];
                if (failure) {
                    failure(error);
                }
            }];
        } break;
        default:
            break;
    }
}

// get user info
+ (void)getUserInfo:(NSString *)userId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure {
    NSDictionary * dic;
    if (userId) {
        dic = @{@"userid": userId};
    }
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:@""
                                params:dic
                               success:success
                               failure:failure];
}

//+ (void)getConversationListLastId:(nullable NSString *)lastId success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
//    NSDictionary * params;
//    if (lastId) {
//        params = @{
//                   @"last_id": lastId
//                   };
//    }
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
//                                   url:kChatList
//                                params:params
//                               success:success
//                               failure:failure];
//}

//+ (void)getConversationDetailWithTargetId:(NSString *)targetId lastId:(NSString *)lastId success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
//    NSParameterAssert(targetId);
//    if (!targetId) return;
//    NSMutableDictionary * params = [@{
//                                      @"toUserid": targetId,
//                                      } mutableCopy];
//    if (lastId) {
//        [params setValue:lastId forKey:@"last_id"];
//    }
//    NSString * const ChatDetail = @"msg/detail";
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
//                                   url:ChatDetail
//                                params:params
//                               success:success
//                               failure:failure];
//}

+ (void)removeConversation:(NSString *)targetId success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSLog(@"unimplemented  do it yourself ");
//    NSParameterAssert(targetId);
//    if (!targetId) return;
//    NSDictionary * params = @{@"userid": targetId};
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
//                                   url:kDelCon
//                                params:params
//                               success:success
//                               failure:failure];
}

+ (void)removeMessage:(NSString *)messageId targetId:(nonnull NSString *)targetId success:(nonnull void (^)(id _Nonnull))success failure:(nonnull void (^)(NSError * _Nonnull))failure {
    NSParameterAssert(targetId && messageId);
    if (!targetId || !messageId) return;
    NSDictionary * params = @{
                              @"userid": targetId,
                              @"msg_id": messageId,
                              };
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kDelMsg
                                params:params
                               success:success
                               failure:failure];
}

+ (void)readConversation:(NSString *)targetId success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
//    NSDictionary * params = @{};
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
//                                   url:kReadMsg
//                                params:params
//                               success:success
//                               failure:failure];
}

//+ (void)sendMessage:(NSDictionary *)dic success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
//    NSDictionary * params = @{};
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
//                                   url:kSendMsg
//                                params:params
//                               success:success
//                               failure:failure];
//}

+ (void)sendMessageWithParameters:(NSDictionary *)parameters success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSParameterAssert(parameters);
    if (!parameters) return;
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kSendMsg
                                params:parameters
                               success:success
                               failure:failure];
}

//+ (void)sendTextMessageToUser:(NSString *)targetId content:(NSString *)content success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
//    NSParameterAssert(targetId && content);
//    if (!targetId || !content) return;
//    NSDictionary * params = @{
//                              @"userid": targetId,
//                              @"content": content,
//                              @"type": @"txt",
//                              };
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
//                                   url:kSendMsg
//                                params:params
//                               success:success
//                               failure:failure];
//}

+ (void)uploadMessage:(NSDictionary *)dic success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSDictionary * params = @{};
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kUploadMsg
                                params:params
                               success:success
                               failure:failure];
}

//+ (void)getFriendsSuccess:(void (^)(id response))success failure:(void (^)(NSError *err))failure {
//    //获取包含自己在内的全部注册用户数据
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet url:@"friends" params:nil success:success failure:failure];
//}
//
//+ (void)getFriendListFromServerSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
//    //获取除自己之外的好友信息
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
//                                   url:@""
//                                params:nil
//                               success:success
//                               failure:failure];
//}

//加入黑名单
+ (void)addToBlacklist:(NSString *)userId
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{@"friendId" : userId};
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:@"user/add_to_blacklist"
                                params:params
                               success:success
                               failure:failure];
}

//从黑名单中移除
+ (void)removeToBlacklist:(NSString *)userId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
    NSDictionary *params = @{@"friendId" : userId};
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:@"user/remove_from_blacklist"
                                params:params
                               success:success
                               failure:failure];
}

//获取黑名单列表
+ (void)getBlacklistsuccess:(void (^)(id response))success failure:(void (^)(NSError *err))failure {
    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
                                   url:@"user/blacklist"
                                params:nil
                               success:success
                               failure:failure];
}

+ (NSString *)p_intct_checkUrlString:(NSString *)originStr {
    NSString * urlString;
    if ([originStr hasPrefix:@"https://"] || [originStr hasPrefix:@"http://"]) {
        urlString = originStr;
    } else {
        urlString = [NSString stringWithFormat:@"%@%@", CTMSGBaseUrlString, originStr];
    }
    NSString * suffixStr = [self URLEncode:[CTMSGIMClient sharedCTMSGIMClient].netUA];
    if ([urlString containsString:@"?"]) {
        urlString = [NSString stringWithFormat:@"%@&token=%@&_ua=%@", urlString, [CTMSGIMClient sharedCTMSGIMClient].netToken, suffixStr];
    } else {
        urlString = [NSString stringWithFormat:@"%@?token=%@&_ua=%@", urlString, [CTMSGIMClient sharedCTMSGIMClient].netToken, suffixStr];
    }
    return urlString;
}

+ (NSString *)URLEncode:(NSString *)url {
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString * encodedStr = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedStr;
}

////更新当前用户名称
//+ (void)updateName:(NSString *)userName success:(void (^)(id response))success failure:(void (^)(NSError *err))failure {
//    
//}

////获取版本信息
//+ (void)getVersionsuccess:(void (^)(id response))success failure:(void (^)(NSError *err))failure {
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
//                              url:@"/misc/client_version"
//                           params:nil
//                          success:success
//                          failure:failure];
//}

@end
