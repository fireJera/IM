//
//  CTMSGVoiceGestureRecognizer.m
//  MessageKit
//
//  Created by Jeremy on 2019/5/22.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "CTMSGVoiceGestureRecognizer.h"

@implementation CTMSGVoiceGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) {
        return;
    }
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
}

//- (instancetype)initWithTarget:(id)target action:(SEL)action {
//    self = [super initWithTarget:target action:action];
//    if (!self) return nil;
//    return self;
//}

@end
