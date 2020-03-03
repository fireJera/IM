//
//  CTMSGTextMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageCell.h"
#import "CTMSGAttributedLabel.h"

extern const int Text_Message_Font_Size;
// 文字距离气泡的左边
extern const int Text_Message_Lable_Leading;
extern const int Text_Message_Lable_Top;

@class CTMSGMessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGTextMessageCell : CTMSGMessageCell <CTMSGAttributedLabelDelegate>

/*!
 显示消息内容的Label
 */
@property(nonatomic, strong) CTMSGAttributedLabel *textLabel;

///*!
// 设置当前消息Cell的数据模型
//
// @param model 消息Cell的数据模型
// */
//- (void)setDataModel:(CTMSGMessageModel *)model;

@end

NS_ASSUME_NONNULL_END
