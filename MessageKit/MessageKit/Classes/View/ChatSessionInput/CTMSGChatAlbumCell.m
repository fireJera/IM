//
//  CTMSGChatAlbumCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatAlbumCell.h"
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGUtilities.h"
#import "CTMSGPhotoModel.h"

@implementation CTMSGChatAlbumCell

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat padding = 10, width = 24, left = selfWidth - padding - width;
    _pickBtn.frame = (CGRect){left, padding, width, width};
}

- (void)pickPhoto:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if ([_delegate respondsToSelector:@selector(cellDidSelectedBtnClick:model:)]) {
        [_delegate cellDidSelectedBtnClick:self model:_model];
    }
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

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)p_commonInit {
    _imageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:CTMSGDefaultAvatar]];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
//    self.clipsToBounds = YES;
    _pickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_pickBtn setBackgroundImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_checkbox_n"] forState:UIControlStateNormal];
    [_pickBtn setBackgroundImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_checkbox_s"] forState:UIControlStateSelected];
//    [_pickBtn setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_checkbox_n"] forState:UIControlStateNormal];
//    [_pickBtn setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_checkbox_s"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [_pickBtn addTarget:self action:@selector(pickPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_pickBtn];
}

@end
