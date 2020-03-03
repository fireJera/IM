//
//  CTMSGTipLabel.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGTipLabel : CTMSGAttributedLabel

/*!
 边缘间隙
 */
@property(nonatomic, assign) UIEdgeInsets marginInsets;

/*!
 初始化灰条提示Label对象
 
 @return 灰条提示Label对象
 */
+ (instancetype)greyTipLabel;

@end

NS_ASSUME_NONNULL_END
