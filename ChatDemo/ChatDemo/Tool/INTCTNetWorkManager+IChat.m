//
//  INTCTNetWorkManager+IChat.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTNetWorkManager+IChat.h"
#import <AdSupport/AdSupport.h>
#import "INTCTConversationListViewmodel.h"
#import "INTCTUser.h"
#import "NSString+INTCT_Custom.h"
#import "NSObject+INTCT_YYModel.h"
#import "INTCTKeyChain.h"
//#import "INTCTMyViewmodel.h"
//#import "INTCTHomeMatch.h"
//#import "INTCTUserHomeModel.h"
//#import "INTCTAccountModel.h"
////#import "INTCTMemberModel.h"
//#import "INTCTVisitorModel.h"
//#import "INTCTMyModel.h"
//#import "INTCTAppData.h"
//#import "INTCTCacheManager.h"
//#import "INTCTInfoEditModel.h"
//#import "INTCTSchoolEditModel.h"
#import "INTCTConversationListModel.h"
#import "INTCTConversationModel.h"
//#import "INTCTDiscoveryModel.h"
////#import "INTCTHomeBgImage.h"
//#import "INTCTSystemModel.h"
//#import "INTCTShanYanModel.h"
//#import "INTCTHUDPopHelper.h"
//#import <YYCache/YYCache.h>
#import <MMessageKit/CTMSGIM.h>
#import <YYModel/YYModel.h>
#import "Header.h"
//#import "INTCTBannerModel.h"

static NSString * const kWechatLogin = @"weixin/login";

//NSString * const INTCTMineInfoChangeNotification = @"INTCTMineInfoChangeNotification";
NSString * const INTCTUserHomeInfoChangeNotification = @"INTCTUserHomeInfoChangeNotification";
NSString * const INTCTVideoAuthChangeNotification = @"INTCTVideoAuthChangeNotification";

@implementation INTCTNetWorkManager (IChat)

