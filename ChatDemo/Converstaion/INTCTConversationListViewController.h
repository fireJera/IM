//
//  INTCTConersationListViewController.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <MMessageKit/MMessageKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol INTCTConversationListInfoDataSource;

@interface INTCTConversationListViewController : CTMSGConversationListController

- (instancetype)initWithDatasource:(id<INTCTConversationListInfoDataSource>)datasource;

@end

NS_ASSUME_NONNULL_END
