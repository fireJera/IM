//
//  INTCTViewmodel.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "INTCTViewmodel.h"
#import "INTCTUser.h"
#import "INTCTNetWorkManager.h"

NSString * const INTCTCellIdentifier = @"INTCTCellIdentifier";

@implementation INTCTViewmodel

- (void)setRefreshBlock:(nonnull INTCTViewControllerRefreshBlock)refreshBlock {
    _refreshBlock = refreshBlock;
}

- (NSString *)uid {
    return INTCTINSTANCE_USER.uid;
}

- (INTCTUserSex)sex {
    return INTCTINSTANCE_USER.sex;
}

- (int)currentPage {
    return _currentPage;
}

- (BOOL)hasMore {
    return _hasMore;
}

- (NSString *)lastId {
    return _lastId;
}

- (BOOL)netReachable {
    return [INTCTNetWorkManager netReachable];
}

- (void)intct_fetchData {
    if (!self.netReachable) {
        _refreshBlock(NO);
        return;
    }
}

- (void)intct_fetchFirstPageData {
    _currentPage = 0;
    _lastId = nil;
    [self intct_fetchData];
}

- (void)intct_fetchNextPageData {
    _currentPage++;
    [self intct_fetchData];
}

- (NSInteger)cellCountInSection:(NSInteger)section {
    return 0;
}

- (NSString *)icellIdentifierInIndex:(NSInteger)index {
    return nil;
}

- (NSString *)cellIdentifierInSection:(NSInteger)section {
    return [self cellIdentifierInIndex:section];
}

- (NSString *)cellIdentifierInIndexPath:(NSIndexPath *)indexPath {
    return [self cellIdentifierInIndex:indexPath.row];
}

- (void)intct_startMonitoringNet:(void (^)(BOOL isSuccess))resultBlock {
    [INTCTNetWorkManager intct_startMonitoringNet:resultBlock];
}

- (void)intct_dealRequest:(NSDictionary *)dictionary {
//    [INTCTNetCallback new].intct_deal(dictionary);
}

- (void)intct_dealRequest:(nonnull NSDictionary *)dictionary completion:(INTCTViewmodelDataBlock _Nullable)completion {
    
}

@end
