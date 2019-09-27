//
//  AppDelegate.m
//  ChatDemo
//
//  Created by Jeremy on 2019/9/26.
//  Copyright © 2019 ChatDemo. All rights reserved.
//

#import "AppDelegate.h"
#import "INTCTConversationListViewController.h"
#import "INTCTConversationListViewmodel.h"
#import "INTCTNetWorkManager+IChat.h"
#import "INTCTViewController.h"
#import "ViewController.h"
#import "INTCTChatManager.h"
#import <MMessageKit/MMessageKit.h>
#import "INTCTKeyChain.h"
#import "INTCTUser.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] init];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    [self p_setChat];
    
    [INTCTNetWorkManager intct_revoke:^(BOOL shouldGoLogin) {
        if (shouldGoLogin) {
            [self p_login];
        }
        else {
            [self p_home];
        }
    }];
    return YES;
}

- (void)p_setChat {
    // chat message kit
    [CTMSGIMClient sharedCTMSGIMClient].logLevel = CTMSGLogLevelError;
    //    CTMSGLogLevelAll
    [CTMSGIM sharedCTMSGIM].connectionStatusDelegate = (id<CTMSGIMConnectionStatusDelegate>)self;
    //        [CTMSGIM sharedCTMSGIM].enablePersistentUserInfoCache = YES;
    //    [CTMSGIM sharedCTMSGIM].userInfoDataSource = CTMSGDataSource;
    [CTMSGIM  sharedCTMSGIM].receiveMessageDelegate = (id<CTMSGIMReceiveMessageDelegate>)self;
    //        [CTMSGIM sharedCTMSGIM].enabledReadReceiptConversationTypeList = @[@(ConversationType_PRIVATE)];;
    [CTMSGIM sharedCTMSGIM].showUnkownMessage = YES;
    [CTMSGIM sharedCTMSGIM].showUnkownMessageNotificaiton = YES;
    [CTMSGIM sharedCTMSGIM].UUIDStr = [INTCTKeyChain UUId];
}

- (void)p_login {
    INTCTViewController * login = [[INTCTViewController alloc] init];
    self.window.rootViewController = login;
}

- (void)p_home {
    NSMutableArray<UIViewController *> *controllers = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 3; i++) {
        UIViewController * viewController;
        if (i == 0) {
            INTCTConversationListViewmodel * viewmodel = [INTCTConversationListViewmodel sharedViewmodel];
            viewController = [[INTCTConversationListViewController alloc] initWithDatasource:viewmodel];
        }
        else if (i == 1) {
            viewController = [[ViewController alloc] init];
        }
        //        viewController.title = navTitleArray[i];
        UINavigationController *homePageNaviVC = [[UINavigationController alloc] initWithRootViewController:viewController];
        [homePageNaviVC.navigationBar setShadowImage:[UIImage new]];
        //        homePageNaviVC.tabBarItem.title = titleArray[i];
        homePageNaviVC.tabBarItem.title = @"11";
//        homePageNaviVC.tabBarItem.imageInsets = UIEdgeInsetsMake(7, 0, -7, 0);
//        homePageNaviVC.tabBarItem.image = [UIImage imageNamed:imageArray[i]];
//        homePageNaviVC.tabBarItem.selectedImage = [UIImage imageNamed:sImageArray[i]];
        //        if (@available(iOS 11.0, *)) {
        //            homePageNaviVC.navigationBar.prefersLargeTitles = YES;
        //        }
        [controllers addObject:homePageNaviVC];
    }
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [UITabBar appearance].shadowImage = [UIImage new];
    [UITabBar appearance].backgroundImage = [UIImage new];
    [UITabBar appearance].backgroundColor = [UIColor whiteColor];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont intct_PingFangMedium11], NSForegroundColorAttributeName:[UIColor color_b1b1b1]} forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont intct_PingFangMedium11], NSForegroundColorAttributeName:kThemeColor} forState:UIControlStateSelected];
    
    tabBarController.viewControllers = controllers;
    //    tabBarController.tabBar.tintColor = kThemeColor;
    //    if (@available(iOS 10.0, *)) {
    //        tabBarController.tabBar.unselectedItemTintColor = [UIColor color_b1b1b1];
    //    }
    tabBarController.selectedIndex = 0;
    
    if (!self.window) {
        self.window = [UIWindow new];
    }
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    [INTCTNetWorkManager intct_pushToken:[CTMSGIMClient sharedCTMSGIMClient].deviceToken result:nil];
    [INTCTChatManager intct_loginChat];
