//
//  INTCTLockMessageCell.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <MMessageKit/MMessageKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface INTCTLockMessageCell : CTMSGMessageCell

@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) UIImageView * lockIcon;


@end

NS_ASSUME_NONNULL_END
