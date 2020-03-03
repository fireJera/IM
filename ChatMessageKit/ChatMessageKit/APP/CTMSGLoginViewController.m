//
//  CTMSGLoginViewController.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGLoginViewController.h"
#import "MessageKit.h"

static NSString * const kUserName1 = @"10657873";
static NSString * const kPass1 = @"R6ZYxyHxxrYquPu1isPdUpiQYqF518jb";

static NSString * const kUserName2 = @"50368823";
static NSString * const kPass2 = @"tBVwGpuCznHV41pilKv1EJMU1e7wpXUL";

@interface CTMSGLoginViewController ()

@end

@implementation CTMSGLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 200, 175, 50);
    btn1.backgroundColor = [UIColor blackColor];
    [btn1 setTitle:@"account 10657873" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    btn1.tag = 10;
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(100, 280, 175, 50);
    btn2.backgroundColor = [UIColor blackColor];
    [btn2 setTitle:@"account 50368823" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    btn2.tag = 20;
    
//    [CTMSGNetManager startMonitoringNet:^{
//        
//    }];
}

- (void)login:(UIButton *)sender {
    NSString * username, * pass;
    if (sender.tag == 10) {
        username = kUserName1;
        pass = kPass1;
    }
    else {
        username = kUserName2;
        pass = kPass2;
    }
    
    [[CTMSGIM sharedCTMSGIM] connectWithUserId:username password:pass success:^(NSString * _Nullable string) {
        NSString * userId = username;
        CTMSGUserInfo * currentUserInfo = [[CTMSGUserInfo alloc] initWithUserId:userId name:@"Tender" portrait:@""];
        [CTMSGIM sharedCTMSGIM].currentUserInfo = currentUserInfo;
        [self gotoRoot];
    } error:^(CTMSGConnectErrorCode status, NSError * _Nullable error) {
        NSLog(@"login fail");
    } tokenIncorrect:^{
        NSLog(@"login fail");
    }];
}

- (void)gotoRoot {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController * view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"root"];
        [self presentViewController:view animated:YES completion:nil];
    });
}

@end
