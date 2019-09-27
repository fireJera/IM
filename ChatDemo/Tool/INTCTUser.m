//
//  INTCTUser.m
//  LetDate
//
//  Created by Jeremy on 2019/1/19.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "INTCTUser.h"
//#import "INTCTApiCache.h

@implementation INTCTUser

@dynamic uid;
@dynamic token;
@dynamic nickname;
@dynamic avatar;
@dynamic wechatRefreshToken;
@dynamic showMatchNote;
//@dynamic fillInfoStep;

@dynamic marriageId;
@dynamic houseId;
@dynamic childId;
@dynamic provinceId;
@dynamic cityId;
@dynamic jobId;
@dynamic educationId;
@dynamic incomeId;
@dynamic travelIds;
@dynamic loveId;
@dynamic birthday;
@dynamic height;
@dynamic weight;
@dynamic heightRange;
@dynamic ageRange;
@dynamic figureId;
@dynamic bodyId;
@dynamic aimIncomeId;
@dynamic aimEducationId;
@dynamic declaration;

static INTCTUser *_user = nil;
static INTCTUser * _standardUser = nil;

#pragma mark - singleton
+ (instancetype )currentUser {
    @synchronized (self) {
        if (_user == nil) {
            NSAssert([self standardUser] != nil, @"current use == nil can't use");
            _user = [[INTCTUser alloc] init];
        }
    }
    return _user;
}

+ (instancetype)standardUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _standardUser = [[INTCTUser alloc] init];
    });
    return _standardUser;
}

#pragma mark - override
- (NSDictionary *)setupDefaults{
    return  @{
              @"uid"            : @"",
              @"token"          : @"",
//              @"fillInfoStep"   : @0,
              };
}

- (NSString *)suitName {
    static NSString * const INTCTDATAIDE = @"debug";
    if (_standardUser) {
        return [NSString stringWithFormat:@"%@_%@_%@", _standardUser.uid, NSStringFromClass([self class]), INTCTDATAIDE];
    } else {
        return [NSString stringWithFormat:@"%@_%@", NSStringFromClass([self class]), INTCTDATAIDE];
    }
}

- (void)intct_signOut {
    self.uid = nil;
    self.token = nil;
//    self.wechatRefreshToken = nil;
//    [INTCTApiCache defaultCache].UserHomeInfoJson = nil;
    _user = nil;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"uid"                 : @"userInfo.userid",
             @"sex"                 : @"userInfo.sex",
             @"avatar"              : @"userInfo.head_pic",
             };
}

@end
