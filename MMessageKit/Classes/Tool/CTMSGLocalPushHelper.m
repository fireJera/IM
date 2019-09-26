////
////  CTMSGLocalPushHelper.m
////  BanteaySrei
////
////  Created by Jeremy on 2019/4/15.
////  Copyright © 2019 BanteaySrei. All rights reserved.
////
//
//#import "CTMSGLocalPushHelper.h"
//#import <UserNotifications/UserNotifications.h>
//
//@implementation CTMSGLocalPushHelper
//
////+ (void)sendLocalPush:(RCMessage *)pushMessage {
////    //    INTCTSystemMessage * message = (INTCTSystemMessage *)pushMessage.content;
////    //    if ([message isKindOfClass:[INTCTSystemMessage class]]) {
////    //        if (message.pageData && message.pageName) {
////    //            NSDictionary * dic =  @{@"pageName": message.pageName, @"pageData": message.pageData};
////    //            NSString * str = [dic convertToJSONStr];
////    //            if (str) {
////    //                NSDictionary * dic = @{@"appData": str};
////    //                NSString * contentStr = message.showContent;
////    //                [CTMSGLocalPushHelper sendLocalPushTitle:contentStr userInfo:dic];
////    //            }
////    //        }
////    //    }
////    //    else {
////    //
////    //    }
////}
//
//+ (void)ctmsg_sendLocalPushTitle:(NSString *)title userInfo:(NSDictionary *)userInfo {
//    if (@available(iOS 10.0, *)) {
//        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
//        content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
//        content.sound = [UNNotificationSound defaultSound];
//        if ([userInfo isKindOfClass:NSDictionary.class]) {
//            content.userInfo = userInfo;
//        }
//        // 在 alertTime 后推送本地推送
//        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
//                                                      triggerWithTimeInterval:0.5 repeats:NO];
//
//        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
//                                                                              content:content trigger:trigger];
//        //        //添加推送成功后的处理！
//        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        }];
//    } else {
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        // 设置触发通知的时间
//        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//        //        NSLog(@"fireDate=%@", fireDate);
//
//        notification.fireDate = fireDate;
//        // 时区
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        // 设置重复的间隔
//        notification.repeatInterval = kCFCalendarUnitSecond;
//
//        // 通知内容
//        notification.alertBody =  title;
//        notification.applicationIconBadgeNumber = 1;
//        // 通知被触发时播放的声音
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        // 通知参数
//        NSDictionary *userDict = [NSDictionary dictionaryWithObject:title forKey:@"key"];
//        notification.userInfo = userDict;
//
//        // ios8后，需要添加这个注册，才能得到授权
//        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
//            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
//                                                                                     categories:nil];
//            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//            // 通知重复提示的单位，可以是天、周、月
//            notification.repeatInterval = NSCalendarUnitDay;
//        } else {
//            // 通知重复提示的单位，可以是天、周、月
//            notification.repeatInterval = NSCalendarUnitDay;//NSDayCalendarUnit;
//        }
//
//        // 执行通知注册
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
//}
//@end
