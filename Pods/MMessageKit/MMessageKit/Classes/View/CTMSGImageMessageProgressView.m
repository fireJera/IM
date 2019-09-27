//
//  CTMSGImageMessageProgressView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGImageMessageProgressView.h"
#import "UIColor+CTMSG_Hex.h"

@implementation CTMSGImageMessageProgressView

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = 20;
    _indicatorView.frame = (CGRect){(self.frame.size.width - width) / 2, (self.frame.size.height - width) / 2, 20, 20};
    _label.center = (CGPoint){self.frame.size.width / 2, self.frame.size.height / 2};
    //    CGFloat labelWidth = 60, labelHeight = 20;
//    _label.frame = (CGRect){(self.frame.size.width - labelWidth) / 2, (self.frame.size.height - labelHeight) / 2, labelWidth, labelHeight};
}

#pragma mark - public

- (void)updateProgress:(NSInteger)progress {
    _label.text = [NSString stringWithFormat:@"%d%%", (int)progress];
    NSLog(@"image cell updateProgress : %d%%", (int)progress);
    if (progress >= 100.0) {
        [self removeFromSuperview];
    }
}

- (void)startAnimating {
    [_indicatorView startAnimating];
}

- (void)stopAnimating {
    [_indicatorView stopAnimating];
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

- (void)p_commonInit {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _label = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 60, 30}];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor whiteColor];
    [self addSubview:_label];
//    _indicatorView = [[UIActivityIndicatorView alloc] init];
//    [self addSubview:_indicatorView];
}

@end
