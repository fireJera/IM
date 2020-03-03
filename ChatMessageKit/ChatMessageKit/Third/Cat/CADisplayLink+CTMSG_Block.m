//
//  CTMSG_Block.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CADisplayLink+CTMSG_Block.h"
#import <objc/runtime.h>

@implementation CADisplayLink (CTMSG_Block)

+ (CADisplayLink *)displayLinkWithExecuteBlock:(CMTSGExecuteDisplayLinkBlock)block {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_letad_executeDisplayLink:)];
    displayLink.executeBlock = [block copy];
    return displayLink;
}

- (void)setExecuteBlock:(CMTSGExecuteDisplayLinkBlock)executeBlock {
    objc_setAssociatedObject(self, @selector(executeBlock), [executeBlock copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CMTSGExecuteDisplayLinkBlock)executeBlock{
    return objc_getAssociatedObject(self, @selector(executeBlock));
}

+ (void)p_letad_executeDisplayLink:(CADisplayLink *)displayLink{
    if (displayLink.executeBlock) {
        displayLink.executeBlock(displayLink);
    }
}

@end
