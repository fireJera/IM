//
//  AppDelegate.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "AppDelegate.h"
#import "CTMSGConversationListController.h"
#import "MessageKit/MessageKit.h"
#import "CTMSGLoginViewController.h"

static int _reconnetCount = 0;

@interface AppDelegate () <CTMSGIMConnectionStatusDelegate, CTMSGIMReceiveMessageDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.window = [[UIWindow alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[CTMSGConversationListController alloc] init]];
//    nav.navigationBar.prefersLargeTitles = YES;
//    self.window.rootViewController = nav;
//    [self.window makeKeyAndVisible];
    [CTMSGIM sharedCTMSGIM].connectionStatusDelegate = self;
    [CTMSGIM sharedCTMSGIM].enablePersistentUserInfoCache = YES;
    [CTMSGIM sharedCTMSGIM].receiveMessageDelegate = self;
//    [CTMSGIM sharedCTMSGIM].enableTypingStatus = YES;
//    //开启发送已读回执
    [CTMSGIM sharedCTMSGIM].enabledReadReceiptConversationTypeList = @[@(ConversationType_PRIVATE)];
//
//    //开启多端未读状态同步
//    [CTMSGIM sharedCTMSGIM].enableSyncReadStatus = YES;
    [CTMSGIM sharedCTMSGIM].userInfoDataSource = CTMSGDataSource;
    //设置显示未注册的消息
    //如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
    [CTMSGIM sharedCTMSGIM].showUnkownMessage = YES;
    [CTMSGIM sharedCTMSGIM].showUnkownMessageNotificaiton = YES;
//    //设置Log级别，开发阶段打印详细log
//    [CTMSGIM sharedCTMSGIM].logLevel = RC_Log_Level_Info;
//
//    NSString * userId = @"10657873";
//    CTMSGUserInfo * currentUserInfo = [[CTMSGUserInfo alloc] initWithUserId:userId name:@"Tender" portrait:@""];
//    [CTMSGIM sharedCTMSGIM].currentUserInfo = currentUserInfo;
//
//    NSString * user = @"user";
//    NSString * pass = @"pass";
//
//    if (!user || !pass) {
//        [self p_regetRCToken];
//    } else {
//        _reconnetCount++;
//        [[CTMSGIM sharedCTMSGIM] connectWithUserId:user password:pass success:^(NSString * _Nullable error) {
//            [[CTMSGDHttpTool shareInstance] getNewestUserInfoByUserID:user completion:^(CTMSGUserInfo * _Nonnull user) {
//                [CTMSGIM sharedCTMSGIM].currentUserInfo = user;
////                INSTANCE_USER.nickname = user.name;
////                INSTANCE_USER.head_pic = user.portraitUri;
//            }];
//            _reconnetCount = 0;
//        } error:^(CTMSGConnectErrorCode status, NSError * _Nullable error) {
//            NSLog(@"链接失败");
//            [self p_regetRCToken];
//        } tokenIncorrect:^{
//            NSLog(@"token 不对");
//            [self p_regetRCToken];
//        }];
//    }
//    [CTMSGNetManager requestWihtMethod:RequestMethodTypeGet
//                                   url:@""
//                                params:nil
//                               success:^(id  _Nonnull response) {
//                                   
//                               } failure:^(NSError * _Nonnull err) {
//                                   
//                               }];
    /**
     * 获取融云推送服务扩展字段1
     */
    if (launchOptions) {
        NSDictionary *pushServiceData = [[CTMSGIMClient sharedCTMSGIMClient] getPushExtraFromLaunchOptions:launchOptions];
        if (pushServiceData) {
            NSLog(@"该启动事件包含来自推送服务");
            for (id key in [pushServiceData allKeys]) {
                NSLog(@"%@", pushServiceData[key]);
            }
        } else {
            NSLog(@"该启动事件不包含来自融云的推送服务");
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:CTMSGKitDispatchMessageNotification
                                               object:nil];
    
    self.window = [[UIWindow alloc] init];
    CTMSGLoginViewController * login = [[CTMSGLoginViewController alloc] init];
    self.window.rootViewController = login;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    NSNumber *left = [notification.userInfo objectForKey:CTMSGKitDispatchMessageNotificationLeftKey];
    if ([CTMSGIMClient sharedCTMSGIMClient].sdkRunningMode == CTMSGRunningMode_Background && 0 == left.integerValue) {
        int unreadMsgCount = [[CTMSGIMClient sharedCTMSGIMClient] getUnreadCount:@[
                                                                                   @(ConversationType_PRIVATE),
                                                                                   ]];
        dispatch_async(dispatch_get_main_queue(),^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount;
        });
    }
}

