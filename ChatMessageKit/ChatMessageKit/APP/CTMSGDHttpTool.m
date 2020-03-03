//
//  CTMSGDHttpTool.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/11.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGDHttpTool.h"
#import "CTMSGUserInfo.h"
#import "CTMSGDUserInfo.h"
#import "CTMSGDataBaseManager.h"
#import "CTMSGNetManager.h"
#import "CTMSGUserInfoManager.h"

@implementation CTMSGDHttpTool

+ (instancetype)shareInstance {
    static CTMSGDHttpTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super allocWithZone:NULL] init];
        [instance p_ctmsg_init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (void)p_ctmsg_init {
    //    _allFriends = [NSMutableArray new];
    //    _allChatHsitoryUsers = [NSMutableArray new];
}

- (void)getUserInfoByUserID:(NSString *)userID completion:(void (^)(CTMSGUserInfo *user))completion {
    CTMSGUserInfo *userInfo = [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userID];
    if (!userInfo) {
        [self getNewestUserInfoByUserID:userID completion:completion];
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(userInfo);
            });
        }
    }
}

//不管本地缓存直接拉取用户信息
- (void)getNewestUserInfoByUserID:(NSString *)userID completion:(void (^)(CTMSGUserInfo *user))completion {
    [CTMSGNetManager getUserInfo:userID
                         success:^(id response) {
                             if (response) {
                                 if ([response[@"ok"] intValue] == 1) {
                                     NSDictionary *dic = response[@"data"];
                                     CTMSGUserInfo *user = [CTMSGUserInfo new];
                                     user.userId = [NSString stringWithFormat:@"%@", dic[@"userid"]];
                                     user.name = [dic objectForKey:@"nickname"];
                                     user.portraitUri = [dic objectForKey:@"head_pic"];
                                     if (!user.portraitUri || user.portraitUri.length <= 0) {
                                         user.portraitUri = @"";
                                     }
                                     [[CTMSGDataBaseManager shareInstance] insertUserToDB:user];
                                     if (completion) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             completion(user);
                                         });
                                     }
                                     return ;
                                 }
                             }
                             CTMSGUserInfo *user = [CTMSGUserInfoManager generateDefaultUserInfo:userID];
                             if (completion) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completion(user);
                                 });
                             }
                         }
                         failure:^(NSError *err) {
                             NSLog(@"getUserInfoByUserID error");
                             if (completion) {
                                 CTMSGUserInfo *user = [CTMSGUserInfoManager generateDefaultUserInfo:userID];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completion(user);
                                 });
                             }
                         }];
}

- (void)addToBlacklist:(NSString *)userId complete:(void (^)(BOOL result))result {
    [CTMSGNetManager addToBlacklist:userId
                            success:^(id response) {
                                NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
                                if (result && [code isEqualToString:@"200"]) {
                                    result(YES);
                                } else if (result) {
                                    result(NO);
                                }
                            }
                            failure:^(NSError *err) {
                                if (result) {
                                    result(NO);
                                }
                            }];
}

- (void)removeToBlacklist:(NSString *)userId complete:(void (^)(BOOL result))result {
    [CTMSGNetManager removeToBlacklist:userId
                               success:^(id response) {
                                   NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
                                   if (result && [code isEqualToString:@"200"]) {
                                       result(YES);
                                   } else if (result) {
                                       result(NO);
                                   }
                               }
                               failure:^(NSError *err) {
                                   if (result) {
                                       result(NO);
                                   }
                               }];
}

- (void)getBlacklistcomplete:(void (^)(NSMutableArray *))blacklist {
//    [CTMSGNetManager getBlacklistsuccess:^(id  _Nonnull response) {
//        NSString *code = [NSString stringWithFormat:@"%@", response[@"code"]];
//        if (blacklist && [code isEqualToString:@"200"]) {
//            NSMutableArray *result = response[@"result"];
//            blacklist(result);
//        } else if (blacklist) {
//            blacklist(nil);
//        }
//    } failure:^(NSError * _Nonnull err) {
//        if (blacklist) {
//            blacklist(nil);
//        }
//    }];
}

- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(CTMSGDUserInfo *user))success
               failure:(void (^)(NSError *err))failure {
    [CTMSGNetManager getUserInfo:userID  success:^(id response) {
        if ([response[@"ok"] integerValue] == 1) {
            NSDictionary * infoDic = response[@"data"];
            CTMSGUserInfo *user = [CTMSGUserInfo new];
            user.userId = [NSString stringWithFormat:@"%@", infoDic[@"userid"]];
            user.name = [infoDic objectForKey:@"nickname"];
            NSString *portraitUri = [infoDic objectForKey:@"head_pic"];
            if (!portraitUri || portraitUri.length <= 0) {
                portraitUri = @"";
            }
            user.portraitUri = portraitUri;
            [[CTMSGDataBaseManager shareInstance] insertUserToDB:user];
            CTMSGUserInfo * result = [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userID];
            CTMSGDUserInfo *detail = [CTMSGDUserInfo new];
            detail.userId = result.userId;
            detail.name = result.name;
            detail.portraitUri = result.portraitUri;
            
            if (detail == nil) {
                detail = [[CTMSGDUserInfo alloc] init];
            }
            detail.name = [infoDic objectForKey:@"nickname"];
            detail.portraitUri = portraitUri;
            [[CTMSGDataBaseManager shareInstance] insertUserToDB:detail];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(detail);
                });
            }
        }
    } failure:^(NSError *err) {
        failure(err);
    }];
}

- (void)updateUserInfo:(CTMSGUserInfo *)userInfo {
    if (!userInfo) {
        return;
    }
    [[CTMSGDataBaseManager shareInstance] insertUserToDB:userInfo];
    CTMSGUserInfo *result = [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userInfo.userId];
    CTMSGDUserInfo *detail = [CTMSGDUserInfo new];
    detail.userId = result.userId;
    detail.name = result.name;
    detail.portraitUri = result.portraitUri;
    if (detail == nil) {
        detail = [[CTMSGDUserInfo alloc] init];
    }
    detail.name = userInfo.name;
    detail.portraitUri = userInfo.portraitUri;
    [[CTMSGDataBaseManager shareInstance] insertUserToDB:detail];
}

//- (void)getVersioncomplete:(void (^)(NSDictionary *))versionInfo {
//    [CTMSGNetManager getVersionsuccess:^(id response) {
//        if (response) {
//            NSDictionary *iOSResult = response[@"iOS"];
//            NSString *sealtalkBuild = iOSResult[@"build"];
//            NSString *applistURL = iOSResult[@"url"];
//
//            NSDictionary *result;
//            NSString *currentBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
//
//            NSDate *currentBuildDate = [self stringToDate:currentBuild];
//            NSDate *buildDtate = [self stringToDate:sealtalkBuild];
//            NSTimeInterval secondsInterval = [currentBuildDate timeIntervalSinceDate:buildDtate];
//            if (secondsInterval < 0) {
//                result =
//                [NSDictionary dictionaryWithObjectsAndKeys:@"YES", @"isNeedUpdate", applistURL, @"applist", nil];
//            } else {
//                result = [NSDictionary dictionaryWithObjectsAndKeys:@"NO", @"isNeedUpdate", nil];
//            }
//            versionInfo(result);
//        }
//    }
//                          failure:^(NSError *err) {
//                              versionInfo(nil);
//                          }];
//}


- (NSDate *)stringToDate:(NSString *)build {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSDate *date = [dateFormatter dateFromString:build];
    return date;
}

//获取用户详细资料
- (void)getUserDetailWithId:(NSString *)userId
                    success:(void (^)(CTMSGDUserInfo *user))success
                    failure:(void (^)(NSError *err))failure {
    [CTMSGNetManager getUserInfo:userId success:^(id response) {
        if ([response[@"ok"] integerValue] == 1) {
            NSDictionary *infoDic = response[@"data"];
            CTMSGUserInfo *user = [CTMSGUserInfo new];
            user.userId = [NSString stringWithFormat:@"%@", infoDic[@"userid"]];
            user.name = [infoDic objectForKey:@"nickname"];
            NSString *portraitUri = [infoDic objectForKey:@"head_pic"];
            if (!portraitUri || portraitUri.length <= 0) {
                portraitUri = @"";
            }
            user.portraitUri = portraitUri;
            [[CTMSGDataBaseManager shareInstance] insertUserToDB:user];
            
            CTMSGUserInfo * result = [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userId];
            CTMSGDUserInfo *detail = [CTMSGDUserInfo new];
            detail.userId = result.userId;
            detail.name = result.name;
            detail.portraitUri = result.portraitUri;
            if (detail == nil) {
                detail = [[CTMSGDUserInfo alloc] init];
            }
            detail.name = [infoDic objectForKey:@"nickname"];
            detail.portraitUri = portraitUri;
            [[CTMSGDataBaseManager shareInstance] insertUserToDB:detail];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(detail);
                });
            }
        }
    } failure:^(NSError *err) {
        failure(err);
    }];
}

@end
