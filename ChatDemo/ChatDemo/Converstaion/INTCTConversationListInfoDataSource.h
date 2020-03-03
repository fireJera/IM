//
//  INTCTConversationListViewmodel.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#ifndef INTCTConversationListInfoDataSource_h
#define INTCTConversationListInfoDataSource_h

#import "INTCTViewControllerInfoDataSource.h"

@class CTMSGConversationModel;

@protocol INTCTConversationListInfoDataSource <INTCTViewControllerInfoDataSource>

@property (readonly) NSInteger unread;
@property (nonatomic, copy, readonly) NSMutableArray<CTMSGConversationModel *> * messages;
@property (readonly) BOOL showEmpty;
@property (readonly) BOOL isCache;

//- (void)readAllMessageWithTargetId:(NSString *)targetId;
- (void)removeConversationAtIndex:(NSInteger)index;

- (void)changeUnread:(NSInteger)count;
//- (void)fetchCache;
- (void)getDBConverstations:(NSMutableArray<CTMSGConversationModel *> *)messages;

@end
#endif /* INTCTConversationListInfoDataSource_h */
