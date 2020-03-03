//
//  CTMSGConversationCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGConversationCell.h"
#import "CTMSGEnumDefine.h"
#import "CTMSGConversationModel.h"
#import "CTMSGMessageContent.h"
#import "CTMSGUserInfo.h"
#import "CTMSGUtilities.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIFont+CTMSG_Font.h"

@interface CTMSGConversationCell ()

@property (nonatomic, strong) CTMSGConversationModel * model;

@end

@implementation CTMSGConversationCell

@synthesize model = _model;

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - setter

- (void)setShowTopTag:(BOOL)showTopTag {
    _showTopTag = showTopTag;
    _topTagImageView.hidden = !showTopTag;
}

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
    if (_showTopTag) {
        _topTagImageView.hidden = !_model.isTop;
    } else {
        _topTagImageView.hidden = YES;
    }
//    if (_model.lastestMessageDirection == CTMSGMessageDirectionReceive) {
//        _conversationTitle.text = _model.lastestMessage.senderUserInfo.name;
//        _conversationTitle.text = _model.targetId;
//        [_conversationTitle sizeToFit];
//    } else {
//        _conversationTitle.text = _model.targetId;
//        [_conversationTitle sizeToFit];
//    }
    
    _messageContentLabel.text = _model.lastestMessage.conversationDigest;
    [_messageContentLabel sizeToFit];
    _messageCreatedTimeLabel.text = [CTMSGUtilities timeStrConvetedByMiseSeconds:_model.receivedTime];
    [_messageCreatedTimeLabel sizeToFit];
    _unreadBGLayer.hidden = _model.unreadMessageCount == 0;
    _unreadCountLabel.hidden = _model.unreadMessageCount == 0;
    _unreadCountLabel.text = [NSString stringWithFormat:@"%d", (int)_model.unreadMessageCount];
    [_unreadCountLabel sizeToFit];
}

#pragma mark - touch event

- (void)clickAvatar:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didTapCellAvatar:)]) {
        [_delegate didTapCellAvatar:_model];
    }
}

#pragma mark - init

- (void)layoutSubviews {
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    CGFloat left = 10, top = 5, avatarLeft = 14, avatarWidth = 48, nameLeft = 14, tRight = 14; // timeRight
    _detailContentView.frame = (CGRect){left, top, selfWidth - left * 2, selfHeight - top * 2};
    _avatarBackgroundView.frame = (CGRect){avatarLeft, (_detailContentView.frame.size.height - avatarWidth) / 2, avatarWidth, avatarWidth};
    _avatarBtn.frame = _avatarBackgroundView.bounds;
    CGFloat titleLeft = _avatarBackgroundView.frame.size.width + _avatarBackgroundView.frame.origin.x + nameLeft;
    _conversationTitle.frame = (CGRect){titleLeft, _avatarBackgroundView.frame.origin.y, _conversationTitle.frame.size.width, _conversationTitle.frame.size.height};
    
    //TODO: - _conversationTitle & _messageContentLabel max width
    CGFloat contentTop = _conversationTitle.frame.size.height + _avatarBackgroundView.frame.origin.y + 5;
    _messageContentLabel.frame = (CGRect){titleLeft, contentTop, _messageContentLabel.frame.size.width, _messageContentLabel.frame.size.height};
    CGFloat timeLeft = _detailContentView.frame.size.width - _messageCreatedTimeLabel.frame.size.width - tRight;
    _messageCreatedTimeLabel.frame = (CGRect){timeLeft, _conversationTitle.frame.origin.y, _messageCreatedTimeLabel.frame.size.width, _messageCreatedTimeLabel.frame.size.height};
    
    CGFloat bgWidth = MAX(_unreadCountLabel.frame.size.width, _unreadCountLabel.frame.size.height);
    CGFloat bgTop =  _messageContentLabel.frame.origin.y + (_messageContentLabel.frame.size.height - bgWidth) / 2;
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
    _showTopTag = NO;
    self.contentView.backgroundColor = [UIColor ctmsg_themeGrayColor];
    _detailContentView = [[UIView alloc] init];
    _detailContentView.backgroundColor = [UIColor whiteColor];
    _detailContentView.layer.cornerRadius = 4;
    _topTagImageView = [[UIImageView alloc] initWithImage:nil];
    [_detailContentView addSubview:_topTagImageView];
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
    _conversationTitle = [[UILabel alloc] init];
    _conversationTitle.font = [UIFont ctmsg_PingFangSemboldWithSize:16];
    _conversationTitle.textColor = [UIColor ctmsg_color4C4C4C];
    [_detailContentView addSubview:_conversationTitle];
    _messageContentLabel = [[UILabel alloc] init];
    _messageContentLabel.font = [UIFont systemFontOfSize:14];
    _messageContentLabel.textColor = [UIColor ctmsg_colorB1B1B1];
    [_detailContentView addSubview:_messageContentLabel];
    _messageCreatedTimeLabel = [[UILabel alloc] init];
    _messageCreatedTimeLabel.font = [UIFont ctmsg_PingFangMedium14];
    _messageCreatedTimeLabel.textColor = [UIColor ctmsg_colorB1B1B1];
    [_detailContentView addSubview:_messageCreatedTimeLabel];
    _unreadBGLayer = [CALayer layer];
    _unreadBGLayer.backgroundColor = [UIColor redColor].CGColor;
    [_detailContentView.layer addSublayer:_unreadBGLayer];
    _unreadCountLabel = [[UILabel alloc] init];
    _unreadCountLabel.font = [UIFont ctmsg_PingFangMedium10];
    _unreadCountLabel.textColor = [UIColor whiteColor];
    [_detailContentView addSubview:_unreadCountLabel];
    _topTagImageView = [[UIImageView alloc] initWithImage:nil];
    [_detailContentView addSubview:_topTagImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
