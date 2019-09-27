//
//  INTCTNetWorkManager.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class INTCTRequest;
@class AFHTTPSessionManager;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - block
// 成功
typedef void(^INTCTNetSuccessBlock)(id _Nullable result);
// 失败
typedef void(^INTCTNetFailBlock)(BOOL netReachable, NSString * _Nullable msg, id _Nullable result);

typedef void(^HttpRequestFailBlock)(NSError * _Nullable error);


@interface INTCTNetWorkManager : NSObject

+ (BOOL)netReachable;

+ (void)intct_startMonitoringNet:(void(^_Nullable)(BOOL isSuccess))resultBlock;

+ (AFHTTPSessionManager *)intct_get:(NSString *)string
                     withParameters:(nullable NSDictionary *)parameters
                            success:(_Nullable INTCTNetSuccessBlock)succeess
                             failed:(_Nullable INTCTNetFailBlock)failed;

+ (AFHTTPSessionManager *)intct_post:(NSString *)string
                      withParameters:(nullable NSDictionary *)parameters
                             success:(_Nullable INTCTNetSuccessBlock)succeess
                              failed:(_Nullable INTCTNetFailBlock)failed;

+ (AFHTTPSessionManager *)intct_postManulCallback:(NSString *)string
                                   withParameters:(nullable NSDictionary *)parameters
                                          success:(_Nullable INTCTNetSuccessBlock)succeess
                                           failed:(_Nullable INTCTNetFailBlock)failed;

+ (void)intct_sendRequest:(NSMutableDictionary *)postData
                  reqData:(nullable NSDictionary *)reqData
                   method:(NSString *)method
             successBlock:(void (^)(BOOL isSuccess, id result))successBlock
             failureBlock:(_Nullable HttpRequestFailBlock)failureBlock;

+ (NSString *)intct_defaultUserAgentString:(BOOL)isBlockRequet;

//一般用这个
+ (NSString *)intct_urlStringSuffix:(BOOL)isBlockRequest;

//处理点击请求
+ (void)intct_conductRequest:(INTCTRequest *)request;

@end

NS_ASSUME_NONNULL_END
