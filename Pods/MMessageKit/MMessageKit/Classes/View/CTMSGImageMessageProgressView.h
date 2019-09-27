//
//  CTMSGImageMessageProgressView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGImageMessageProgressView : UIView

/*!
 显示进度的Label
 */
@property(nonatomic, strong) UILabel *label;

/*!
 进度指示的View
 */
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;

/*!
 更新进度
 
 @param progress 进度值，0 <= progress <= 100
 */
- (void)updateProgress:(NSInteger)progress;

/*!
 开始播放动画
 */
- (void)startAnimating;

/*!
 停止播放动画
 */
- (void)stopAnimating;


@end

NS_ASSUME_NONNULL_END
