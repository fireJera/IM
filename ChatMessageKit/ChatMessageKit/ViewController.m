//
//  ViewController.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "ViewController.h"
#import "MessageKit/MessageKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)chat:(UIButton *)sender {
    CTMSGConversationListController * list = [[CTMSGConversationListController alloc] init];
//    UIViewController * view = [[UIViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
    if (@available(iOS 11.0, *)) {
        nav.navigationBar.prefersLargeTitles = YES;
    } else {
        
    }
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)sendMessage:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSString *targetId = [NSString stringWithFormat:@"%d", (int)(10000000 + tag)];
    CTMSGTextMessage * message = [CTMSGTextMessage messageWithContent:@"this is a text message frome me"];
    [[CTMSGIM sharedCTMSGIM] sendMessage:ConversationType_PRIVATE
                                targetId:targetId
                                 content:message
                             pushContent:nil
                                pushData:nil
                                 success:^(long messageId) {
                                     
                                 } error:^(CTMSGErrorCode nErrorCode, long messageId) {
                                     
                                 }];
    
    CTMSGTextMessage * textmessage = [CTMSGTextMessage messageWithContent:@"this is a text message to me"];
    CTMSGMessage * receiveMessage = [[CTMSGMessage alloc] initWithType:ConversationType_PRIVATE
                                                              targetId:targetId
                                                             direction:CTMSGMessageDirectionReceive
                                                             messageId:0
                                                               content:textmessage];
    receiveMessage.senderUserId = targetId;
    [[CTMSGIMClient sharedCTMSGIMClient] receiveTestMessage:receiveMessage];
}

@end
