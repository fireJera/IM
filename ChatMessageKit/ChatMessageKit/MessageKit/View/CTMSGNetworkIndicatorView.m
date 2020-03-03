//
//  CTMSGNetworkIndicatorView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/2.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGNetworkIndicatorView.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"

@implementation CTMSGNetworkIndicatorView

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

-(void)p_commonInit {
    self.backgroundColor = [UIColor yellowColor];
    int iconWidth = 30;
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, (self.frame.size.height - iconWidth) / 2, iconWidth, iconWidth)];
    [self addSubview:_iconView];
    
    _noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconView.frame.origin.x + _iconView.frame.size.width + 10, (self.frame.size.height - 20) / 2, 0, 20)];
    _noteLabel.text = @"当前网络不可用，请检查你的网络设置";
    _noteLabel.textAlignment = NSTextAlignmentCenter;
    _noteLabel.font = [UIFont systemFontOfSize:14];
    [_noteLabel sizeToFit];
    [self addSubview:_noteLabel];
}


@end
