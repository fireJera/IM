//
//  INTCTConversationModel.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface INTCTChatListModel : NSObject

@property (nonatomic, copy) NSString * userid;
@property (nonatomic, copy) NSString * targetId;
@property (nonatomic, copy) NSString * msgType;
@property (nonatomic, assign) NSInteger unread;
@property (nonatomic, copy) NSString * time;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, assign) BOOL isLock;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * avatar;
//@property (nonatomic, assign) BOOL isVip;

@end

@interface INTCTConversationListModel : NSObject

@property (nonatomic, strong) NSMutableArray<INTCTChatListModel *> * list;
@property (nonatomic, copy) NSString * lastId;
@property (nonatomic, assign) BOOL hasMore;

@end

NS_ASSUME_NONNULL_END
