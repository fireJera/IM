//
//  INTCTViewController.m
//  ChatDemo
//
//  Created by Jeremy on 2019/9/27.
//  Copyright © 2019 ChatDemo. All rights reserved.
//

#import "INTCTViewController.h"
#import "UIView+INTCT_Frame.h"
#import "INTCTNetWorkManager+IChat.h"
#import "INTCTConversationListViewmodel.h"
#import "INTCTConversationListViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "INTCTChatManager.h"

@interface INTCTViewController ()

@property (nonatomic, strong) UIButton * loginBtn;
@property (nonatomic, strong) UILabel * noteLabel;

@end

@implementation INTCTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _noteLabel = [[UILabel alloc] init];
    _noteLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_noteLabel];
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _loginBtn.frame = CGRectMake((self.view.width - 100) / 2, 300, 100, 50);
}

- (void)resetLabel {
    [self.noteLabel sizeToFit];
    self.noteLabel.centerX = self.view.width / 2;
    self.noteLabel.top = 100;
}

- (void)login {
    _loginBtn.enabled = NO;
    NSString * phone = @"18551677863";
    NSString * pass = @"123456";
    self.noteLabel.text = @"登录中...1";
    [INTCTNetWorkManager intct_phoneLogin:phone pass:pass result:^(BOOL loginSuccess) {
        _loginBtn.enabled = YES;
        if (loginSuccess) {
            [self p_home];
        }
        else {
            self.noteLabel.text = @"登录失败";
        }
    }];

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
    [UIApplication sharedApplication].delegate.window.rootViewController = tabBarController;
//    [self.window makeKeyAndVisible];
    
    [INTCTNetWorkManager intct_pushToken:[CTMSGIMClient sharedCTMSGIMClient].deviceToken result:nil];
    [INTCTChatManager intct_loginChat];
    //    INTCTAliLog.userid = INTCTINSTANCE_USER.uid;
    //    INTCTAliLog.uaInfo = [INTCTNetWorkManager intct_urlStringSuffix:NO];
    //    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //    [INTCTPushHandler intct_dealPush];
}

@end
