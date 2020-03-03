//
//  CTMSGPluginBoardView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGPluginBoardView.h"
#import "UIColor+CTMSG_Hex.h"

@implementation CTMSGPluginBoardView

#pragma mark - layout

- (void)layoutSubviews {
    
}

#pragma mark - public
- (void)insertItemWithImage:(UIImage *)image title:(NSString *)title tag:(NSInteger)tag {
    
}

- (void)insertItemWithImage:(UIImage *)image title:(NSString *)title atIndex:(NSInteger)index tag:(NSInteger)tag {
    
}

- (void)updateItemAtIndex:(NSInteger)index image:(UIImage *)image title:(NSString *)title {
    
}

- (void)updateItemWithTag:(NSInteger)tag image:(UIImage *)image title:(NSString *)title {
    
}

- (void)removeItemAtIndex:(NSInteger)index {
    
}

- (void)removeItemWithTag:(NSInteger)tag {
    
}

- (void)removeAllItems {
    
}

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
    
}

@end
