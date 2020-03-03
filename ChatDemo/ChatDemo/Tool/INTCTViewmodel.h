//
//  INTCTViewmodel.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "INTCTViewControllerInfoDataSource.h"
//
//typedef void(^INTCTViewmodelProgessBlock)(float progress);
//typedef void(^INTCTViewmodelSuccessBlock)(NSString * _Nullable msg, id _Nullable result);
//typedef void(^INTCTViewmodelFailBlock)(BOOL isSuccess, BOOL netReachable, NSString * _Nullable msg);

NS_ASSUME_NONNULL_BEGIN

@interface INTCTViewmodel : NSObject <INTCTViewControllerInfoDataSource> {
    int _currentPage;
    NSString * _lastId;
    BOOL _hasMore;
    INTCTViewControllerRefreshBlock _refreshBlock;
}

- (NSString *)uid;

- (INTCTUserSex)sex;

- (int)currentPage;
- (BOOL)hasMore;
- (NSString *)lastId;
- (BOOL)netReachable;
- (void)intct_fetchData;
- (void)intct_fetchFirstPageData;
- (void)intct_fetchNextPageData;
- (void)intct_startMonitoringNet:(void (^_Nullable )(BOOL isSuccess))resultBlock;
- (void)intct_dealRequest:(NSDictionary *)dictionary;
- (void)intct_dealRequest:(nonnull NSDictionary *)dictionary completion:(INTCTViewmodelDataBlock _Nullable)completion;
- (void)setRefreshBlock:(INTCTViewControllerRefreshBlock)refreshBlock;

@end

NS_ASSUME_NONNULL_END
