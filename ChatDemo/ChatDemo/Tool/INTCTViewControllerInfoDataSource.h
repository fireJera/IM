//
//  INTCTViewControllerInfoDataSource.h
//  CodeFrame
//
//  Created by Jeremy on 2019/4/20.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#ifndef INTCTViewControllerInfoDataSource_h
#define INTCTViewControllerInfoDataSource_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, INTCTUserSex) {
    INTCTUserSexFemale = 1,
    INTCTUserSexMale = 2,
};

typedef void(^INTCTViewControllerRefreshBlock)(BOOL needRefresh);
typedef void(^INTCTViewmodelDataBlock)(BOOL isSuccess, BOOL netReachable, NSString * _Nullable msg);

extern NSString * const INTCTCellIdentifier;

@protocol INTCTViewControllerInfoDataSource <NSObject>

#pragma mark - page
@optional
@property (nonatomic, copy, readonly) NSString * uid;
@property (nonatomic, copy, readonly) NSString * lastId;
@property (readonly) INTCTUserSex sex;
@property (readonly) int currentPage;
@property (readonly) BOOL hasMore;
//网络监测
@property (nonatomic, assign, readonly) BOOL netReachable;
//@property (nonatomic, assign, readonly) BOOL isSelf;

- (void)setRefreshBlock:(INTCTViewControllerRefreshBlock)refreshBlock;
- (void)intct_fetchData;
- (void)intct_fetchFirstPageData;
- (void)intct_fetchNextPageData;

- (void)intct_startMonitoringNet:(void(^_Nullable)(BOOL isSuccess))resultBlock;

- (void)intct_dealRequest:(NSDictionary *)dictionary;
- (void)intct_dealRequest:(NSDictionary *)dictionary completion:(_Nullable INTCTViewmodelDataBlock)completion;

#pragma mark - cell
@property (nonatomic, assign, readonly) NSInteger sectionCount;
- (CGFloat)heightForSection:(NSInteger)section;
- (NSInteger)cellCountInSection:(NSInteger)section;
- (NSString *)cellIdentifierInSection:(NSInteger)section;
- (NSString *)cellIdentifierInIndex:(NSInteger)index;
- (NSString *)cellIdentifierInIndexPath:(NSIndexPath *)indexPath;

- (void)clickCellInIndexPath:(nullable NSIndexPath *)indexPath;

@end
NS_ASSUME_NONNULL_END

#endif /* INTCTViewControllerInfoDataSource_h */