- (void)onCTMSGIMConnectionStatusChanged:(CTMSGConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
//        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的账号在别的设备上登录，您已被迫下线" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }]];
//        [self setLoginForWindow];
//        [UCNINSTANCE_Application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        //        [RCIMManager RCIMLoginInit];
    } else if (status == ConnectionStatus_DISCONN_EXCEPTION) {
//        [[RCIMClient sharedRCIMClient] disconnect];
//        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的账号被封禁" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }]];
//        [UCNINSTANCE_Application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

-(BOOL)onRCIMCustomLocalNotification:(CTMSGMessage *)message withSenderName:(NSString *)senderName {
    if ([[message.content.class getObjectName] isEqualToString:@"RCJrmf:RpOpendMsg"]) {
        return YES;
    }
    if ([message.objectName isEqualToString:@"RC:InfoNtf"]) {
        //        [UCNLocalPush sendLocalPush:message];
        return YES;
    }
    return NO;
}

#pragma mark - CTMSGIMReceiveMessageDelegate

- (void)onCTMSGIMReceiveMessage:(nonnull CTMSGMessage *)message left:(int)left {
    if (left == 0) {
        //        [[NSNotificationCenter defaultCenter] postNotificationName:UCNMessageRefreshRCNotification
        //                                                            object:nil];
    }
    if ([message.content isMemberOfClass:[CTMSGInformationNotificationMessage class]]) {
        //        RCInformationNotificationMessage *msg = (RCInformationNotificationMessage *)message.content;
        //        //NSString *str = [NSString stringWithFormat:@"%@",msg.message];
        //        //10赞和评论 11系统消息 12关注
        //        NSDictionary * dic = [msg.extra convertToObject];
        //        if (IsDictionaryWithItems(dic)) {
        //            int type = [dic[@"type"] intValue];
        //            NSDictionary * dicType = @{@"type": [NSNumber numberWithInt:type]};
        //            if (type > 9 || type < 13) {
        //                [[NSNotificationCenter defaultCenter] postNotificationName:UCNMessageRefreshServerNotification
        //                                                                    object:nil
        //                                                                  userInfo:dicType];
        //            }
        //        }
    } else {
        //        NSDictionary * dic = @{@"message": message, @"left":[NSNumber numberWithInt:left]};
        //        [[UCNMessageViewModel sharedViewmodel] didReceiveMessage:message left:left];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:UCNMessageReceiveNewNotification
        //                                                            object:nil
        //                                                          userInfo:dic];
    }
}

- (void)p_regetRCToken {
    _reconnetCount++;
    if ((_reconnetCount % 4) == 0) {
        return;
    }
//    NSString * urlString = [NSString stringWithFormat:@"%@?token=%@", kGetRCTokenUrl, UCNINSTANCE_USER.token];
//    [UCNNetWorkManager multipartPost:urlString withParameters:nil result:^(BOOL isSuccess, id result) {
//        if (isSuccess) {
//            NSString * rcToken = SAFESTRING(result[@"data"][@"token"]);
//            if (rcToken) {
//                UCNINSTANCE_USER.rc_token = rcToken;
//                NSLog(@"rctoken:%@", rcToken);
//                NSLog(@"irctoken:%@", UCNINSTANCE_USER.token);
//                [[RCIM sharedRCIM] connectWithToken:rcToken success:^(NSString *userId) {
//                    [RCDHTTPTOOL getNewestUserInfoByUserID:SAFESTRING(UCNINSTANCE_USER.uid) completion:^(RCUserInfo *user) {
//                        UCNINSTANCE_USER.nickname = user.name;
//                        UCNINSTANCE_USER.head_pic = user.portraitUri;
//                        [RCIMClient sharedRCIMClient].currentUserInfo = user;
//                        [RCIM sharedRCIM].currentUserInfo = user;
//                    }];
//                    _reconnetCount = 0;
//                } error:^(RCConnectErrorCode status) {
//                    NSLog(@"链接失败");
//                    [[[RCIMManager alloc] init] p_regetRCToken];
//                } tokenIncorrect:^{
//                    NSLog(@"reget rctoken 不对");
//                    [[[RCIMManager alloc] init] p_regetRCToken];
//                }];
//            }
//        } else {
//            [[[RCIMManager alloc] init] p_regetRCToken];
//        }
//    }];
}


@end
