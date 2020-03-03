//
//  CTMSGEmojiBoardView.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGEmojiBoardView.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGUtilities.h"

@interface CTMSGEmojiBoardView ()

@property (nonatomic, strong) NSMutableArray<UIButton *> * emojiBtns;
@property (nonatomic, strong) NSArray<NSArray *> * internalEmojis;
@property (nonatomic, strong) CALayer * bottomLineLayer;

@end

@implementation CTMSGEmojiBoardView

#pragma mark - layout

- (void)layoutSubviews {
    CGFloat selfWidth = self.bounds.size.width, selfHeight = self.bounds.size.height;
    CGFloat bottomHeight = 44;
    _emojiBackgroundView.frame = (CGRect){0, 0, selfWidth, selfHeight - bottomHeight};
    
    CGFloat pageWidth = 60, pageHeight = 20, pageBottom = 8;
    CGFloat pageTop = _emojiBackgroundView.frame.size.height - pageHeight - pageBottom;
    CGFloat pageLeft = (selfWidth  - pageWidth) / 2;
    _emojiPageControl.frame = (CGRect){pageLeft, pageTop, pageWidth, pageHeight};
    
    CGFloat delWidth = 24, delHeight = 24, delBottom = 32, delRight = 14;
    CGFloat delTop = _emojiBackgroundView.frame.size.height - delHeight - delBottom;
    CGFloat delLeft = selfWidth  - delWidth - delRight;
    _emojiDeleteBtn.frame = (CGRect){delLeft, delTop, delWidth, delHeight};
    
    _emojiBottomView.frame = (CGRect){0, selfHeight - bottomHeight, selfWidth, bottomHeight};
    _bottomLineLayer.frame = (CGRect){0, 0 , selfWidth, 1};
    CGFloat sendWidth = 52, sendHeight = 26, sendRight = 14;
    CGFloat sendLeft = selfWidth - sendWidth - sendRight, sendTop = (bottomHeight - sendHeight) / 2;
    _emojiSendBtn.frame = (CGRect){sendLeft, sendTop, sendWidth, sendHeight};
    if (!_emojiBtns || _emojiBtns.count == 0) {
        [self p_ctmsg_setEmoji];
    }
}

#pragma mark - touch event

- (void)touchEmoji:(UIButton *)sender {
    int outIdx = (int)(sender.tag  / 100);
    int inIdx = (int)(sender.tag  % 100);
    if (outIdx < _internalEmojis.count) {
        NSArray * array = _internalEmojis[outIdx];
        if (inIdx < array.count) {
            NSString * str = array[inIdx];
            if ([_delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)]) {
                [_delegate didTouchEmojiView:self touchedEmoji:str];
            }
        }
    }
}

- (void)deleteEmoji:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didRemoveEmojiView:)]) {
        [_delegate didRemoveEmojiView:self];
    }
}

- (void)sendEmoji:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didSendButtonEvent:sendButton:)]) {
        [_delegate didSendButtonEvent:self sendButton:sender];
    }
}

#pragma mark - public

- (void)loadLabelView {
    
}

- (void)enableSendButton:(BOOL)sender {
    _emojiSendBtn.enabled = sender;
    if (sender) {
        [_emojiSendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _emojiSendBtn.backgroundColor = [UIColor blueColor];
    } else {
        [_emojiSendBtn setTitleColor:[UIColor ctmsg_colorB1B1B1] forState:UIControlStateNormal];
        _emojiSendBtn.backgroundColor = [UIColor ctmsg_colorD9D9D9];
    }
}

- (void)addEmojiTab:(id<CTMSGEmoticonTabSource>)viewDataSource {
    
}

- (void)addExtensionEmojiTab:(id<CTMSGEmoticonTabSource>)viewDataSource {
    
}

- (void)setCurrentIndex:(int)index withTotalPages:(int)totalPageNum {
    
}

- (void)reloadExtensionEmoticonTabSource {
    
}

#pragma mark - UIScrollViewDelegate
//滚动时-调动多次
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}
////将要滑动
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//
//}
////手指离开停止滑动
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//
//}
////滑动减速
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//
//}
////滑动停止
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//
//}
//
////手指离开
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//
//}

#pragma mark - private

