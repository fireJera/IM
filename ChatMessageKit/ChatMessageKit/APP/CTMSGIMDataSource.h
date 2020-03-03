//
//  CTMSGIMDataSource.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/11.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMSGIM.h"

#define CTMSGDataSource [CTMSGIMDataSource shareInstance]

/*
 层级关系
 DataSource
    |
   \|∕
 UserInfoManager  从数据库拿或者从网络获取
    |
   \|∕
 HttpTool         从网络获取
    |
   \|∕
 NetManager       网络请求管理
    |
   \|∕
 */


NS_ASSUME_NONNULL_BEGIN

@interface CTMSGIMDataSource : NSObject <CTMSGIMUserInfoDataSource>

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
