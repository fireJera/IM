//
//  INTCTUser.h
//  LetDate
//
//  Created by Jeremy on 2019/1/19.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "INTCTUserDefaults.h"

//NS_ASSUME_NONNULL_BEGIN
#define INTCTINSTANCE_USER                     ([INTCTUser standardUser])
#define INTCTINSTANCE_CURRENTUSER              ([INTCTUser currentUser])      // 确保当前用户不为空的时候调用

@interface INTCTUser : INTCTUserDefaults

+ (instancetype)standardUser;           // 所有用户公用数据
+ (instancetype)currentUser;            // 用户独享数据

#pragma mark - standardUser
/* 个人基本资料  */
@property (nonatomic, copy) NSString * uid;
@property (nonatomic, copy) NSString * token;
@property (nonatomic, assign) int sex;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, copy) NSString * wechatRefreshToken;
//@property (nonatomic, assign) BOOL dailySign;

#pragma mark - currentUser

//@property (nonatomic, assign) int fillInfoStep;

@property (nonatomic, assign) NSInteger marriageId;
@property (nonatomic, assign) NSInteger houseId;
@property (nonatomic, assign) NSInteger childId;
@property (nonatomic, assign) NSInteger provinceId;
@property (nonatomic, assign) NSInteger cityId;
@property (nonatomic, assign) NSInteger jobId;
@property (nonatomic, assign) NSInteger educationId;
@property (nonatomic, assign) NSInteger incomeId;
@property (nonatomic, copy) NSString * travelIds;
@property (nonatomic, assign) NSInteger loveId;
@property (nonatomic, copy) NSString * birthday;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger weight;
@property (nonatomic, copy) NSString * heightRange;
@property (nonatomic, copy) NSString * ageRange;
@property (nonatomic, assign) NSInteger figureId;
@property (nonatomic, assign) NSInteger bodyId;
@property (nonatomic, assign) NSInteger aimIncomeId;
@property (nonatomic, assign) NSInteger aimEducationId;
@property (nonatomic, copy) NSString * declaration;

// 0 unset 1 off 2 on 
@property (nonatomic, assign) int showMatchNote;

- (void)intct_signOut;

@end

//NS_ASSUME_NONNULL_END
