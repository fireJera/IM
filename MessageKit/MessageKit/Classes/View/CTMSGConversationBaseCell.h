//
//  CTMSGConversationBaseCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTMSGConversationModel;
NS_ASSUME_NONNULL_BEGIN

@interface CTMSGConversationBaseCell : UITableViewCell

/*!
 会话Cell的数据模型
 */
@property(nonatomic, strong) CTMSGConversationModel *model;

@end

NS_ASSUME_NONNULL_END
