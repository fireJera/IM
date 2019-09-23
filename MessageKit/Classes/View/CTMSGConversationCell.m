//
//  CTMSGConversationCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGConversationCell.h"
#import <MessageLib/CTMSGEnumDefine.h>
#import "CTMSGConversationModel.h"
#import "CTMSGMessageContent.h"
#import "CTMSGUserInfo.h"
#import "CTMSGUtilities.h"
#import "UIColor+CTMSG_Hex.h"
//#import "UIButton+WebCache.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface CTMSGConversationCell ()

@property (nonatomic, strong) CTMSGConversationModel * model;
//@property (nonatomic, strong) UIImage * animateImage;

@end

@implementation CTMSGConversationCell

@synthesize model = _model;

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - setter

//- (void)setShowTopTag:(BOOL)showTopTag {
//    _showTopTag = showTopTag;
//    _topTagImageView.hidden = !showTopTag;
//}

//- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor {
//    _cellBackgroundColor = cellBackgroundColor;
//
//}
//
//- (void)setTopCellBackgroundColor:(UIColor *)topCellBackgroundColor {
//    _topCellBackgroundColor = topCellBackgroundColor;
//}

- (void)setModel:(CTMSGConversationModel *)model {
    _model = model;
    [self p_ctmsg_updateCell];
}

- (void)p_ctmsg_updateCell {
    _topTagImageView.hidden = !_model.isTop;
//    if (_model.lastestMessageDirection == CTMSGMessageDirectionReceive) {
//        _conversationTitle.text = _model.lastestMessage.senderUserInfo.name;
//        _conversationTitle.text = _model.targetId;
//        [_conversationTitle sizeToFit];
//    } else {
//        _conversationTitle.text = _model.targetId;
//        [_conversationTitle sizeToFit];
//    }
    
    _messageContentLabel.text = _model.lastestMessage.conversationDigest;
    _unreadBGLayer.hidden = _model.unreadMessageCount == 0;
    _unreadCountLabel.hidden = _model.unreadMessageCount == 0;
    _unreadCountLabel.text = [NSString stringWithFormat:@"%d", (int)_model.unreadMessageCount];
    [_unreadCountLabel sizeToFit];
    [_avatarBtn sd_setImageWithURL:[NSURL URLWithString:_model.lastestMessage.senderUserInfo.portraitUri] forState:UIControlStateNormal];
    _messageCreatedTimeLabel.text = _model.showTime;
    [_messageCreatedTimeLabel sizeToFit];
    _conversationTitle.text = _model.lastestMessage.senderUserInfo.name;
    [_conversationTitle sizeToFit];
    _messageContentLabel.text = _model.conversationTitle;
    [_messageContentLabel sizeToFit];
//    _avatarAnimate.image = _animateImage;
    _avatarAnimate.hidden = !_model.isTop;
}

#pragma mark - touch event

- (void)clickAvatar:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didTapCellAvatar:)]) {
        [_delegate didTapCellAvatar:_model];
    }
}

