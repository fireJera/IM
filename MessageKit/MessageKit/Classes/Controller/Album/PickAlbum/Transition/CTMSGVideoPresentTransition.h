//
//  CTMSGVideoPresentTransition.h
//  微博照片选择
//
//  Created by 洪欣 on 17/2/22.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CTMSGVideoPresentTransitionType) {
    CTMSGVideoPresentTransitionPresent = 0,
    CTMSGVideoPresentTransitionDismiss
};

@interface CTMSGVideoPresentTransition : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithTransitionType:(CTMSGVideoPresentTransitionType)type;

- (instancetype)initWithTransitionType:(CTMSGVideoPresentTransitionType)type;
@end
