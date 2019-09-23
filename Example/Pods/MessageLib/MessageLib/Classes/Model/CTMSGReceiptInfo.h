//
//  CTMSGReceiptInfo.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMSGEnumDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGReceiptInfo : NSObject

/*!
 是否需要回执消息
 */
@property(nonatomic, assign) BOOL isReceiptRequestMessage;

/**
 *  是否已经发送回执
 */
@property(nonatomic, assign) BOOL hasRespond;

/*!
 发送回执的用户ID列表
 */
@property(nonatomic, strong) NSMutableDictionary *userIdList;

@end

NS_ASSUME_NONNULL_END
