//
//  CTMSGImageMessageProgressView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGImageMessageProgressView.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"

@implementation CTMSGImageMessageProgressView


#pragma mark - layout

#pragma mark - public

- (void)updateProgress:(NSInteger)progress {
    
}

- (void)startAnimating {
    
}

- (void)stopAnimating {
    
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    _label = [[UILabel alloc] init];
    [self addSubview:_label];
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    [self addSubview:_label];
}

@end
