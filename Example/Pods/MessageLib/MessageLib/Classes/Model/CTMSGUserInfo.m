//
//  CTMSGUser.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUserInfo.h"

@implementation CTMSGUserInfo

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait isVip:(BOOL)isVip {
    self = [super init];
    if (!self) return nil;
    _userId = userId;
    _name = username;
    _portraitUri = portrait;
    _isVip = isVip;
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait {
    return [self initWithUserId:userId name:userId portrait:portrait isVip:NO];
}

@end