//    INTCTAliLog.userid = INTCTINSTANCE_USER.uid;
//    INTCTAliLog.uaInfo = [INTCTNetWorkManager intct_urlStringSuffix:NO];
//    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    [INTCTPushHandler intct_dealPush];
    
//    self.window.rootViewController = tabBarController;
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

#pragma mark - CTMSGIMConnectionStatusDelegate

- (void)onCTMSGIMConnectionStatusChanged:(CTMSGConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        NSString * msg = @"您的账号在别的设备上登录，您已被迫下线";
//        [INTCTINSTANCE_USER intct_signOut];
        [[CTMSGIM sharedCTMSGIM] logout];
        INTCTInstanceChatList_VM.totalUnread = 0;
//        [INTCTOpenPageHelper intct_showCustomAlertWithTitle:msg block:^(INTCTOpenAlert * _Nonnull alert) {
//            alert.title(@"知道了").defaultStyle().actionHandler = ^(UIAlertAction * _Nonnull action) {
//                [INTCTOpenPageHelper openLogin];
//            };
//        }];
    }
}

- (void)requireNewNetToken {
    [CTMSGIM sharedCTMSGIM].netToken = INTCTINSTANCE_USER.token;
    [CTMSGIM sharedCTMSGIM].userAgent = [INTCTNetWorkManager intct_defaultUserAgentString:NO];
    [CTMSGIM sharedCTMSGIM].netUA = [INTCTNetWorkManager intct_urlStringSuffix:NO];
}

#pragma mark - CTMSGIMReceiveMessageDelegate

- (void)onCTMSGIMReceiveMessage:(CTMSGMessage *)message left:(int)left {
    if ([message.content isKindOfClass:[CTMSGCommandMessage class]]) {
        CTMSGCommandMessage * command = (CTMSGCommandMessage *)message.content;
        if ([command.name isEqualToString:@"fastChat"]) {
            NSString * userId = [NSString stringWithFormat:@"%@", message.targetId];
//            [[INTCTMatchViewmodel shareViewmodel] receiveMatchResult:userId];
            return;
        }
//        else if ([command.name isEqualToString:@"fastLike"]) {
//            NSString * userId = [NSString stringWithFormat:@"%@", message.targetId];
//            NSEnumerator * enumerator = [CTMSGConversationViewController.allInstance objectEnumerator];
//            CTMSGConversationViewController * conversation;
//            while (conversation = [enumerator nextObject]) {
//                if ([conversation isKindOfClass:[INTCTConversationViewController class]]) {
//                    INTCTConversationViewController * inCon = (INTCTConversationViewController *)conversation;
//                    if (inCon.conversationFrom == INTCTConversationMatch &&
//                        [inCon.targetId isEqualToString:userId]) {
//                        [inCon receiveMatchFavor];
//                    }
//                }
//            }
//            return;
//        }
//        else if ([command.name isEqualToString:@"fastOut"]) {
//            NSString * userId = [NSString stringWithFormat:@"%@", message.targetId];
//            NSEnumerator * enumerator = [CTMSGConversationViewController.allInstance objectEnumerator];
//            CTMSGConversationViewController * conversation;
//            while (conversation = [enumerator nextObject]) {
//                if ([conversation isKindOfClass:[INTCTConversationViewController class]]) {
//                    INTCTConversationViewController * inCon = (INTCTConversationViewController *)conversation;
//                    if (inCon.conversationFrom == INTCTConversationMatch &&
//                        [inCon.targetId isEqualToString:userId]) {
//                        [inCon receiveMatchOut];
//                    }
//                }
//            }
//            return;
//        }
    }
    if ([message.content isKindOfClass:[CTMSGInformationNotificationMessage class]]) {
        if ([message.extra isEqualToString:@"follow"]) {
//            [[INTCTMyViewmodel sharedViewmodel] receiveNewFollow];
            return;
        }
        else if ([message.extra isEqualToString:@"visit"]) {
//            [[INTCTMyViewmodel sharedViewmodel] receiveNewVisitor];
            return;
        }
    }
    [[INTCTConversationListViewmodel sharedViewmodel] receiveNewMessage:message];
}

@end
