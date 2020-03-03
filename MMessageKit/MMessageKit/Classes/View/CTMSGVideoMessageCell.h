//
//  CTMSGVideoMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

extern const int CTMSGVideoMessageCellMaxWidth;
extern const int CTMSGVideoMessageCellMaxHeight;

@class CTMSGImageMessageProgressView;

@interface CTMSGVideoMessageCell : CTMSGMessageCell

/*!
 显示图片缩略图的View
 */
@property(nonatomic, strong) UIImageView *pictureView;

@property(nonatomic, strong) UIImageView *palyIcon;

/*!
 显示发送进度的View
 */
@property(nonatomic, strong) CTMSGImageMessageProgressView *progressView;

@end

NS_ASSUME_NONNULL_END
