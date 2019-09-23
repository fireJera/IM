//
//  NSTimer+CTMSG_Block.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSTimer+CTMSG_Block.h"
#import <objc/runtime.h>

@implementation NSTimer (CTMSG_Block)


+ (NSTimer *)ctmsg_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(void))block {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(p_ctmsg_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)p_ctmsg_blockInvoke:(NSTimer *)timer {
    void(^blcok)(void) = timer.userInfo;
    if (blcok) {
        blcok();
    }
}

@end

@implementation CADisplayLink (CTMSG_Block)

+ (CADisplayLink *)displayLinkWithExecuteBlock:(CTMSGExecuteDisplayLinkBlock)block {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_ctmsg_executeDisplayLink:)];
    displayLink.executeBlock = [block copy];
    return displayLink;
}

- (void)setExecuteBlock:(CTMSGExecuteDisplayLinkBlock)executeBlock {
    objc_setAssociatedObject(self, @selector(executeBlock), [executeBlock copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CTMSGExecuteDisplayLinkBlock)executeBlock{
    return objc_getAssociatedObject(self, @selector(executeBlock));
}

+ (void)p_ctmsg_executeDisplayLink:(CADisplayLink *)displayLink{
    if (displayLink.executeBlock) {
        displayLink.executeBlock(displayLink);
    }
}

@end