- (void)p_ctmsg_setEmoji {
    _emojiPageControl.numberOfPages = _internalEmojis.count;
    _emojiBackgroundView.contentSize = CGSizeMake(_emojiBackgroundView.bounds.size.width * _internalEmojis.count, _emojiBackgroundView.bounds.size.height);
    
    int row = 3, column = 9, left = 10, horizon = 6, vertical = 6, top = 10;
    CGFloat scrollWidth = _emojiBackgroundView.bounds.size.width;
    CGFloat width = (_emojiBackgroundView.bounds.size.width - left * 2 - (column - 1) * horizon) / column;
    CGFloat height = (_emojiBackgroundView.bounds.size.height - top * 2 - (row - 1) * vertical) / row;
    [_internalEmojis enumerateObjectsUsingBlock:^(NSArray * _Nonnull array, NSUInteger outIdx, BOOL * _Nonnull stop) {
        [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger inIdx, BOOL * _Nonnull stop) {
            UIButton * button = ({
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn addTarget:self action:@selector(touchEmoji:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = outIdx * 100 + inIdx;
                [btn setTitle:obj forState:UIControlStateNormal];
                CGFloat btnLeft = (scrollWidth * outIdx) + (left + (width + horizon) * (inIdx % 9));
                CGFloat btnTop = (top + (height + vertical) * (inIdx / 9));
                btn.frame = (CGRect){btnLeft, btnTop, width, height};
                [_emojiBtns addObject:btn];
                btn;
            });
            [_emojiBackgroundView addSubview:button];
        }];
    }];
    
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<CTMSGEmojiViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        [self p_commonInit];
    }
    return self;
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
    _emojiBackgroundView = [[UIScrollView alloc] init];
    _emojiBackgroundView.showsHorizontalScrollIndicator = NO;
    _emojiBackgroundView.showsVerticalScrollIndicator = NO;
    _emojiBackgroundView.pagingEnabled = YES;
    [self addSubview:_emojiBackgroundView];
    
    _emojiPageControl = [[UIPageControl alloc] init];
    [self addSubview:_emojiPageControl];
    
    _emojiBottomView = [[UIView alloc] init];
    [self addSubview:_emojiBottomView];
    
    _bottomLineLayer = [CALayer layer];
    _bottomLineLayer.backgroundColor = [UIColor ctmsg_colorF2F2F2].CGColor;
    [_emojiBottomView.layer addSublayer:_bottomLineLayer];
    
    _emojiSendBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(sendEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"发送" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor ctmsg_colorB1B1B1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.backgroundColor = [UIColor ctmsg_colorD9D9D9];
        [_emojiBottomView addSubview:button];
        button;
    });
    
    _emojiDeleteBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_del_n"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    _emojiBtns = [NSMutableArray array];
    
    _internalEmojis = @[
                        @[@"😃", @"😀", @"😊", @"😉", @"😍", @"😘", @"😗", @"😗", @"😜",
                          @"😝", @"😳", @"😁", @"😔", @"😌", @"😒", @"😟", @"😞", @"😣",
                          @"😢", @"😂", @"😭", @"😪", @"😰", @"😅", @"😓", @"😫"],
                        
                        @[@"😩", @"😨", @"😱", @"😡", @"😤", @"😖", @"😆", @"😋", @"😷",
                          @"😎", @"😴", @"😲", @"😵", @"😈", @"👿", @"😯", @"😬", @"😕",
                          @"😶", @"😇", @"😉", @"🙄", @"🙈", @"🙉", @"🙊", @"👽"],
                        
                        @[@"💩", @"💔", @"🔥", @"💢", @"💤", @"🚫", @"⭐", @"⚡", @"🌙",
                          @"☀️", @"🌥️", @"☁️", @"❄️", @"☔", @"⛄", @"👍", @"👎", @"👌",
                          @"👊", @"✊", @"✌️", @"🤟", @"🙏", @"☝️", @"👏", @"💪"],
                        
                        @[@"👪", @"👫", @"👼", @"🐴", @"🐶", @"🐷", @"👻", @"🌹", @"🌻",
                          @"🌲", @"🍀", @"🎁", @"🎉", @"💰", @"🎂", @"🍖", @"🍚", @"🍦",
                          @"🍫", @"🍉", @"🍷", @"🍻", @"🍵", @"🏀", @"⚽", @"⛷️"],
                        
                        @[@"🎤", @"🎵", @"🎲", @"🀄", @"👑", @"💄", @"💋", @"💍", @"📚",
                          @"🎓", @"✏️", @"🏡", @"🚿", @"💡", @"📞", @"📢", @"🕖", @"⏰",
                          @"⏳", @"💣", @"🔫", @"💊", @"🚀", @"🌏"],
                        ];
//    [self p_ctmsg_setEmoji];
    //    @property(nonatomic, strong) UIScrollView *emojiBackgroundView;
    //    @property(nonatomic, strong) UIView *emojiBottomView;
    //    @property(nonatomic, strong) UIButton *emojiSendBtn;
    //    @property(nonatomic, strong) UIPageControl *emojiPageControl;
    //    @property(nonatomic, strong) UIButton *emojiDeleteBtn;
}
    
    
@end
