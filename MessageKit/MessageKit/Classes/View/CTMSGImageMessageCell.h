//
//  CTMSGImageMessageCell.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageCell.h"

extern const int CTMSGImageMessageCellMaxWidth;
extern const int CTMSGImageMessageCellMinWidth;
extern const int CTMSGImageMessageCellMaxHeight;
extern const int CTMSGImageMessageCellMinHeight;

@class CTMSGImageMessageProgressView;

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGImageMessageCell : CTMSGMessageCell

/*!
 显示图片缩略图的View
 */
@property(nonatomic, strong) CTMSGBubbleImageView *pictureView;

/*!
 显示发送进度的View
 */
@property(nonatomic, strong) CTMSGImageMessageProgressView *progressView;


@end

NS_ASSUME_NONNULL_END
