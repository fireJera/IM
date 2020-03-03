//
//  CTMSGNetworkIndicatorView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGNetworkIndicatorView : UIView

@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * noteLabel;

@end

NS_ASSUME_NONNULL_END