#pragma mark - init

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    CGFloat left = 10, top = 5, avatarLeft = 14, avatarWidth = 48, nameLeft = 14, tRight = 14; // timeRight
    _detailContentView.frame = (CGRect){left, top, selfWidth - left * 2, selfHeight - top * 2};
    _avatarBackgroundView.frame = (CGRect){avatarLeft, (_detailContentView.frame.size.height - avatarWidth) / 2, avatarWidth, avatarWidth};
    _avatarBtn.frame = _avatarBackgroundView.bounds;
    
    CGFloat timeLeft = _detailContentView.frame.size.width - _messageCreatedTimeLabel.frame.size.width - tRight;
    _messageCreatedTimeLabel.frame = (CGRect){timeLeft, _avatarBackgroundView.frame.origin.y, _messageCreatedTimeLabel.frame.size.width, _messageCreatedTimeLabel.frame.size.height};
    
    CGFloat titleLeft = _avatarBackgroundView.frame.size.width + _avatarBackgroundView.frame.origin.x + nameLeft;
    CGFloat titleWidth = timeLeft - titleLeft - tRight;
    titleWidth = MIN(_conversationTitle.frame.size.width, titleWidth);
    _conversationTitle.frame = (CGRect){titleLeft, _avatarBackgroundView.frame.origin.y, titleWidth, 20};
    CGFloat contentTop = _conversationTitle.frame.size.height + _avatarBackgroundView.frame.origin.y + 5;
    _messageContentLabel.frame = (CGRect){titleLeft, contentTop, _detailContentView.frame.size.width - 40 - titleLeft, _messageContentLabel.frame.size.height};
    
    CGFloat bgWidth = MAX(_unreadCountLabel.frame.size.width, _unreadCountLabel.frame.size.height);
    CGFloat bgTop = _messageContentLabel.frame.origin.y + (_messageContentLabel.frame.size.height - bgWidth) / 2;
    CGFloat bgLeft = _detailContentView.frame.size.width - bgWidth - tRight;
    _unreadBGLayer.frame = (CGRect){bgLeft, bgTop, bgWidth, bgWidth};
    _unreadBGLayer.cornerRadius = bgWidth / 2;
    
    _unreadCountLabel.center = CGPointMake(CGRectGetMidX(_unreadBGLayer.frame) , CGRectGetMidY(_unreadBGLayer.frame));
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    _showTopTag = NO;
    self.contentView.backgroundColor = [UIColor ctmsg_color_f7f7f7];
    _detailContentView = [[UIView alloc] init];
    _detailContentView.backgroundColor = [UIColor whiteColor];
    _detailContentView.layer.cornerRadius = 8;
    [self.contentView addSubview:_detailContentView];
    _avatarBackgroundView = [[UIView alloc] init];
    [_detailContentView addSubview:_avatarBackgroundView];
    _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_avatarBtn setImage:[CTMSGUtilities imageForNameInBundle:CTMSGDefaultAvatar] forState:UIControlStateNormal];
    _avatarBtn.backgroundColor = [UIColor ctmsg_colorB6B6B6];
    _avatarBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_avatarBtn addTarget:self action:@selector(clickAvatar:) forControlEvents:UIControlEventTouchUpInside];
    _avatarBtn.layer.cornerRadius = 24;
    _avatarBtn.layer.masksToBounds = YES;
    [_avatarBackgroundView addSubview:_avatarBtn];
    
    _avatarAnimate = [[UIImageView alloc] init];
    _avatarAnimate.frame = (CGRect){0, 0, 76, 76};
//    _avatarAnimate.backgroundColor = [UIColor blackColor];
    _avatarAnimate.contentMode = UIViewContentModeScaleAspectFill;
    _avatarAnimate.image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chatlist_vip"];
    [_detailContentView addSubview:_avatarAnimate];
//    [_avatarBackgroundView addSubview:_avatarAnimate];
    _conversationTitle = [[UILabel alloc] init];
    _conversationTitle.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    _conversationTitle.textColor = [UIColor ctmsg_color4C4C4C];
    [_detailContentView addSubview:_conversationTitle];
    _messageContentLabel = [[UILabel alloc] init];
    _messageContentLabel.font = [UIFont systemFontOfSize:14];
    _messageContentLabel.textColor = [UIColor ctmsg_colorB1B1B1];
    [_detailContentView addSubview:_messageContentLabel];
    _messageCreatedTimeLabel = [[UILabel alloc] init];
    _messageCreatedTimeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    _messageCreatedTimeLabel.textColor = [UIColor ctmsg_colorB1B1B1];
    [_detailContentView addSubview:_messageCreatedTimeLabel];
    _unreadBGLayer = [CALayer layer];
    _unreadBGLayer.backgroundColor = [UIColor redColor].CGColor;
    [_detailContentView.layer addSublayer:_unreadBGLayer];
    _unreadCountLabel = [[UILabel alloc] init];
    _unreadCountLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
    _unreadCountLabel.textColor = [UIColor whiteColor];
    [_detailContentView addSubview:_unreadCountLabel];
    _topTagImageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_chatlist_top"]];
    _topTagImageView.frame = CGRectMake(15, 0, 12, 12);
    [_detailContentView addSubview:_topTagImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
