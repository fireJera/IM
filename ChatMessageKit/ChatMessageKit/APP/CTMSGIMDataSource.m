//
//  CTMSGIMDataSource.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/11.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGIMDataSource.h"
#import "CTMSGUserInfo.h"
#import "CTMSGUserInfoManager.h"

@implementation CTMSGIMDataSource

+ (instancetype)shareInstance {
    static CTMSGIMDataSource *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static CTMSGIMDataSource *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

#pragma mark - CTMSGIMUserInfoDataSource

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(CTMSGUserInfo * _Nonnull))completion {
    CTMSGUserInfo *user = [CTMSGUserInfo new];
    if (userId == nil || [userId length] == 0) {
        user = [CTMSGUserInfoManager generateDefaultUserInfo:userId];
        completion(user);
        return;
    }
    
    [[CTMSGUserInfoManager shareInstance] getUserInfo:userId
                                         completion:^(CTMSGUserInfo *user) {
                                             [[CTMSGIM sharedCTMSGIM] refreshUserInfoCache:user withUserId:user.userId];
                                             completion(user);
                                         }];
    return;
}

@end
