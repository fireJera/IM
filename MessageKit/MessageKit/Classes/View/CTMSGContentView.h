//
//  CTMSGContentView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTMSGContentView : UIView

/*!
 Frame发生变化的回调
 */
@property(nonatomic, copy) void (^eventBlock)(CGRect frame);

/*!
 注册Frame发生变化的回调
 
 @param eventBlock Frame发生变化的回调
 */
- (void)registerFrameChangedEvent:(void (^)(CGRect frame))eventBlock;

@end

NS_ASSUME_NONNULL_END