+ (void)intct_revoke:(void (^)(BOOL))resultBlock {
    static NSString * const kRevokeUrl = @"revoke/index";
    NSString * uid = INTCTINSTANCE_USER.uid;
    NSString * version = INTCTMajorVersion;
    NSString * IDFAStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    NSDictionary * parameters = @{
                                  @"userid": uid,
                                  @"version_id": version,
                                  @"idfa": IDFAStr,
                                  };
    [self intct_post:kRevokeUrl withParameters:parameters success:^(id  _Nullable result) {
        [INTCTINSTANCE_USER yy_modelSetWithJSON:result[@"data"]];
//        [INTCTINSTANCE_APP yy_modelSetWithJSON:result[@"data"]];
//        INTCTINSTANCE_APP.showMatchNote = INTCTINSTANCE_APP.preRelease;
        INTCTInstanceChatList_VM.totalUnread = [result[@"data"][@"unreadInfo"][@"chatList"] integerValue] + [result[@"data"][@"unreadInfo"][@"unread_notice"] integerValue];
//        INTCTMyViewmodel.visitorCount = [result[@"data"][@"unreadInfo"][@"visit"] integerValue];
//        INTCTMyViewmodel.followCount = [result[@"data"][@"unreadInfo"][@"follow"] integerValue];
//        INTCTMyViewmodel.badgeCount = [result[@"data"][@"unreadInfo"][@"homeMy"] integerValue];
        int loginStaus = [result[@"data"][@"loginStatus"] intValue];
        if (resultBlock) {
            resultBlock(loginStaus == 1 ? NO : YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(YES);
        }
    }];
}

+ (void)intct_chatToken:(void (^)(id _Nullable))resultBlock {
    NSString * tokenUrl = @"immsg/token";
    NSString * userId = INTCTINSTANCE_USER.uid;
    NSDictionary * dic;
    if (userId) {
        dic = @{@"userid": userId};
    }
    [self intct_post:tokenUrl withParameters:dic success:^(id  _Nullable result) {
        NSDictionary * dic = result[@"data"];
        if (resultBlock) {
            resultBlock(dic);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    }];
}

+ (void)intct_pushToken:(NSString *)token result:(void (^)(BOOL))resultBlock {
    if (!IsStringLengthGreaterThanZero(token)) return;
    static NSString * const kRevokeUrl = @"home/save_push_token";
    NSDictionary * parameters = @{
                                  @"device_token": token,
                                  };
    [self intct_post:kRevokeUrl withParameters:parameters success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_wechatLogin:(void (^)(BOOL))resultBlock {
    NSString * version = INTCTMajorVersion;
    NSString * IDFAString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSDictionary * parameters = @{
                                  @"refresh_token"  : INTCTINSTANCE_USER.wechatRefreshToken,
                                  @"device_id"      : [INTCTKeyChain UUId],
                                  @"version_id"     : version,
                                  @"idfa"           : IDFAString,
                                  };
    
    [self intct_post:kWechatLogin withParameters:parameters success:^(id  _Nullable result) {
        [INTCTINSTANCE_USER yy_modelSetWithJSON:result[@"data"]];
//        [INTCTINSTANCE_APP yy_modelSetWithJSON:result[@"data"]];
        INTCTInstanceChatList_VM.totalUnread = [result[@"data"][@"unreadInfo"][@"chatList"] integerValue] + [result[@"data"][@"unreadInfo"][@"unread_notice"] integerValue];
//        INTCTMyViewmodel.visitorCount = [result[@"data"][@"unreadInfo"][@"visit"] integerValue];
//        INTCTMyViewmodel.followCount = [result[@"data"][@"unreadInfo"][@"follow"] integerValue];
//        INTCTMyViewmodel.badgeCount = [result[@"data"][@"unreadInfo"][@"homeMy"] integerValue];
        int loginResult = [result[@"ok"] intValue];
        if (resultBlock) {
            resultBlock(loginResult == 1 ? YES : NO);
        }
        //        if (loginResult) {
        //            [INTCTOpenPageHelper enterApp];
        //        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_wechatCodeLogin:(NSString *)code result:(void (^)(BOOL))resultBlock {
    NSString * version = INTCTMajorVersion;
    NSString * IDFAString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSDictionary * parameters = @{
                                  @"code"       : code,
                                  @"device_id"  : [INTCTKeyChain UUId],
                                  @"version_id" : version,
                                  @"idfa"       : IDFAString,
                                  };
    
    [self intct_post:kWechatLogin withParameters:parameters success:^(id  _Nullable result) {
        [INTCTINSTANCE_USER yy_modelSetWithJSON:result[@"data"]];
//        [INTCTINSTANCE_APP yy_modelSetWithJSON:result[@"data"]];
        INTCTInstanceChatList_VM.totalUnread = [result[@"data"][@"unreadInfo"][@"chatList"] integerValue] + [result[@"data"][@"unreadInfo"][@"unread_notice"] integerValue];
//        INTCTMyViewmodel.visitorCount = [result[@"data"][@"unreadInfo"][@"visit"] integerValue];
//        INTCTMyViewmodel.followCount = [result[@"data"][@"unreadInfo"][@"follow"] integerValue];
//        INTCTMyViewmodel.badgeCount = [result[@"data"][@"unreadInfo"][@"homeMy"] integerValue];
        int loginResult = [result[@"ok"] intValue];
        if (resultBlock) {
            resultBlock(loginResult == 1 ? YES : NO);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_phoneLogin:(NSString *)phoneNum pass:(NSString *)pass result:(void (^)(BOOL))resultBlock {
    if (!phoneNum || !pass) return;
    NSString * loginUrl = @"mobile/login";
    NSDictionary * parameters = @{
                                  @"username": phoneNum,
                                  @"password": pass,
                                  };
    
    [self intct_post:loginUrl withParameters:parameters success:^(id  _Nullable result) {
        //        NSDictionary *badgeDic = result[@"data"][@"unreadInfo"];
        //        [INTCTINSTANCE_Chat yy_modelSetWithDictionary:badgeDic];
        [INTCTINSTANCE_USER yy_modelSetWithJSON:result[@"data"]];
        INTCTInstanceChatList_VM.totalUnread = [result[@"data"][@"unreadInfo"][@"chatList"] integerValue] + [result[@"data"][@"unreadInfo"][@"unread_notice"] integerValue];
//        INTCTMyViewmodel.visitorCount = [result[@"data"][@"unreadInfo"][@"visit"] integerValue];
//        INTCTMyViewmodel.followCount = [result[@"data"][@"unreadInfo"][@"follow"] integerValue];
//        INTCTMyViewmodel.badgeCount = [result[@"data"][@"unreadInfo"][@"homeMy"] integerValue];
        if (resultBlock) {
            resultBlock(YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_getSmsCode:(NSString *)phoneNum result:(void (^)(BOOL))resultBlock {
    if (!IsStringLengthGreaterThanZero(phoneNum)) return;
    NSString * loginUrl = @"mobile/send-code";
    NSDictionary * parameters = @{
                                  @"mobile": phoneNum,
                                  };
    
    [self intct_post:loginUrl withParameters:parameters success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_phoneRegister:(NSString *)phoneNum
                 verifyCode:(NSString *)code
                       pass:(NSString *)pass
                   nickname:(NSString *)nickname
                        sex:(NSInteger)sex
                     result:(void (^)(BOOL))resultBlock {
    if (!(IsStringLengthGreaterThanZero(phoneNum) &&
          IsStringLengthGreaterThanZero(code) &&
          IsStringLengthGreaterThanZero(pass) &&
          IsStringLengthGreaterThanZero(nickname))) return;
    
    NSString * loginUrl = @"mobile/register";
    NSDictionary * parameters = @{
                                  @"mobile"     :phoneNum,
                                  @"vcode"      :code,
                                  @"password"   :pass,
                                  @"nickname"   :nickname,
                                  @"sex"        :@(sex),
                                  };
    
    [self intct_post:loginUrl withParameters:parameters success:^(id  _Nullable result) {
        //        [INTCTINSTANCE_USER yy_modelSetWithJSON:result[@"data"]];
        if (resultBlock) {
            resultBlock(YES);
        }
//        [INTCTOpenPageHelper enterApp:nil];
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_logout:(void (^)(BOOL))resultBlock {
    NSString * logoutUrl = @"logout/index";
    NSDictionary * parameters = @{
                                  //                                  @"mobile": phoneNum,
                                  };
    
    [self intct_post:logoutUrl withParameters:parameters success:^(id  _Nullable result) {
        [INTCTINSTANCE_USER intct_signOut];
        [[CTMSGIM sharedCTMSGIM] logout];
        INTCTInstanceChatList_VM.totalUnread = 0;
//        INTCTMyViewmodel.visitorCount = 0;
//        INTCTMyViewmodel.followCount = 0;
//        INTCTMyViewmodel.badgeCount = 0;
        
//        [INTCTOpenPageHelper openLogin];
        
//        INTCTAliLog.userid = nil;
//        INTCTAliLog.uaInfo = [INTCTNetWorkManager intct_urlStringSuffix:NO];
        if (resultBlock) {
            resultBlock(YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
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
            if (successBlock) {
                NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                successBlock(YES, str);
            }
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }] resume];
}

+ (void)intct_signUpTransition:(void (^)(NSError * _Nullable))resultBlock {
    NSString * const signURL = @"register/transition";
    [self intct_post:signURL withParameters:nil success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

+ (void)intct_signUpVideoWithSkip:(BOOL)isSkip result:(void (^)(NSError * _Nullable))resultBlock {
    NSString * const signURL = @"register/video";
    
    NSDictionary * parameters;
    if (isSkip) {
        parameters = @{
                       @"type": @"skip",
                       };
    } else {
        parameters = @{
                       @"type": @"takePhoto",
                       };
    }
    [self intct_post:signURL withParameters:parameters success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

+ (void)intct_playVideo:(NSString *)targetId result:(void (^)(NSError * _Nullable))resultBlock {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSString * playUrl = @"user/play-video";
    NSDictionary * parameters = @{
                                  @"userid": targetId,
                                  };
    
    [self intct_post:playUrl withParameters:parameters success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

+ (void)intct_shanYanUser:(void (^)(NSError * _Nullable, NSArray<INTCTShanYanUser *> * _Nullable, NSString * _Nullable))resultBlock {
    NSString * URL = @"register/near-register";
    [self intct_post:URL withParameters:nil success:^(id  _Nullable result) {
        NSArray * users = [NSObject arrayWithClass:@"INTCTShanYanUser" array:result[@"data"][@"userList"]];
        NSString * title = result[@"data"][@"title"];
        if (resultBlock) {
            resultBlock(nil, users, title);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil, nil);
        }
    }];
}

#pragma mark - home
+ (void)intct_matchInfo:(void (^)(NSError * _Nullable, INTCTHomeMatch * _Nullable))resultBlock {
    NSString * homeUrl = @"fastChat/index";
    [self intct_get:homeUrl withParameters:nil success:^(id  _Nullable result) {
//        INTCTHomeMatch * match = [INTCTHomeMatch yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(nil, match);
//        }
//        YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//        NSString * key = @"appmatchcache";
//        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
//        [cache setObject:data forKey:key];
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
            NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
            INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
            NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
            resultBlock(error, nil);
        }
    }];
}

+ (void)intct_timeMatch:(void (^)(NSError * _Nullable))resultBlock {
    NSString * homeUrl = @"fastChat/mate-user";
    [self intct_post:homeUrl withParameters:nil success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
            NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
            INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
            NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
            resultBlock(error);
        }
    }];
}

+ (void)intct_cancelMatch:(void (^)(NSError * _Nullable))resultBlock {
    NSString * homeUrl = @"fastChat/out-mate";
    [self intct_post:homeUrl withParameters:nil success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
            NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
            INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
            NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
            resultBlock(error);
        }
    }];
}

+ (void)intct_exitMatchConversationWithUserId:(NSString *)userId result:(void (^)(NSError * _Nullable))resultBlock {
    NSParameterAssert(userId);
    if (!userId) return;
    NSDictionary * params = @{
                              @"userid": userId,
                              };
    NSString * homeUrl = @"fastChat/out-chat";
    [self intct_post:homeUrl withParameters:params success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
            NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
            INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
            NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
            resultBlock(error);
        }
    }];
}

#pragma mark - discovery

+ (void)intct_discoveryWithPage:(NSUInteger)page result:(void (^)(NSError * _Nullable, INTCTDiscoveryModel * _Nullable))resultBlock {
//    NSString * const chatListURL = @"online/home";
//    NSDictionary * params = @{
//                              @"page": @(page)
//                              };
//    [self intct_post:chatListURL withParameters:params success:^(id  _Nullable result) {
//        INTCTDiscoveryModel * discovery = [INTCTDiscoveryModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(nil, discovery);
//        }
//        if (page == 0) {
//            YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//            NSString * key = @"appuserlistcache";
//            NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
//            [cache setObject:data forKey:key];
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
//        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
//        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
//        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
//        if (resultBlock) {
//            resultBlock(error, nil);
//        }
//    }];
}

+ (void)intct_bannerInfo:(void (^)(NSError * _Nullable, INTCTBannerModel * _Nullable))resultBlock {
    NSString * const adURL = @"ad/list";
//    [self intct_get:adURL withParameters:@{@"type": @"banner"} success:^(id  _Nullable result) {
//        INTCTBannerModel * banner = [INTCTBannerModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(nil, banner);
//        }
//        YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//        NSString * key = @"appuserlistbannercache";
//        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
//        [cache setObject:data forKey:key];
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
//        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
//        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
//        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
//        if (resultBlock) {
//            resultBlock(error, nil);
//        }
//    }];
}

#pragma mark - chat

+ (void)intct_chatListWithLastId:(NSString *)lastId result:(nonnull void (^)(NSError * _Nullable, INTCTConversationListModel * _Nullable))resultBlock {
    NSString * const chatListURL = @"immsg/list";
    NSDictionary * params;
    if (lastId) {
        params = @{
                   @"last_id": lastId
                   };
    }
    [self intct_get:chatListURL withParameters:params success:^(id  _Nullable result) {
        INTCTConversationListModel * chatData = [INTCTConversationListModel yy_modelWithJSON:result[@"data"]];
        if (resultBlock) {
            resultBlock(nil, chatData);
        }
//        if (!lastId) {
//            YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//            NSString * key = @"chatListCache";
//            NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
//            [cache setObject:data forKey:key];
//        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil);
        }
    }];
}

+ (void)intct_matchFollow:(nullable NSString *)userid
                   result:(void (^ _Nullable)(NSError * _Nullable error, BOOL followed))resultBlock {
    NSParameterAssert(userid);
    if (!userid) return;
    NSDictionary * params = @{
                              @"userid": userid,
                              };
    NSString * const chatURL = @"fastChat/like";
    [self intct_post:chatURL withParameters:params success:^(id  _Nullable result) {
        BOOL favored = result[@"data"][@"faovred"];
        if (resultBlock) {
            resultBlock(nil, favored);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, NO);
        }
    }];
}

+ (void)intct_chatDetailWithTargetId:(NSString *)targetId
                              lastId:(NSString *)lastId
                             isMatch:(BOOL)isMatch
                              result:(void (^)(NSError * _Nullable, INTCTConversationModel * _Nullable))resultBlock {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSMutableDictionary * params = [@{
                                      @"to_userid": targetId,
                                      } mutableCopy];
    if (lastId) {
        [params setValue:lastId forKey:@"last_id"];
    }
    if (isMatch) {
        [params setValue:@"fastChat" forKey:@"chatType"];
    }
    NSString * const chatURL = @"immsg/detail";
    [self intct_get:chatURL withParameters:params success:^(id  _Nullable result) {
        INTCTConversationModel * chatData = [INTCTConversationModel yy_modelWithJSON:result[@"data"]];
        if (resultBlock) {
            resultBlock(nil, chatData);
        }
        //        if (!lastId) {
        //            YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
        //            NSString * key = [NSString stringWithFormat:@"chat_detail_%@", targetId] ;
        //            NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
        //            [cache setObject:data forKey:key];
        //        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil);
        }
    }];
}

+ (void)intct_msgUnlock:(NSString *)targetId result:(nonnull void (^)(NSError * _Nullable, NSDictionary * _Nullable))resultBlock {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSDictionary * params = @{
                              @"to_userid": targetId,
                              };
    NSString * const chatURL = @"immsg/unlock";
    [self intct_post:chatURL withParameters:params success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil, result);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil);
        }
    }];
}

+ (void)readMessageInChatDetail:(NSString *)targetId result:(nonnull void (^)(NSError * _Nullable))resultBlock {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSDictionary * params = @{
                              @"userid": targetId,
                              };
    NSString * const chatURL = @"immsg/read-index";
    [self intct_post:chatURL withParameters:params success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

+ (void)deleteMessageWithTargetId:(NSString *)targetId msgUid:(NSString *)msgUid result:(void (^)(NSError * _Nullable))resultBlock {
    NSParameterAssert(msgUid && targetId);
    if (!msgUid || !targetId) return;
    NSDictionary * params = @{
                              @"to_userid": targetId,
                              @"msg_id": msgUid,
                              };
    NSString * const chatURL = @"immsg/del-detail";
    [self intct_post:chatURL withParameters:params success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

+ (void)intct_removeConversationWithTargetId:(NSString *)targetId result:(void (^)(NSError * _Nullable))resultBlock {
    NSParameterAssert(targetId);
    if (!targetId) return;
    NSDictionary * params = @{
                              @"to_userid": targetId,
                              };
    NSString * const chatURL = @"immsg/del-index";
    [self intct_post:chatURL withParameters:params success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

#pragma mark - 个人中心

+ (void)intct_myCenter:(void (^)(BOOL, INTCTMyModel * _Nullable))resultBlock {
//    NSString * myCenter = @"home/my";
//    [self intct_post:myCenter withParameters:nil success:^(id  _Nullable result) {
//        INTCTMyModel * my = [INTCTMyModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(YES, my);
//        }
//        YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//        NSString * key = @"INTCTMyInfo";
//        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
//        [cache setObject:data forKey:key];
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO, nil);
//        }
//    }];
}

+ (void)intct_chatHelloToUserId:(NSString *)userId result:(void (^)(BOOL))resultBlock {
    if (!userId) return;
    NSString * helloURL = @"immsg/hi";
    NSDictionary * dic = @{@"userid": userId};
    [self intct_post:helloURL withParameters:dic success:^(id  _Nullable result) {
        NSArray * strings = result[@"data"][@"list"];
//        [INTCTHUDPopHelper showHelloViewWithStrings:strings];
        if (resultBlock) {
            resultBlock(YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_myHomeInfo:(NSString *)userid result:(void (^ _Nullable)(BOOL, INTCTUserHomeModel * _Nullable))resultBlock {
    if (!IsStringLengthGreaterThanZero(userid)) {
        userid = INTCTINSTANCE_USER.uid;
    }
    NSString * myInfo = @"home/homepage";
    NSDictionary * parameters = @{
                                  @"to_userid": userid,
                                  };
    
//    [self intct_post:myInfo withParameters:parameters success:^(id  _Nullable result) {
//        INTCTUserHomeModel * model = [INTCTUserHomeModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(YES, model);
//        }
//        YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//        NSString * key = [NSString stringWithFormat:@"userHomeCache_%@", userid];
//        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:kNilOptions error:nil];
//        [cache setObject:data forKey:key];
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO, nil);
//        }
//    }];
}

//+ (void)intct_follow:(NSString *)userid result:(void (^ _Nullable)(NSError * _Nullable, NSUInteger))resultBlock {
//    NSParameterAssert(userid);
//    if (!userid) return;
//    NSString * const myInfo = @"follow/follow";
//    NSDictionary * parameters = @{
//                                  @"to_userid" : userid,
//                                  };
//
//    [self intct_post:myInfo withParameters:parameters success:^(id  _Nullable result) {
//        NSUInteger follow = [result[@"data"][@"followStatus"] integerValue];
//        if (resultBlock) {
//            resultBlock(nil, follow);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            NSString * domain = @"com.banteaySrei.INTCTNetWorkManager.netError";
//            NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
//            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
//            INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
//            NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
//            resultBlock(error, YES);
//        }
//    }];
//}

//+ (void)intct_invite:(NSString *)userid invitype:(INTCTInviteType)inviteType result:(void (^ _Nullable)(NSError * _Nullable))resultBlock {
//    NSParameterAssert(userid);
//    if (!userid) return;
//    NSString * type;
//    switch (inviteType) {
//        case INTCTInviteTypeWechat:
//            type = @"weixin";
//            break;
//        case INTCTInviteTypeAlbum:
//            type = @"album";
//            break;
//        case INTCTInviteTypeAvatar:
//            type = @"avatar";
//            break;
//        case INTCTInviteTypeVideoAuth:
//            type = @"videoAuth";
//            break;
//        case INTCTInviteTypeNone:
//            type = @"";
//            break;
//    }
//    NSString * const myInfo = @"invite/invite";
//    NSDictionary * parameters = @{
//                                  @"userid" : userid,
//                                  @"type"   : type,
//                                  };
//
//    [self intct_post:myInfo withParameters:parameters success:^(id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(nil);
//        }
////        [INTCTHUDPopHelper showTextHUD:@"邀请成功"];
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            NSString * domain = @"com.banteaySrei.INTCTNetWorkManager.netError";
//            NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
//            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
//            INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
//            NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
//            resultBlock(error);
//        }
//    }];
//}

//+ (void)intct_myInfoEditWithParameters:(NSDictionary *)dic result:(void (^)(BOOL))resultBlock {
//    NSString * editUrl = @"home/edit";
////    [self intct_post:editUrl withParameters:dic success:^(id  _Nullable result) {
////        if (resultBlock) {
////            resultBlock(YES);
////        }
////        [[INTCTControllerFinder rootControlerInWindow].view showTextHUD:@"提交成功！"];
////    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
////        if (resultBlock) {
////            resultBlock(NO);
////        }
////    }];
//}

+ (void)intct_myEditInfo:(void (^)(BOOL, INTCTInfoEditModel * _Nullable))resultBlock {
    NSString * infoUrl = @"home/editpage";
//    [self intct_post:infoUrl withParameters:nil success:^(id  _Nullable result) {
//        INTCTInfoEditModel * model = [INTCTInfoEditModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(YES, model);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO, nil);
//        }
//    }];
}

+ (void)intct_myAccount:(void (^)(BOOL, INTCTAccountModel * _Nullable))resultBlock {
    NSString * accountUrl = @"user/account";
    NSDictionary * parameters = @{
                                  //                                  @"mobile": phoneNum,
                                  };
    
//    [self intct_get:accountUrl withParameters:parameters success:^(id  _Nullable result) {
//        INTCTAccountModel * model = [INTCTAccountModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(YES, model);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO, nil);
//        }
//    }];
}

+ (void)intct_myWechatInfo:(void (^)(BOOL, NSDictionary * _Nullable))resultBlock {
    NSString * wechatURL = @"home/edit-weixin";
    
    [self intct_get:wechatURL withParameters:nil success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(YES, result[@"data"]);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO, nil);
        }
    }];
}

+ (void)intct_myVideoAuthInfo:(void (^)(BOOL, NSDictionary * _Nullable))resultBlock {
    NSString * wechatURL = @"home/edit-video";
    [self intct_get:wechatURL withParameters:nil success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(YES, result[@"data"]);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO, nil);
        }
    }];
}

+ (void)intct_blackWithUserId:(NSString *)userId result:(void (^)(NSError * _Nullable, NSDictionary * _Nullable))resultBlock {
    NSParameterAssert(userId);
    if (!userId) {
        return;
    }
    NSString * blackURL = @"user/blackUser";
    NSDictionary * parameters = @{@"to_userid": userId};
    [self intct_post:blackURL withParameters:parameters success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil, result[@"data"]);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil);
        }
    }];
}

+ (void)intct_delPhotoWithPhotoId:(NSString *)photoId result:(void (^)(NSError * _Nullable, NSDictionary * _Nonnull))resultBlock {
    if (!IsStringLengthGreaterThanZero(photoId)) return;
    NSString * const delURL = @"home/del-photo";
    [self intct_post:delURL withParameters:@{@"photo_id": photoId} success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil, result[@"data"]);
        }
//        [INTCTHUDPopHelper showTextHUD:@"删除成功"];
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, result);
        }
        if (!msg) {
            msg = @"删除失败";
        }
//        [INTCTHUDPopHelper showTextHUD:msg];
    }];
}

+ (void)intct_visitorListWithURL:(NSString *)URL
                          lastId:(NSString *)lastId
                          result:(void (^)(BOOL, INTCTVisitorModel * _Nullable))resultBlock {
    if (!URL) return;
    NSString * visitUrl = @"visit/in";
    visitUrl = URL;
    NSDictionary * parameters;
    if (lastId) {
        parameters = @{
                       @"last_id": lastId,
                       };
    }
    
//    [self intct_post:visitUrl withParameters:parameters success:^(id  _Nullable result) {
//        INTCTVisitorModel * model = [INTCTVisitorModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(YES, model);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO, nil);
//        }
//    }];
}

//+ (void)intct_accountVipInfo:(void (^)(BOOL, INTCTMemberModel * _Nullable))resultBlock {
//    NSString * vipInfoUrl = @"account/vip";
//    NSDictionary * parameters = @{
//                                  //                                  @"mobile": phoneNum,
//                                  };
//    
//    [self intct_get:vipInfoUrl withParameters:parameters success:^(id  _Nullable result) {
//        INTCTMemberModel * member = [INTCTMemberModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(YES, member);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO, nil);
//        }
//    }];
//}

//+ (void)intct_myHomeBgList:(NSString *)lastId :(void (^)(NSError * _Nullable, INTCTHomeBgImage * _Nullable))resultBlock {
//    NSString * const URL = @"home/bgimg-list";
//    NSDictionary * parameters;
//    if (lastId) {
//        parameters = @{
//                       @"last_id": lastId,
//                       };
//    }
//    [self intct_get:URL withParameters:parameters success:^(id  _Nullable result) {
//        INTCTHomeBgImage * images = [INTCTHomeBgImage yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(nil, images);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(error, nil);
//        }
//    }];
//}

+ (void)intct_iapOrderInfo:(NSString *)productId
                      type:(NSInteger)type
                    result:(void (^ _Nullable)(NSError * _Nullable, NSString * _Nullable, NSString * _Nullable))resultBlock {
    if (!IsStringLengthGreaterThanZero(productId)) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = @"无效的productid";
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type =INTCTNetRequestErrorTypeRequestFail;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil, nil);
        }
        return;
    }
    NSString * iapUrl = @"apple/place-order";
    NSString * typeStr = type == 1 ? @"gold" : @"vip";
    NSDictionary * parameters = @{
                                  @"buy_id": productId,
                                  @"buy_type": typeStr,
                                  };
    
    [self intct_post:iapUrl withParameters:parameters success:^(id  _Nullable result) {
        NSString * productId = result[@"data"][@"productId"];
        NSString * orderId = SAFESTRING(result[@"data"][@"orderId"]);
        if (resultBlock) {
            resultBlock(nil, productId, orderId);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error, nil, nil);
        }
    }];
}

+ (void)intct_iapReceiptOrderId:(NSString *)orderId
                        receipt:(NSString *)receipt
                  transactionId:(NSString *)transactionId
                         result:(void (^)(BOOL))resultBlock {
    if (!(IsStringLengthGreaterThanZero(orderId) &&
          IsStringLengthGreaterThanZero(receipt) &&
          IsStringLengthGreaterThanZero(transactionId))) {
        if (resultBlock) {
            resultBlock(NO);
        }
    };
    NSString * receitUrl = @"apple/verify-receipt";
    NSDictionary * parameters = @{
                                  @"order_id": orderId,
                                  @"receipt": receipt,
                                  @"transaction_id": transactionId,
                                  };
    
    [self intct_post:receitUrl withParameters:parameters success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(YES);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        if (resultBlock) {
            resultBlock(NO);
        }
    }];
}

+ (void)intct_notificationList:(NSString *)lastId result:(void (^ _Nullable)(NSError * _Nullable, INTCTSystemModel * _Nullable))resultBlock {
    NSString * listUrl = @"notification/list";
    NSDictionary * parameters;
    if (lastId) {
        parameters = @{
                       @"last_id": lastId,
                       };
    }
//    [self intct_post:listUrl withParameters:parameters success:^(id  _Nullable result) {
//        INTCTSystemModel * sysModel = [INTCTSystemModel yy_modelWithJSON:result[@"data"]];
//        if (resultBlock) {
//            resultBlock(nil, sysModel);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
//        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
//        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
//        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
//        if (resultBlock) {
//            resultBlock(error, nil);
//        }
//    }];
}

//+ (void)intct_removeNotificatin:(NSString *)notifyId result:(void (^)(BOOL))resultBlock {
//    if (!IsStringLengthGreaterThanZero(notifyId)) return;
//    NSString * removeUrl = @"notification/delete";
//    NSDictionary * parameters = @{
//                                  @"notification_id": notifyId,
//                                  };
//
//    [self intct_post:removeUrl withParameters:parameters success:^(id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(YES);
//        }
//    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
//        if (resultBlock) {
//            resultBlock(NO);
//        }
//    }];
//}
//
+ (void)intct_clearNotification:(void (^)(NSError * _Nullable))resultBlock {
    NSString * clearUrl = @"notification/empty";
    
    [self intct_post:clearUrl withParameters:nil success:^(id  _Nullable result) {
        if (resultBlock) {
            resultBlock(nil);
        }
    } failed:^(BOOL netReachable, NSString * _Nullable msg, id  _Nullable result) {
        NSString * domain = @"com.interstChat.INTCTNetWorkManager.netError";
        NSString * desc = msg ? msg : INTCTNetWorkErrorNoteString;
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : desc};
        INTCTNetRequestErrorType type = netReachable ? INTCTNetRequestErrorTypeRequestFail : INTCTNetRequestErrorTypeNetDisable;
        NSError * error = [NSError errorWithDomain:domain code:type userInfo:userInfo];
        if (resultBlock) {
            resultBlock(error);
        }
    }];
}

#pragma mark - info edit

+ (void)netLogout {
    [INTCTINSTANCE_USER intct_signOut];
    [[CTMSGIM sharedCTMSGIM] logout];
    INTCTInstanceChatList_VM.totalUnread = 0;
//    INTCTMyViewmodel.visitorCount = 0;
//    INTCTMyViewmodel.followCount = 0;
//    INTCTMyViewmodel.badgeCount = 0;
}

@end
