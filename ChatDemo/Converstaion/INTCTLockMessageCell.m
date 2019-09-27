//
//  INTCTLockMessageCell.m
//  InterestChat
//
//  Created by Jeremy on 2019/7/24.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import "INTCTLockMessageCell.h"
#import "Header.h"

static const CGFloat kLockIconWidth = 20;

@implementation INTCTLockMessageCell


+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    NSString * content = ((CTMSGTextMessage *)model.content).content;
    CGSize size = [self getBubbleBackgroundViewSize:content width:collectionViewWidth];
    
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
    if ([self.model.objectName isEqualToString:CTMSGTextMessageTypeIdentifier]) {
        CTMSGTextMessage * message = (CTMSGTextMessage *)self.model.content;
        _textLabel.text = message.content;
        [_textLabel sizeToFit];
        [self p_ctmsg_updateFrame];
    }
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CTMSGTextMessage * message = (CTMSGTextMessage *)self.model.content;
    //    CGFloat width = self.contentView.frame.size.width;
    //    CGFloat height = self.contentView.frame.size.height;
    
    CGSize textLabelSize = [[self class] getTextLabelSize:message.content width:INTCTSCREENWIDTH];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    UIImage * image;
    
    CGFloat iconTop = (messageContentViewRect.size.height - kLockIconWidth) / 2;
    self.lockIcon.frame = (CGRect){Text_Message_Lable_Leading, iconTop,kLockIconWidth, kLockIconWidth};
    self.textLabel.frame = (CGRect){Text_Message_Lable_Leading * 2 + kLockIconWidth, Text_Message_Lable_Top, textLabelSize};
    self.bubbleBackgroundView.frame = (CGRect){CGPointZero, bubbleBackgroundViewSize};
    //拉伸图片
    //    if (self.messageDirection == CTMSGMessageDirectionReceive) {
    _textLabel.textColor = [UIColor whiteColor];
    messageContentViewRect.origin.x = CTMSGMessageCellBubbleLeading;
    messageContentViewRect.size = bubbleBackgroundViewSize;
    image = [UIImage imageNamed:@"intct_msg_35"];
    //    }
    self.messageContentView.frame = messageContentViewRect;
    self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.3, image.size.width * 0.3,
                                                                                          image.size.height * 0.7, image.size.width * 0.7)];
}

- (void)updateStatusContentView:(CTMSGMessageModel *)model {
    //    [self.messageActivityIndicatorView stopAnimating];
    //    if (model.sentStatus == SentStatus_SENDING) {
    //        self.messageActivityIndicatorView.hidden = NO;
    //        [self.messageActivityIndicatorView startAnimating];
    //        self.messageFailedStatusView.hidden = YES;
    //    }
    //    else if (model.sentStatus == SentStatus_FAILED) {
    //        self.messageActivityIndicatorView.hidden = YES;
    //        self.messageFailedStatusView.hidden = NO;
    //    }
    //    else if (model.sentStatus == SentStatus_SENT) {
    //        self.messageActivityIndicatorView.hidden = YES;
    //        self.messageFailedStatusView.hidden = YES;
    //        return;
    //    }
    //    if (model.messageDirection == CTMSGMessageDirectionSend) {
    //        CGFloat failedLeft = self.messageContentView.frame.origin.x - 10 - self.messageFailedStatusView.frame.size.width;
    //        CGFloat failedTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - self.messageFailedStatusView.frame.size.height) / 2);
    //        self.messageFailedStatusView.frame = CGRectMake(failedLeft, failedTop, self.messageFailedStatusView.frame.size.width, self.messageFailedStatusView.frame.size.height);
    //        CGFloat indiWidth = 20;
    //        CGFloat indiLeft = self.messageContentView.frame.origin.x - 10 - indiWidth;
    //        CGFloat indiTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - indiWidth) / 2);
    //        self.messageActivityIndicatorView.frame = CGRectMake(indiLeft, indiTop, indiWidth, indiWidth);
    //    }
    //    else {
    //        CGFloat left = self.messageContentView.frame.origin.x + self.messageContentView.frame.size.width + 10;
    //        CGFloat failedTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - self.messageFailedStatusView.frame.size.height) / 2);
    //        self.messageFailedStatusView.frame = CGRectMake(left, failedTop, self.messageFailedStatusView.frame.size.width, self.messageFailedStatusView.frame.size.height);
    //        CGFloat indiWidth = 20;
    //        CGFloat indiTop = self.messageContentView.frame.origin.y + ((self.messageContentView.frame.size.height - indiWidth) / 2);
    //        self.messageActivityIndicatorView.frame = CGRectMake(left, indiTop, indiWidth, indiWidth);
    //    }
}


#pragma mark - touch event
- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBackgroundView];
    }
}

+ (CGSize)getTextLabelSize:(NSString *)message width:(CGFloat)collectionWidth {
    if ([message length] > 0) {
        float maxWidth = collectionWidth - (CTMSGMessageCellBubbleLeading + Text_Message_Lable_Leading) * 2;
        CGRect textRect = [message
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]}
                           context:nil];
        textRect.size.height = ceilf(textRect.size.height);
        textRect.size.width = ceilf(textRect.size.width);
        // +5 估计是uilabel 的上下左右边距
        return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)getBubbleSize:(CGSize)textLabelSize {
    CGSize bubbleSize = CGSizeMake(textLabelSize.width, textLabelSize.height);
    bubbleSize.width = MAX(CTMSGMessageCellBubbleMinWidth, bubbleSize.width + Text_Message_Lable_Leading * 3 + kLockIconWidth);
    bubbleSize.height = MAX(CTMSGMessageCellBubbleMinHeight, bubbleSize.height + Text_Message_Lable_Top * 2);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(NSString *)message width:(CGFloat)collectionWidth {
    CGSize textLabelSize = [[self class] getTextLabelSize:message width:collectionWidth];
    return [[self class] getBubbleSize:textLabelSize];
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self p_intct_initView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_intct_initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self p_intct_initView];
}

- (void)p_intct_initView {
    _textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont systemFontOfSize:16];
    [self.messageContentView addSubview:_textLabel];
    _lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intct_msg_11"]];
    [self.messageContentView addSubview:_lockIcon];
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *textTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
    textTap.numberOfTapsRequired = 1;
    textTap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:textTap];
}

@end
