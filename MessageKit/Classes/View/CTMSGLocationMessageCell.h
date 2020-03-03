//
//  CTMSGLocationMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGLocationMessageCell : CTMSGMessageCell

/*!
 当前位置在地图中的概览图
 */
@property(nonatomic, strong) UIImageView *pictureView;

/*!
 显示位置名称的Label
 */
@property(nonatomic, strong) UILabel *locationNameLabel;

@end

NS_ASSUME_NONNULL_END
