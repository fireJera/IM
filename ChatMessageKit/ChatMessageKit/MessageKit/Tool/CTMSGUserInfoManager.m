//
//  CTMSGUserInfoManager.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUserInfoManager.h"
#import "CTMSGUserInfo.h"
#import "CTMSGDUserInfo.h"
#import "CTMSGDHttpTool.h"
#import "CTMSGDataBaseManager.h"

@implementation CTMSGUserInfoManager

+ (instancetype)shareInstance {
    static CTMSGUserInfoManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

//通过自己的userId获取自己的用户信息
- (void)getUserInfo:(NSString *)userId completion:(void (^)(CTMSGUserInfo *))completion {
    [CTMSGGHTTPTOOL getUserInfoByUserID:userId completion:^(CTMSGUserInfo * _Nonnull user) {
        if (user) {
            completion(user);
            return;
        } else {
            user = [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userId];
            if (user == nil) {
                user = [CTMSGUserInfo new];
                user.userId = userId;
                completion(user);
                return;
            }
        }
    }];
}

//设置默认的用户信息
+ (CTMSGUserInfo *)generateDefaultUserInfo:(NSString *)userId {
    CTMSGUserInfo *defaultUserInfo = [CTMSGUserInfo new];
    defaultUserInfo.userId = userId;
    defaultUserInfo.name = [NSString stringWithFormat:@"name%@", userId];
    defaultUserInfo.portraitUri = @"";
    return defaultUserInfo;
}

//- (NSArray *)getConversationList:(NSArray *)conversationList {
//    NSMutableArray *resultList = [NSMutableArray new];
//    //    for (CTMSGUserInfo *user in friendList) {
//    //        CTMSGUserInfo *friend = [self getFriendInfoFromDB:user.userId];
//    //        if (friend != nil) {
//    //            [resultList addObject:friend];
//    //        } else {
//    //            [resultList addObject:user];
//    //        }
//    //    }
//    NSArray *result = [[NSArray alloc] initWithArray:resultList];
//    return result;
//}

//- (CTMSGUserInfo *)getUserInfoFromDB:(NSString *)userId {
////    CTMSGUserInfo *resultInfo;
//    CTMSGUserInfo *user = [[CTMSGDataBaseManager shareInstance] searchUserInfoWithID:userId];
////    if (friend != nil) {
////        resultInfo = [self getRCUserInfoByRCDUserInfo:friend];
////        return resultInfo;
////    }
//    return user;
//}

////通过CTMSGDUserInfo对象获取CTMSGUserInfo对象
//- (CTMSGUserInfo *)getRCUserInfoByRCDUserInfo:(CTMSGDUserInfo *)dUser {
//    CTMSGUserInfo *user = [CTMSGUserInfo new];
//    user.userId = dUser.userId;
//    user.name = dUser.name;
//    user.portraitUri = dUser.portraitUri;
//    return user;
//}

@end
