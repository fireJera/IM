//
//  INTCTFastTextView.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/30.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTFastTextView.h"
#import "UIView+INTCT_Frame.h"
#import "UIFont+INTCT_Custom.h"
#import "UIColor+INTCT_App.h"
#import "Header.h"

@interface INTCTFastTextView ()

@property (nonatomic, copy) NSArray * texts;

@end

@implementation INTCTFastTextView

#pragma mark - touch

//- (void)p_intct_close:(UIButton *)sender {
//    [self removeFromSuperview];
//}

- (void)p_intct_clickText:(UIButton *)sender {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _closeBtn.frame = (CGRect){self.width - 32 - 14, self.height - 32 - 94 - kIphoneXBottomHeight, 32, 32};
    CGFloat begin = _closeBtn.top, vertical = 10, height = 32;
    NSUInteger count = _textBtns.count;
    
    [_textBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sizeToFit];
        obj.width += 20;
        obj.height = height;
        obj.bottom = begin - (vertical + (count - idx - 1) * (height + vertical));
        obj.right = self.width - 14;
    }];
}

- (instancetype)initWithTexts:(NSArray<NSString *> *)texts {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _texts = texts;
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _closeBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectZero;
//        [INTCTViewHelper intct_buttonWithFrame:CGRectZero
//                                                           bgImage:nil
//                                                             image:@"message_quickreply_close"
//                                                             title:nil
//                                                         textColor:nil
//                                                            method:nil
//                                                            target:nil];
        
        
        [self addSubview:button];
        button;
    });
    
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0; i < _texts.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(p_intct_clickText:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:_texts[i] forState:UIControlStateNormal];
        
//        [INTCTViewHelper intct_buttonWithFrame:CGRectZero
//                                                           bgImage:nil
//                                                             image:nil
//                                                             title:_texts[i]
//                                                         textColor:[UIColor color_46494d]
//                                                            method:@selector(p_intct_clickText:)
//                                                            target:self];
        button.layer.cornerRadius = 16;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.backgroundColor = [UIColor whiteColor];
        button.tag = 10 + i;
        [self addSubview:button];
        [array addObject:button];
    }
    _textBtns = [array copy];
}

@end
