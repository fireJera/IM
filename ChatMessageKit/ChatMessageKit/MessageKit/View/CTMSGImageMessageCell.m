//
//  CTMSGImageMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGImageMessageCell.h"
#import "CTMSGMessageModel.h"
#import "CTMSGImageMessage.h"
#import "CTMSGContentView.h"
#import "CTMSGImageMessageProgressView.h"
#import "UIFont+CTMSG_Font.h"
#import "CTMSGUtilities.h"

const int CTMSGImageMessageCellMaxWidth = 200;
const int CTMSGImageMessageCellMaxHeight = 120;

@interface CTMSGImageMessageCell () {
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
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGImageMessageTypeIdentifier]) {
        CTMSGImageMessage * message = (CTMSGImageMessage *)self.model.content;
//        if (message.originalImage) {
//            _pictureView.image = message.originalImage;
//        }
        _pictureView.image = message.thumbnailImage;
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
    if (self.messageDirection == CTMSGMessageDirectionSend) {
//
//    } else {
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading);
    }
    self.messageContentView.frame = messageContentViewRect;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:messageContentViewRect
                                                byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                      cornerRadii:CGSizeMake(10, 10)];
    _cornerLayer.path = path.CGPath;
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

//#pragma mark - notification
//
//- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
//
//}

+ (CGSize)getCellSize:(CTMSGImageMessage *)message {
    float messageRate = (float)CTMSGImageMessageCellMaxWidth / (float)CTMSGImageMessageCellMaxHeight;
    float imageRate = message.thumbnailImage.size.width / message.thumbnailImage.size.height;
    CGSize bubbleSize;
    if (message.thumbnailImage.size.width < CTMSGImageMessageCellMaxWidth && message.thumbnailImage.size.height > CTMSGImageMessageCellMaxHeight) {
        bubbleSize = message.thumbnailImage.size;
    } else if (messageRate > imageRate) {
        bubbleSize = (CGSize){CTMSGImageMessageCellMaxHeight * imageRate, CTMSGImageMessageCellMaxHeight};
    } else {
        bubbleSize = (CGSize){CTMSGImageMessageCellMaxWidth, CTMSGImageMessageCellMaxWidth / imageRate};
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
