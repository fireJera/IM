//
//  CTMSGCommadnNotificationMessage.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CTMSGCommandNotificationMessageIdentifier;

@interface CTMSGCommadnNotificationMessage : CTMSGMessageContent

/*!
 通知的内容
 */
@property(nonatomic, strong) NSString * pageName;
@property(nonatomic, strong) NSString * showContent;
@property(nonatomic, strong) NSDictionary * pageData;

/*!
 通知的附加信息
 */
@property(nonatomic, strong) NSString *extra;


@end

NS_ASSUME_NONNULL_END
