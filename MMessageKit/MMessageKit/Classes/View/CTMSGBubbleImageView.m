//
//  CTMSGBubbleImageView.m
//  MessageKit
//
//  Created by Jeremy on 2019/9/9.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "CTMSGBubbleImageView.h"

@implementation CTMSGBubbleImageView

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(p_copy:) ||
        action == @selector(p_delete:)) {
        return YES;
    }
    return NO;
}

- (void)p_copy:(UIMenuController *)menu {
    if ([_delegate respondsToSelector:@selector(bubbleMenuClickCopy)]) {
        [_delegate bubbleMenuClickCopy];
    }
//    NSLog(@"copy message");
}

- (void)p_delete:(UIMenuController *)menu {
    if ([_delegate respondsToSelector:@selector(bubbleMenuClickDelete)]) {
        [_delegate bubbleMenuClickDelete];
    }
//    NSLog(@"delete message");
}

@end
