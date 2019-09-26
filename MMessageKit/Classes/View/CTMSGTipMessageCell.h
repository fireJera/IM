//
//  CTMSGTipMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageBaseCell.h"

@class CTMSGTipLabel, CTMSGMessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGTipMessageCell : CTMSGMessageBaseCell

/*!
 提示的Label
 */
@property(nonatomic, strong) CTMSGTipLabel *tipMessageLabel;

///*!
// 设置当前消息Cell的数据模型
//
// @param model 消息Cell的数据模型
// */
//- (void)setDataModel:(CTMSGMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
