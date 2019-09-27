//
//  INTCTConversationListViewmodel.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/23.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTConversationListViewmodel.h"
#import "INTCTConversationListModel.h"
#import <MMessageKit/MMessageKit.h>
#import <YYCache/YYCache.h>
#import <YYModel/YYModel.h>
#import "INTCTNetWorkManager+IChat.h"

@interface INTCTConversationListViewmodel () {
    NSInteger _currentPage;
    BOOL _hasCache;
}

@property (nonatomic, strong) INTCTConversationListModel * model;
@property (nonatomic, strong) NSMutableArray<CTMSGConversationModel *> * messageModels;

@end
@implementation INTCTConversationListViewmodel

+ (instancetype)sharedViewmodel {
    static INTCTConversationListViewmodel * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedViewmodel];
}

- (void)intct_fetchData {
    NSString * lastId;
    if (_currentPage) {
        lastId = _model.lastId;
    }
    [INTCTNetWorkManager intct_chatListWithLastId:lastId result:^(NSError * _Nullable error, INTCTConversationListModel * _Nullable chatData) {
        NSMutableArray<CTMSGConversationModel *> *converstaionModels = [NSMutableArray array];
        NSMutableArray<CTMSGConversation *> *converstaions = [NSMutableArray array];
        NSMutableArray<CTMSGUserInfo *> *users = [NSMutableArray array];
        [chatData.list enumerateObjectsUsingBlock:^(INTCTChatListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CTMSGConversation * converstaion = [obj copy];
            CTMSGConversationModel *model = [[CTMSGConversationModel alloc] initWithConversation:converstaion extend:nil];
            model.isLock = obj.isLock;
            model.showTime = obj.time;
            [converstaions addObject:converstaion];
            [converstaionModels addObject:model];
            if (converstaion.lastestMessage.senderUserInfo) {
                [users addObject:converstaion.lastestMessage.senderUserInfo];
            }
        }];
        [[CTMSGDataBaseManager shareInstance] updateConversationDBWithList:converstaions];
        [[CTMSGDataBaseManager shareInstance] updateUserInfoWithUsers:users];
        if (_currentPage == 0) {
            _model = chatData;
            _messageModels = converstaionModels;
        } else {
            _model.lastId = chatData.lastId;
            _model.hasMore = chatData.hasMore;
            [_model.list addObjectsFromArray:chatData.list];
            [_messageModels addObjectsFromArray:converstaionModels];
        }
        _hasCache = NO;
        if (_refreshBlock) {
            _refreshBlock(error == nil);
        }
    }];
    
    //    [CTMSGNetManager getConversationListLastId:_lastId success:^(id  _Nonnull response) {
    //        if ([response isKindOfClass:[NSDictionary class]]) {
    //            NSDictionary * result = (NSDictionary *)response;
    //            _hasMore = [result[@"data"][@"hasMore"] boolValue];
    //            _lastId =  [NSString stringWithFormat:@"%@", result[@"data"][@"lastId"]];
    //            NSArray * array = result[@"data"][@"list"];
    //            NSMutableArray<CTMSGConversationModel *> * conversations = [NSMutableArray array];
    //            for (NSDictionary * dic in array) {
    //                CTMSGNetConversationModel * model = [CTMSGNetConversationModel yy_modelWithJSON:dic];
    //                CTMSGConversationModel * cModel = [model copy];
    //                [conversations addObject:cModel];
    //            }
    //
    //            LOCK
    //            if (_currentPage == 0) {
    //                _conversationListDataSource = conversations;
    //            } else {
    //                [_conversationListDataSource addObjectsFromArray:conversations];
    //            }
    //            _conversationListDataSource = [self willReloadTableData:_conversationListDataSource];
    //            UNLOCK
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [_conversationListTableView reloadData];
    //                if (_conversationListDataSource.count == 0) {
    //                    _conversationListTableView.tableFooterView = self.emptyConversationView;
    //                }
    //            });
    //            _currentPage++;
    //        }
    //    } failure:^(NSError * _Nonnull err) {
    //    }];
}

- (void)removeConversationAtIndex:(NSInteger)index {
    CTMSGConversationModel * model = [_messageModels objectAtIndex:index];
    [INTCTNetWorkManager intct_removeConversationWithTargetId:model.targetId result:^(NSError * _Nullable error) {
        if (!error) {
            [_messageModels removeObject:model];
            [self changeUnread:-model.unreadMessageCount];
            [[CTMSGIMClient sharedCTMSGIMClient] removeConversation:ConversationType_PRIVATE targetId:model.targetId];
            if (_refreshBlock) {
                _refreshBlock(error == nil);
            }
        }
    }];
}

- (void)getDBConverstations:(NSMutableArray<CTMSGConversationModel *> *)messages {
    _messageModels = messages;
}

//- (void)fetchCache {
//    YYCache * cache = [YYCache cacheWithName:INTCTINSTANCE_USER.uid];
//    NSString * key = @"chatListCache";
//    NSData * data = (NSData *)[cache objectForKey:key];
//    if (data) {
//        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        INTCTConversationListModel * chatData = [INTCTConversationListModel yy_modelWithJSON:result[@"data"]];
//
//        NSMutableArray<CTMSGConversationModel *> *array = [NSMutableArray array];
//        [chatData.list enumerateObjectsUsingBlock:^(INTCTChatListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            CTMSGConversation * converstaion = [obj copy];
//            CTMSGConversationModel *model = [[CTMSGConversationModel alloc] initWithConversation:converstaion extend:nil];
////            model.isLock = obj.isLock;
////            model.showTime = obj.time;
//            [array addObject:model];
//        }];
//        _model = chatData;
//        _messageModels = array;
//        if (_refreshBlock) {
//            _hasCache = YES;
//            _refreshBlock(YES);
//        }
//    }
//}

- (BOOL)isCache {
    return _hasCache;
}

//+ (void)setTotalUnread:(NSInteger)totalUnread {
//    totalUnread = MAX(totalUnread, 0);
//}

//+ (NSInteger)totalUnread {
//    return totalUnread;
//}

- (NSInteger)unread {
    return _totalUnread;
}

- (BOOL)hasMore {
    return _model.hasMore;
}

- (BOOL)showEmpty {
    return _messageModels.count == 0;
}

- (NSMutableArray<CTMSGConversationModel *> *)messages {
    return _messageModels;
}

- (void)intct_fetchFirstPageData {
    _currentPage = 0;
    [self intct_fetchData];
}

- (void)intct_fetchNextPageData {
    _currentPage++;
    [self intct_fetchData];
}

//- (void)readAllMessageWithTargetId:(NSString *)targetId {
//
//}

- (void)changeUnread:(NSInteger)count {
    _totalUnread += count;
    _totalUnread = MAX(0, _totalUnread);
}

- (void)readMessageWithTargetId:(NSString *)targetId {
    [_messageModels enumerateObjectsUsingBlock:^(CTMSGConversationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([targetId isEqualToString:obj.targetId]) {
            [self changeUnread:-obj.unreadMessageCount];
            obj.unreadMessageCount = 0;
            *stop = YES;
        }
    }];
}

- (void)receiveNewMessage:(CTMSGMessage *)message {
    if (message.messageDirection == CTMSGMessageDirectionReceive) {
        if ([message.content isKindOfClass:[CTMSGCommandMessage class]]) {
            return;
        }
        if (![CTMSGConversationViewController conversationOpenedWithTargetId:message.targetId]) {
            [self changeUnread:1];
//            [INTCTOpenPageHelper setUnreadMessageCount:_totalUnread];
        }
    }
}

@end
