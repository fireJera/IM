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
const int CTMSGMessageCellAvatarLeading = 10;

const int CTMSGMessageCellBubbleLeading = 14;
//const int CTMSGMessageCellBubbleMinWidth = 72;
const int CTMSGMessageCellBubbleMinWidth = 72;
const int CTMSGMessageCellBubbleMinHeight = 40;

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
    
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [self p_ctmsg_updateMsgCell];
}

- (void)p_ctmsg_updateMsgCell {
    
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

#pragma mark - notification

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {

}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
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
//    _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_portraitBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.baseContentView addSubview:_portraitBtn];
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
        [_messageFailedStatusView addTarget:self action:@selector(failedViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageFailedStatusView;
}

- (UIActivityIndicatorView *)messageActivityIndicatorView {
    if (!_messageActivityIndicatorView) {
        _messageActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
        [_portraitBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.baseContentView addSubview:_portraitBtn];
    }
    return _portraitBtn;
}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[CTMSGContentView alloc] initWithFrame:CGRectMake(CTMSGMessageCellBubbleLeading, CTMSGMessageCellAvatarLeading, CTMSGMessageCellBubbleMinWidth, CTMSGMessageCellBubbleMinHeight)];
        [self.baseContentView addSubview:_messageContentView];
    }
    return _messageContentView;
}

- (UIImageView *)bubbleBackgroundView {
    if (!_bubbleBackgroundView) {
        _bubbleBackgroundView = [[UIImageView alloc] init];
        _bubbleBackgroundView.userInteractionEnabled = YES;
        [self.messageContentView insertSubview:_bubbleBackgroundView atIndex:0];
//        [self.messageContentView addSubview:_bubbleBackgroundView];
    }
    return _bubbleBackgroundView;
}

- (UIImageView *)lockImageView {
    if (!_lockImageView) {
        _lockImageView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:@""]];
        [self.bubbleBackgroundView addSubview:_lockImageView];
    }
    return _lockImageView;
}

- (UILabel *)lockLable {
    if (!_lockLable) {
        _lockLable = [[UILabel alloc] init];
        _lockLable.textColor = [UIColor whiteColor];
        _lockLable.font = [UIFont systemFontOfSize:16];
        [self.bubbleBackgroundView addSubview:_lockLable];
    }
    return _lockLable;
}

@end
