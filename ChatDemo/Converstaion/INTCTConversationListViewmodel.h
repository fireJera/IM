//
//  INTCTConversationListViewmodel.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INTCTConversationListInfoDataSource.h"
#import "INTCTViewmodel.h"

NS_ASSUME_NONNULL_BEGIN

#define INTCTInstanceChatList_VM  ([INTCTConversationListViewmodel sharedViewmodel])

@class CTMSGMessage;

@interface INTCTConversationListViewmodel : INTCTViewmodel <INTCTConversationListInfoDataSource>

@property (nonatomic, assign) NSInteger totalUnread;

+ (instancetype)sharedViewmodel;
- (void)readMessageWithTargetId:(NSString *)targetId;

- (void)receiveNewMessage:(CTMSGMessage *)message;

@end

NS_ASSUME_NONNULL_END
