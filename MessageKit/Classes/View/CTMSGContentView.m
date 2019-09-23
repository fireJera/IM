//
//  CTMSGContentView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGContentView.h"
//#import "UIColor+CTMSG_Hex.h"

@implementation CTMSGContentView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_eventBlock) {
        _eventBlock(self.bounds);
    }
}

- (void)registerFrameChangedEvent:(void (^)(CGRect))eventBlock {
    _eventBlock = eventBlock;
}

@end
