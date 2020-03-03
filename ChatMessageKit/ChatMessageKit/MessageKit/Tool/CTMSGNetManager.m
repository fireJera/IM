//
//  CTMSGNetManager.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/8.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGNetManager.h"

#if __has_include (<AFNetworking.h>)
#import <AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

static const int kIsDev = 1;
#if DEBUG
static NSString * const CTMSGBaseUrlString = kIsDev == 1 ? @"https://dev-api.imdsk.com" : @"https://test-api.imdsk.com";
//static NSString * const CTMSGWebUrlHost = kIsDev == 1 ? @"https://dev-m.imdsk.com/" : @"https://test-m.imdsk.com/";
#else
static NSString * const CTMSGBaseUrlString = @"https://api.imdsk.com";
//static NSString * const UCNWebUrlHost = @"https://m.imdsk.com/";
#endif

static NSString * const kChatDetail = @"msg/detail";
static NSString * const kChatList = @"msg/list";
static NSString * const kDelCon = @"msg/del-index";
static NSString * const kDelMsg = @"msg/del-msg";
static NSString * const kReadMsg = @"msg/read-index";
static NSString * const kSendMsg = @"msg/send";
static NSString * const kUploadMsg = @"upload/msg";
//static NSString * const kContentType = @"application/json";

static NSString * const kContentType = @"application/json";

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
    NSURL * baseUrl = [NSURL URLWithString:CTMSGBaseUrlString];
    AFHTTPRequestOperationManager *mgr = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseUrl];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:kContentType];
    mgr.requestSerializer.HTTPShouldHandleCookies = YES;
    
    NSString *cookieString = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCookies"];
    
    if (cookieString)
        [mgr.requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    switch (methodType) {
        case RequestMethodTypeGet: {
            // GET请求
            [mgr GET:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObj) {
                 if (success) {
                     success(responseObj);
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if (failure) {
                     failure(error);
                 }
             }];
        } break;
            
        case RequestMethodTypePost: {
            // POST请求
            [mgr POST:url parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObj) {
                  if (success) {
                      if ([url isEqualToString:@"user/login"]) {
                          NSString *cookieString = [[operation.response allHeaderFields] valueForKey:@"Set-Cookie"];
                          NSMutableString *finalCookie = [NSMutableString new];
                          NSArray *cookieStrings = [cookieString componentsSeparatedByString:@","];
                          for (NSString *temp in cookieStrings) {
                              NSArray *tempArr = [temp componentsSeparatedByString:@";"];
                              [finalCookie appendString:[NSString stringWithFormat:@"%@;", tempArr[0]]];
                          }
                          [[NSUserDefaults standardUserDefaults] setObject:finalCookie forKey:@"UserCookies"];
                          [[NSUserDefaults standardUserDefaults] synchronize];
                      }
                      success(responseObj);
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

+ (void)getConversationListLastId:(nullable NSString *)lastId success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSDictionary * params;
    if (lastId) {
        params = @{
                   @"last_id": lastId
                   };
    }
    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
                                   url:kChatList
                                params:params
                               success:success
                               failure:failure];
}

+ (void)getConversationDetail:(NSString *)targetId lastId:(nullable NSString *)lastId success:(nonnull void (^)(id _Nonnull))success failure:(nonnull void (^)(NSError * _Nonnull))failure {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSMutableDictionary * params = [@{
                                      @"toUserid": targetId,
                                      } mutableCopy];
    if (lastId) {
        [params setValue:lastId forKey:@"last_id"];
    }
    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
                                   url:kChatDetail
                                params:params
                               success:success
                               failure:failure];
}

+ (void)removeConversation:(NSString *)targetId success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSDictionary * params = @{@"userid": targetId};
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kDelCon
                                params:params
                               success:success
                               failure:failure];
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
    NSDictionary * params = @{};
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kReadMsg
                                params:params
                               success:success
                               failure:failure];
}

+ (void)sendMessage:(NSDictionary *)dic success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSDictionary * params = @{};
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kSendMsg
                                params:params
                               success:success
                               failure:failure];
}

+ (void)sendTextMessageToUser:(NSString *)targetId content:(NSString *)content success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSParameterAssert(targetId && content);
    if (!targetId || !content) return;
    NSDictionary * params = @{
                              @"userid": targetId,
                              @"content": content,
                              @"type": @"txt",
                              };
    [CTMSGNetManager requestWihtMethod:RequestMethodTypePost
                                   url:kSendMsg
                                params:params
                               success:success
                               failure:failure];
}

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
