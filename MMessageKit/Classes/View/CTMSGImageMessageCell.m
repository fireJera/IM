//
//  CTMSGImageMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGImageMessageCell.h"
#import "CTMSGMessageModel.h"
//#import "CTMSGImageMessage.h"
#import <MessageLib/CTMSGImageMessage.h>
#import "CTMSGContentView.h"
#import "CTMSGImageMessageProgressView.h"
#import "CTMSGUtilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

//#if __has_include (<UIImageView+WebCache.h>)
//#import <UIImageView+WebCache.h>
//#else
//#import "UIImageView+WebCache.h"
//#endif

const int CTMSGImageMessageCellMaxWidth = 200;
const int CTMSGImageMessageCellMinWidth = 120;
const int CTMSGImageMessageCellMaxHeight = 200;
const int CTMSGImageMessageCellMinHeight = 120;

@interface CTMSGImageMessageCell () <BubbleImageViewMenuDelegate> {
    CAShapeLayer * _cornerLayer;
}

@end

@implementation CTMSGImageMessageCell

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CTMSGImageMessage *message = (CTMSGImageMessage *)model.content;
    CGSize size = [self getCellSize:message];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
    return (CGSize){collectionViewWidth, extraHeight};
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [self p_ctmsg_updateCell];
    [self updateStatusContentView:model];
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGImageMessageTypeIdentifier]) {
        CTMSGImageMessage * message = (CTMSGImageMessage *)self.model.content;
        if (message.thumbnailImage) {
            _pictureView.image = message.thumbnailImage;
        } else {
            [_pictureView sd_setImageWithURL:[NSURL URLWithString:message.thumbnailURL] placeholderImage:[CTMSGUtilities imageForNameInBundle:@"chat_mesage_kit_avatar"]];
        }
        [self p_ctmsg_updateFrame];
    }
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CTMSGImageMessage * message = (CTMSGImageMessage *)self.model.content;
    CGSize contentViewSize = [[self class] getCellSize:message];
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    _pictureView.frame = (CGRect){0, 0, contentViewSize};
    messageContentViewRect.size = contentViewSize;
    //拉伸图片
    UIRectCorner corner;
    if (self.messageDirection == CTMSGMessageDirectionSend) {
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading) - CTMSGMessageCellAvatarWith - CTMSGMessageCellAvatarLeading;
        corner = (UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight);
    } else {
        corner = (UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight);
        messageContentViewRect.origin.x = CTMSGMessageCellBubbleLeading + CTMSGMessageCellAvatarWith + CTMSGMessageCellAvatarLeading;
    }
    self.messageContentView.frame = messageContentViewRect;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.messageContentView.bounds
                                                byRoundingCorners:corner
                                                      cornerRadii:CGSizeMake(10, 10)];
    _cornerLayer.path = path.CGPath;
    self.messageContentView.layer.mask = _cornerLayer;
}

- (void)updateStatusContentView:(CTMSGMessageModel *)model {
    [super updateStatusContentView:model];
    if (model.sentStatus == SentStatus_SENDING) {
        self.progressView.frame = self.messageContentView.bounds;
    }
    else if (model.sentStatus == SentStatus_FAILED) {
        self.progressView.label.text = @"上传失败";
        [self.messageContentView addSubview:_progressView];
    }
    else if (model.sentStatus == SentStatus_SENT) {
        [_progressView removeFromSuperview];
    }
    _progressView.frame = self.messageContentView.bounds;
    self.progressView.label.center = (CGPoint){_progressView.bounds.size.width / 2, _progressView.bounds.size.height / 2};
}

#pragma mark - BubbleImageViewMenuDelegate

- (void)bubbleMenuClickDelete {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCellMenuDelete:)]) {
        [self.delegate didTapMessageCellMenuDelete:self.model];
    }
}

#pragma mark - touch event
- (void)tapImage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.pictureView];
    }
}

#pragma mark - notification

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
    [super messageCellUpdateSendingStatusEvent:notification];
    NSDictionary * dic = notification.object;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        long messageId = [dic[@"messageId"] longValue];
        CTMSGSentStatus status = [dic[@"status"] unsignedIntegerValue];
        NSInteger progress = [dic[@"progress"] integerValue];
        if (self.model.messageId == messageId) {
            self.model.sentStatus = status;
            if (status == SentStatus_SENDING) {
                [self.progressView updateProgress:progress];
            }
            [self updateStatusContentView:self.model];
        }
    }
}

+ (CGSize)getCellSize:(CTMSGImageMessage *)message {
    float messageRate = (float)CTMSGImageMessageCellMaxWidth / (float)CTMSGImageMessageCellMaxHeight;
    float imageRate;
    CGSize imageSize;
    if (message.thumbnailImage) {
        imageRate = message.thumbnailImage.size.width / message.thumbnailImage.size.height;
        imageSize = message.thumbnailImage.size;
    } else {
        imageRate = message.imageSize.width / message.imageSize.height;
        imageSize = message.imageSize;
    }
    CGSize bubbleSize;
    if (imageSize.width < CTMSGImageMessageCellMaxWidth && imageSize.height < CTMSGImageMessageCellMaxHeight) {
        bubbleSize = imageSize;
    } else if (messageRate > imageRate) {
        CGFloat realWidth = CTMSGImageMessageCellMaxHeight * imageRate;
        realWidth = MAX(CTMSGImageMessageCellMinWidth, realWidth);
        bubbleSize = (CGSize){realWidth, CTMSGImageMessageCellMaxHeight};
    } else {
        CGFloat realHeight = CTMSGImageMessageCellMaxWidth / imageRate;
        realHeight = MAX(CTMSGImageMessageCellMinHeight, realHeight);
        bubbleSize = (CGSize){CTMSGImageMessageCellMaxWidth, realHeight};
    }
    return bubbleSize;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self p_ctmsg_initImageView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_ctmsg_initImageView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self p_ctmsg_initImageView];
}

- (void)p_ctmsg_initImageView {
//    _pictureView = [[UIImageView alloc] init];
    _pictureView = [[CTMSGBubbleImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:CTMSGDefaultAvatar]];
    _pictureView.contentMode = UIViewContentModeScaleAspectFill;
    _pictureView.clipsToBounds = YES;
    _pictureView.delegate = self;
    _pictureView.userInteractionEnabled = YES;
    [self.messageContentView addSubview:_pictureView];
    _cornerLayer = [CAShapeLayer layer];
//    self.messageContentView.layer.mask = _cornerLayer;
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [_pictureView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *voiceTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    voiceTap.numberOfTapsRequired = 1;
    voiceTap.numberOfTouchesRequired = 1;
    [_pictureView addGestureRecognizer:voiceTap];
}

- (CTMSGImageMessageProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CTMSGImageMessageProgressView alloc] init];
        _progressView.userInteractionEnabled = NO;
        [self.messageContentView addSubview:_progressView];
    }
    return _progressView;
}

@end
