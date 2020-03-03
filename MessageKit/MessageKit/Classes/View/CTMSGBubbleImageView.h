//
//  CTMSGBubbleImageView.h
//  MessageKit
//
//  Created by Jeremy on 2019/9/9.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BubbleImageViewMenuDelegate;

@interface CTMSGBubbleImageView : UIImageView

@property (nonatomic, weak) id<BubbleImageViewMenuDelegate> delegate;

@end

@protocol BubbleImageViewMenuDelegate <NSObject>

@optional

- (void)bubbleMenuClickCopy;
- (void)bubbleMenuClickDelete;

@end

NS_ASSUME_NONNULL_END
