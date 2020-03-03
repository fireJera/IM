//
//  CTMSGNetManager.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/8.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestMethodType) { RequestMethodTypePost = 1, RequestMethodTypeGet = 2 };

NS_ASSUME_NONNULL_BEGIN

typedef void(^CTMSGNetSuccessBlock)(id _Nullable result);
// 失败结果
typedef void(^CTMSGNetFailBlock)(NSString * _Nullable msg, id _Nullable result);

//typedef void(^HttpRequestFailBlock)(NSError * _Nullable error);

@interface CTMSGNetManager : NSObject

+ (BOOL)netReachable;
+ (BOOL)wifiReachable;
+ (void)startMonitoringNet:(void(^)(void))resultBlock;

//+ (void)ctmsg_get:(NSString *)string
//   withParameters:(nullable NSDictionary *)parameters
//          success:(_Nullable CTMSGNetSuccessBlock)succeess
//           failed:(_Nullable CTMSGNetFailBlock)failed;
//
//+ (void)ctmsg_post:(NSString *)string
//    withParameters:(nullable NSDictionary *)parameters
//           success:(_Nullable CTMSGNetSuccessBlock)succeess
//            failed:(_Nullable CTMSGNetFailBlock)failed;

/**
 *  发送一个请求
 *
 *  @param methodType   请求方法
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(nullable NSDictionary *)params
                  success:(void (^ _Nullable)(id response))success
                  failure:(void (^ _Nullable)(NSError *err))failure;

// get user info
+ (void)getUserInfo:(NSString *)userId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

////
//+ (void)getConversationListLastId:(nullable NSString *)lastId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

//
//+ (void)getConversationDetailWithTargetId:(NSString *)targetId lastId:(nullable NSString *)lastId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

//
+ (void)removeConversation:(NSString *)targetId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

//
+ (void)removeMessage:(NSString *)messageId targetId:(NSString *)targetId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

+ (void)readConversation:(NSString *)targetId success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

+ (void)sendMessageWithParameters:(NSDictionary *)parameters success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

//+ (void)sendTextMessageToUser:(NSString *)targetId content:(NSString *)content success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

+ (void)uploadMessage:(NSDictionary *)dic success:(void (^)(id response))success failure:(void (^)(NSError *err))failure;

//// 从网络拉取好友列表
//+ (void)getFriendsSuccess:(void (^)(id response))success failure:(void (^)(NSError *err))failure NS_UNAVAILABLE;
//
////获取好友列表 同上
//+ (void)getFriendListFromServerSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure NS_UNAVAILABLE;

//加入黑名单
+ (void)addToBlacklist:(NSString *)userId
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

//从黑名单中移除
+ (void)removeToBlacklist:(NSString *)userId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

//获取黑名单列表
+ (void)getBlacklistsuccess:(void (^)(id response))success failure:(void (^)(NSError *err))failure NS_UNAVAILABLE;

//更新当前用户名称
+ (void)updateName:(NSString *)userName success:(void (^)(id response))success failure:(void (^)(NSError *err))failure NS_UNAVAILABLE;

//获取版本信息
+ (void)getVersionsuccess:(void (^)(id response))success failure:(void (^)(NSError *err))failure NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
