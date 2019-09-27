//
//  INTCTChatManager.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/26.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTChatManager.h"
#import <MMessageKit/MMessageKit.h>
#import "INTCTNetWorkManager+IChat.h"
#import "INTCTUser.h"

static int _reconnetCount = 0;

@implementation INTCTChatManager

+ (void)intct_loginChat {
    CTMSGUserInfo * currentUser = [[CTMSGUserInfo alloc] initWithUserId:INTCTINSTANCE_USER.uid name:INTCTINSTANCE_USER.nickname portrait:INTCTINSTANCE_USER.avatar];
    [CTMSGIM sharedCTMSGIM].currentUserInfo = currentUser;
    
    //    [[CTMSGIMClient sharedCTMSGIMClient] disconnect];
    //    [[CTMSGIMClient sharedCTMSGIMClient] logout];
    [self p_intct_reconncet];
}

+ (void)p_intct_reconncet {
    _reconnetCount++;
    if ((_reconnetCount % 4) == 0) {
        return;
    }
    
    [INTCTNetWorkManager intct_chatToken:^(id  _Nullable result) {
        if (result) {
            NSString * pass = result[@"token"];
            NSString * host = result[@"host"];
            NSUInteger port = [result[@"port"] unsignedIntegerValue];
            [CTMSGIM sharedCTMSGIM].netToken = INTCTINSTANCE_USER.token;
            [CTMSGIM sharedCTMSGIM].userAgent = [INTCTNetWorkManager intct_defaultUserAgentString:NO];
            [CTMSGIM sharedCTMSGIM].netUA = [INTCTNetWorkManager intct_urlStringSuffix:NO];
            [[CTMSGIM sharedCTMSGIM] connectWithUserId:INTCTINSTANCE_USER.uid password:pass host:host port:port success:^(NSString * _Nullable string) {
                [[CTMSGDataBaseManager shareInstance] removeAllMatchChatMessages];
            } error:^(CTMSGConnectErrorCode status, NSError * _Nullable error) {
                [self p_intct_reconncet];
            } tokenIncorrect:^{
                [self p_intct_reconncet];
            }];
        } else {
            [self p_intct_reconncet];
        }
    }];
}

@end
