//
//  CTMSGMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageCell.h"
//#import "CTMSGMessageModel.h"
#import "CTMSGContentView.h"
#import "CTMSGUtilities.h"

const int HeadAndContentSpacing = 6;
const int CTMSGMessageCellAvatarWith = 40;
const int CTMSGMessageCellAvatarLeading = 14;

const int CTMSGMessageCellBubbleLeading = 10;
//const int CTMSGMessageCellBubbleMinWidth = 72;
const int CTMSGMessageCellBubbleMinWidth = 48;
const int CTMSGMessageCellBubbleMinHeight = 40;

@interface CTMSGMessageCell () <BubbleImageViewMenuDelegate>

@end

@implementation CTMSGMessageCell

//@synthesize model = _model;
//@synthesize delegate = _delegate;
//@synthesize messageDirection = _messageDirection;
//@synthesize messageTimeLabel = _messageTimeLabel;
//@synthesize baseContentView = _baseContentView;

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    return (CGSize){collectionViewWidth, extraHeight};
}

- (void)updateStatusContentView:(CTMSGMessageModel *)model {
    [_messageActivityIndicatorView stopAnimating];
    if (model.sentStatus == SentStatus_SENDING) {
        self.messageActivityIndicatorView.hidden = NO;
        [_messageActivityIndicatorView startAnimating];
        _messageFailedStatusView.hidden = YES;
    }
    else if (model.sentStatus == SentStatus_FAILED) {
        _messageActivityIndicatorView.hidden = YES;
        self.messageFailedStatusView.hidden = NO;
    }
    else if (model.sentStatus == SentStatus_SENT) {
        _messageActivityIndicatorView.hidden = YES;
        _messageFailedStatusView.hidden = YES;
//        return;
    }
    if (model.messageDirection == CTMSGMessageDirectionSend) {
        _portraitBtn.frame = (CGRect){self.baseContentView.frame.size.width - CTMSGMessageCellAvatarLeading - CTMSGMessageCellAvatarWith, 10, CTMSGMessageCellAvatarWith, CTMSGMessageCellAvatarWith};
        CGFloat failedLeft = _messageContentView.frame.origin.x - 10 - _messageFailedStatusView.frame.size.width;
        CGFloat failedTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - _messageFailedStatusView.frame.size.height) / 2);
        _messageFailedStatusView.frame = CGRectMake(failedLeft, failedTop, _messageFailedStatusView.frame.size.width, _messageFailedStatusView.frame.size.height);
        CGFloat indiWidth = 20;
        CGFloat indiLeft = _messageContentView.frame.origin.x - 10 - indiWidth;
        CGFloat indiTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - indiWidth) / 2);
        _messageActivityIndicatorView.frame = CGRectMake(indiLeft, indiTop, indiWidth, indiWidth);
    }
    else {
        _portraitBtn.frame = (CGRect){CTMSGMessageCellAvatarLeading, 10, CTMSGMessageCellAvatarWith, CTMSGMessageCellAvatarWith};
        CGFloat left = _messageContentView.frame.origin.x + _messageContentView.frame.size.width + 10;
        CGFloat failedTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - _messageFailedStatusView.frame.size.height) / 2);
        _messageFailedStatusView.frame = CGRectMake(left, failedTop, _messageFailedStatusView.frame.size.width, _messageFailedStatusView.frame.size.height);
        CGFloat indiWidth = 20;
        CGFloat indiTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - indiWidth) / 2);
        _messageActivityIndicatorView.frame = CGRectMake(left, indiTop, indiWidth, indiWidth);
    }
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [self p_ctmsg_updateMsgCell];
}

- (void)p_ctmsg_updateMsgCell {
    [self updateStatusContentView:self.model];
}

#pragma mark - touch event

- (void)failedViewClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)avatarClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didTapCellPortrait:)]) {
        if (self.model.messageDirection == CTMSGMessageDirectionSend) {
            [self.delegate didTapCellPortrait:self.model.senderUserId];
        }
        else {
            [self.delegate didTapCellPortrait:self.model.targetId];
        }
    }
}

#pragma mark - BubbleImageViewMenuDelegate

- (void)bubbleMenuClickDelete {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCellMenuDelete:)]) {
        [self.delegate didTapMessageCellMenuDelete:self.model];
    }
}

- (void)bubbleMenuClickCopy {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCellMenuCopy:)]) {
        [self.delegate didTapMessageCellMenuCopy:self.model];
    }
}

#pragma mark - notification

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
    [super messageCellUpdateSendingStatusEvent:notification];
