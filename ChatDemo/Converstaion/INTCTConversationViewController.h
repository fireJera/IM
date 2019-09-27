//
//  INTCTConversationViewController.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <MMessageKit/MMessageKit.h>
#import "INTCTConversationDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface INTCTConversationViewController : CTMSGConversationViewController

@property (nonatomic, assign, readonly) INTCTConversationFrom conversationFrom;

- (instancetype)initWithDataSource:(id<INTCTConversationDataSource>)dataSource;

- (void)receiveMatchFavor;
- (void)receiveMatchOut;

@end

NS_ASSUME_NONNULL_END
