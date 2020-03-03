//
//  CTMSGUnknownMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUnknownMessageCell.h"
#import "CTMSGMessageModel.h"
#import "CTMSGTextMessageCell.h"
#import <MessageLib/MessageLib-umbrella.h>
#import "CTMSGUtilities.h"
#import "CTMSGContentView.h"
#import "UIColor+CTMSG_Hex.h"

NSString * const CTMSGMessageUnSupprotNote = @"当前版本不支持查看此消息类型，请升级到最新版本";

@implementation CTMSGUnknownMessageCell

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CTMSGUnknownMessage * message = (CTMSGUnknownMessage *)model.content;
    CGSize size = [self getBubbleBackgroundViewSize:message width:collectionViewWidth];
    CGFloat __messagecontentview_height = size.height;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [self p_ctmsg_updateCell];
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGUnknownMessageTypeIdentifier]) {
        CTMSGUnknownMessage * unknown = (CTMSGUnknownMessage *)self.model.content;
        self.messageLabel.text = unknown.content;
        [self.messageTimeLabel sizeToFit];
        [self p_ctmsg_updateFrame];
    }
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CTMSGUnknownMessage * message = (CTMSGUnknownMessage *)self.model.content;
    
    CGSize textLabelSize = [[self class] getTextLabelSize:message width:CTMSGSCREENWIDTH];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    UIImage * image;
    
    self.messageLabel.frame = (CGRect){Text_Message_Lable_Leading, Text_Message_Lable_Top, textLabelSize};
    self.bubbleBackgroundView.frame = (CGRect){CGPointZero, bubbleBackgroundViewSize};
    //拉伸图片
    if (self.messageDirection == CTMSGMessageDirectionReceive) {
        _messageLabel.textColor = [UIColor whiteColor];
        messageContentViewRect.origin.x = CTMSGMessageCellBubbleLeading + CTMSGMessageCellAvatarWith + CTMSGMessageCellAvatarLeading;
        messageContentViewRect.size = bubbleBackgroundViewSize;
        image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_to"];
    } else {
        _messageLabel.textColor = [UIColor ctmsg_color212121];
        messageContentViewRect.size = bubbleBackgroundViewSize;
        messageContentViewRect.origin.x =
        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading) - CTMSGMessageCellAvatarWith - CTMSGMessageCellAvatarLeading;
        image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_from"];
    }
    self.messageContentView.frame = messageContentViewRect;
    self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.3, image.size.width * 0.3,
                                                                                          image.size.height * 0.7, image.size.width * 0.7)];
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

#pragma mark - private
+ (CGSize)getTextLabelSize:(CTMSGUnknownMessage *)message width:(CGFloat)collectionWidth {
    if ([message.content length] > 0) {
        float maxWidth = collectionWidth - (CTMSGMessageCellBubbleLeading + Text_Message_Lable_Leading) * 2 - CTMSGMessageCellAvatarWith - CTMSGMessageCellAvatarLeading;
        CGRect textRect = [message.content
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
    bubbleSize.width = MAX(CTMSGMessageCellBubbleMinWidth, bubbleSize.width + Text_Message_Lable_Leading * 2);
    bubbleSize.height = MAX(CTMSGMessageCellBubbleMinHeight, bubbleSize.height + Text_Message_Lable_Top * 2);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CTMSGUnknownMessage *)message width:(CGFloat)collectionWidth {
    CGSize textLabelSize = [[self class] getTextLabelSize:message width:collectionWidth];
    return [[self class] getBubbleSize:textLabelSize];
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self p_ctmsg_initView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_ctmsg_initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self p_ctmsg_initView];
}

- (void)p_ctmsg_initView {
    _messageLabel = [[CTMSGAttributedLabel alloc] init];
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = [UIFont systemFontOfSize:16];
    [self.messageContentView addSubview:_messageLabel];
    self.messageContentView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *textTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextMessage:)];
    textTap.numberOfTapsRequired = 1;
    textTap.numberOfTouchesRequired = 1;
    [self.messageContentView addGestureRecognizer:textTap];
}

@end