//    NSDictionary * dic = notification.object;
//    if ([dic isKindOfClass:[NSDictionary class]]) {
//        long messageId = [dic[@"messageId"] longValue];
//        CTMSGSentStatus status = [dic[@"status"] unsignedIntegerValue];
//        if (self.model.messageId == messageId) {
//            self.model.sentStatus = status;
//            [self updateStatusContentView:self.model];
//        }
//    }
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.model.messageDirection == CTMSGMessageDirectionSend) {
        _portraitBtn.frame = (CGRect){self.baseContentView.frame.size.width - CTMSGMessageCellAvatarLeading - CTMSGMessageCellAvatarWith, 10, CTMSGMessageCellAvatarWith, CTMSGMessageCellAvatarWith};
        CGFloat failedLeft = _messageContentView.frame.origin.x - 10 - _messageFailedStatusView.frame.size.width;
        CGFloat failedTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - _messageFailedStatusView.frame.size.height) / 2);
        _messageFailedStatusView.frame = CGRectMake(failedLeft, failedTop, _messageFailedStatusView.frame.size.width, _messageFailedStatusView.frame.size.height);
        CGFloat indiWidth = 20;
        CGFloat indiLeft = _messageContentView.frame.origin.x - 10 - indiWidth;
        CGFloat indiTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - indiWidth) / 2);
        _messageActivityIndicatorView.frame = CGRectMake(indiLeft, indiTop, indiWidth, indiWidth);
    }
    else {
        _portraitBtn.frame = (CGRect){CTMSGMessageCellAvatarLeading, 10, CTMSGMessageCellAvatarWith, CTMSGMessageCellAvatarWith};
        CGFloat left = _messageContentView.frame.origin.x + _messageContentView.frame.size.width + 10;
        CGFloat failedTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - _messageFailedStatusView.frame.size.height) / 2);
        _messageFailedStatusView.frame = CGRectMake(left, failedTop, _messageFailedStatusView.frame.size.width, _messageFailedStatusView.frame.size.height);
        CGFloat indiWidth = 20;
        CGFloat indiTop = _messageContentView.frame.origin.y + ((_messageContentView.frame.size.height - indiWidth) / 2);
        _messageActivityIndicatorView.frame = CGRectMake(left, indiTop, indiWidth, indiWidth);
    }
//    CGFloat width = self.contentView.frame.size.width;
//    CGFloat height = self.contentView.frame.size.height;
//    if (_baseContentView) {
//        _baseContentView.frame = (CGRect){0, 0, width, height - 0};
//    }
//    _messageTimeLabel.center = (CGPoint){width / 2, height / 2};
}

#pragma mark - init
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (!self) return nil;
//    [self p_ctmsg_initView];
//    return self;
//}
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    [self p_ctmsg_initView];
//}

//- (void)p_ctmsg_initView {
////    _baseContentView = [[UIView alloc] init];
////    [self.contentView addSubview:_baseContentView];
//
////    _messageContentView = [[CTMSGContentView alloc] init];
////    [_baseContentView addSubview:_messageContentView];
//}

#pragma mark - lazy

//- (CTMSGTipLabel *)messageTimeLabel {
//    if (!_messageTimeLabel) {
//        _messageTimeLabel = [[CTMSGTipLabel alloc] init];
//    }
//    return _messageTimeLabel;
//}

- (UIView *)statusContentView {
    if (!_statusContentView) {
        _statusContentView = [[UIView alloc] init];
    }
    return _statusContentView;
}

- (UIButton *)messageFailedStatusView {
    if (!_messageFailedStatusView) {
        _messageFailedStatusView = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_neterror"];
        [_messageFailedStatusView setImage:image forState:UIControlStateNormal];
        _messageFailedStatusView.frame = (CGRect){0, 0, image.size};
        [_messageFailedStatusView addTarget:self action:@selector(failedViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.baseContentView addSubview:_messageFailedStatusView];
    }
    return _messageFailedStatusView;
}

- (UIActivityIndicatorView *)messageActivityIndicatorView {
    if (!_messageActivityIndicatorView) {
        _messageActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.baseContentView addSubview:_messageActivityIndicatorView];
    }
    return _messageActivityIndicatorView;
}

//- (UIView *)baseContentView {
//    if (!_baseContentView) {
//        _baseContentView = [[UIView alloc] init];
//        [self.contentView addSubview:_baseContentView];
//    }
//    return _baseContentView;
//}

- (UIView *)portraitBtn {
    if (!_portraitBtn) {
        _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitBtn setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_avatar"] forState:UIControlStateNormal];
        _portraitBtn.layer.cornerRadius = CTMSGMessageCellAvatarWith / 2;
        _portraitBtn.layer.masksToBounds = YES;
        [_portraitBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.baseContentView addSubview:_portraitBtn];
    }
    return _portraitBtn;
}

- (CTMSGContentView *)messageContentView {
    if (!_messageContentView) {
        CGFloat contentLeft = CTMSGMessageCellAvatarLeading + CTMSGMessageCellAvatarWith + CTMSGMessageCellBubbleLeading;
        _messageContentView = [[CTMSGContentView alloc] initWithFrame:CGRectMake(contentLeft, CTMSGMessageCellAvatarLeading, CTMSGMessageCellBubbleMinWidth, CTMSGMessageCellBubbleMinHeight)];
        [self.baseContentView addSubview:_messageContentView];
    }
    return _messageContentView;
}

- (UIImageView *)bubbleBackgroundView {
    if (!_bubbleBackgroundView) {
        self.portraitBtn.hidden = NO;
        _bubbleBackgroundView = [[CTMSGBubbleImageView alloc] init];
        _bubbleBackgroundView.userInteractionEnabled = YES;
        _bubbleBackgroundView.delegate = self;
        [self.messageContentView insertSubview:_bubbleBackgroundView atIndex:0];
//        [self.messageContentView addSubview:_bubbleBackgroundView];
    }
    return _bubbleBackgroundView;
}

//- (UIImageView *)lockImageView {
//    if (!_lockImageView) {
//        _lockImageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@""]];
//        [self.bubbleBackgroundView addSubview:_lockImageView];
//    }
//    return _lockImageView;
//}

//- (UILabel *)lockLable {
//    if (!_lockLable) {
//        _lockLable = [[UILabel alloc] init];
//        _lockLable.textColor = [UIColor whiteColor];
//        _lockLable.font = [UIFont systemFontOfSize:16];
//        [self.bubbleBackgroundView addSubview:_lockLable];
//    }
//    return _lockLable;
//}

@end
