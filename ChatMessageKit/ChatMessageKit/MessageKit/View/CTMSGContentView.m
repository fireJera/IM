//
//  CTMSGContentView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGContentView.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"

@implementation CTMSGContentView

- (void)layoutSubviews {
    if (_eventBlock) {
        _eventBlock(self.bounds);
    }
}

- (void)registerFrameChangedEvent:(void (^)(CGRect))eventBlock {
    _eventBlock = eventBlock;
}

@end
