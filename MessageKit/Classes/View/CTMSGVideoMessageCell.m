//
//  CTMSGVideoMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGVideoMessageCell.h"
#import "CTMSGMessageModel.h"
//#import "CTMSGVideoMessage.h"
#import <MessageLib/MessageLib-umbrella.h>
#import "CTMSGContentView.h"
#import "CTMSGImageMessageProgressView.h"
#import "CTMSGUtilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

const int CTMSGVideoMessageCellMaxWidth = 200;
const int CTMSGVideoMessageCellMinWidth = 120;
const int CTMSGVideoMessageCellMaxHeight = 200;
const int CTMSGVideoMessageCellMinHeight = 120;

@interface CTMSGVideoMessageCell () {
    CAShapeLayer * _cornerLayer;
}

@end

@implementation CTMSGVideoMessageCell

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CTMSGVideoMessage *message = (CTMSGVideoMessage *)model.content;
    CGSize size = [self getCellSize:message];
    
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
//    return (CGSize){collectionViewWidth, extraHeight};
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [self p_ctmsg_updateCell];
    [self updateStatusContentView:model];
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGVideoMessageTypeIdentifier]) {
        CTMSGVideoMessage * message = (CTMSGVideoMessage *)self.model.content;
        if (message.thumbnailImage) {
            _pictureView.image = message.thumbnailImage;
        } else {
            [_pictureView sd_setImageWithURL:[NSURL URLWithString:message.thumbnailURL]];
        }
        [self p_ctmsg_updateFrame];
    }
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CTMSGVideoMessage * message = (CTMSGVideoMessage *)self.model.content;
    CGSize contentViewSize = [[self class] getCellSize:message];
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    _pictureView.frame = (CGRect){0, 0, contentViewSize};
    messageContentViewRect.size = contentViewSize;
    //拉伸图片
    UIRectCorner corner;
    if (self.messageDirection == CTMSGMessageDirectionSend) {
        //
        //    } else {
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading);
        corner = (UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight);
    }
    else {
        corner = (UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight);
    }
    
    self.messageContentView.frame = messageContentViewRect;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.messageContentView.bounds
                                                byRoundingCorners:corner
                                                      cornerRadii:CGSizeMake(10, 10)];
    _palyIcon.center = (CGPoint){self.messageContentView.frame.size.width / 2, self.messageContentView.frame.size.height / 2};
    _cornerLayer.path = path.CGPath;
    self.messageContentView.layer.mask = _cornerLayer;
}

- (void)updateStatusContentView:(CTMSGMessageModel *)model {
    [super updateStatusContentView:model];
    _palyIcon.hidden = YES;
    if (model.sentStatus == SentStatus_SENDING) {
        self.progressView.frame = self.messageContentView.bounds;
    }
    else if (model.sentStatus == SentStatus_FAILED) {
        self.progressView.label.text = @"上传失败";
        [self.messageContentView addSubview:_progressView];
    }
    else if (model.sentStatus == SentStatus_SENT) {
        [_progressView removeFromSuperview];
        _palyIcon.hidden = NO;
    }
    _progressView.frame = self.messageContentView.bounds;
    self.progressView.label.center = (CGPoint){_progressView.bounds.size.width / 2, _progressView.bounds.size.height / 2};
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

+ (CGSize)getCellSize:(CTMSGVideoMessage *)message {
    float messageRate = (float)CTMSGVideoMessageCellMaxWidth / (float)CTMSGVideoMessageCellMaxHeight;
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
    if (imageSize.width < CTMSGVideoMessageCellMaxWidth && imageSize.height > CTMSGVideoMessageCellMaxHeight) {
        bubbleSize = imageSize;
    } else if (messageRate > imageRate) {
        CGFloat realWidth = CTMSGVideoMessageCellMaxHeight * imageRate;
        realWidth = MAX(CTMSGVideoMessageCellMinWidth, realWidth);
        bubbleSize = (CGSize){realWidth, CTMSGVideoMessageCellMaxHeight};
    } else {
        CGFloat realHeight = CTMSGVideoMessageCellMaxWidth / imageRate;
        realHeight = MAX(CTMSGVideoMessageCellMinHeight, realHeight);
        bubbleSize = (CGSize){CTMSGVideoMessageCellMaxWidth, realHeight};
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
    _pictureView = [[UIImageView alloc] initWithImage:[CTMSGUtilities imageForNameInBundle:CTMSGDefaultAvatar]];
    _pictureView.contentMode = UIViewContentModeScaleAspectFill;
    _pictureView.userInteractionEnabled = YES;
    [self.messageContentView addSubview:_pictureView];
    _cornerLayer = [CAShapeLayer layer];
    //    self.messageContentView.layer.mask = _cornerLayer;
    UIImage * image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_voice_play_n"];
    _palyIcon = [[UIImageView alloc] initWithImage:image];
    _palyIcon.frame = (CGRect){0, 0, image.size};
    [self.messageContentView addSubview:_palyIcon];
    
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
    }
    return _progressView;
}
@end
