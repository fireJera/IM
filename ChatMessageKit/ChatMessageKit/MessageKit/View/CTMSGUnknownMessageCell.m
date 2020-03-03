//
//  CTMSGUnknownMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGUnknownMessageCell.h"
#import "CTMSGMessageModel.h"
#import "CTMSGUnknownMessage.h"
#import "UIFont+CTMSG_Font.h"
#import "CTMSGTextMessageCell.h"
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
        self.lockLable.text = unknown.conversationDigest;
    }
    [self.messageTimeLabel sizeToFit];
    [self p_ctmsg_updateFrame];
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CGSize textLabelSize = [[self class] getTextLabelSize:CTMSGMessageUnSupprotNote width:CTMSGSCREENWIDTH];
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    
    CGRect messageContentViewRect = self.messageContentView.frame;
    UIImage * image;
    
    self.lockLable.frame = (CGRect){Text_Message_Lable_Leading, Text_Message_Lable_Top, textLabelSize};
    self.bubbleBackgroundView.frame = (CGRect){CGPointZero, bubbleBackgroundViewSize};
    //拉伸图片
    if (self.messageDirection == CTMSGMessageDirectionReceive) {
        self.lockLable.textColor = [UIColor whiteColor];
        messageContentViewRect.size = bubbleBackgroundViewSize;
        image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_to"];
    } else {
//        _textLabel.textColor = [UIColor ctmsg_color212121];
//        messageContentViewRect.size = bubbleBackgroundViewSize;
//        messageContentViewRect.origin.x =
//        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + CTMSGMessageCellBubbleLeading);
//        image = [CTMSGUtilities imageForNameInBundle:@"ctmsg_chat_bubble_from"];
    }
    self.messageContentView.frame = messageContentViewRect;
    self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.3, image.size.width * 0.3,
                                                                                          image.size.height * 0.7, image.size.width * 0.7)];
}

#pragma mark - private
+ (CGSize)getTextLabelSize:(NSString *)content width:(CGFloat)collectionWidth {
    float maxWidth = collectionWidth - (CTMSGMessageCellBubbleLeading + Text_Message_Lable_Leading) * 2;
    CGRect textRect = [content
                       boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                       options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                NSStringDrawingUsesFontLeading)
                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:Text_Message_Font_Size]}
                       context:nil];
    textRect.size.height = ceilf(textRect.size.height);
    textRect.size.width = ceilf(textRect.size.width);
    return CGSizeMake(textRect.size.width + 5, textRect.size.height + 5);
}

+ (CGSize)getBubbleSize:(CGSize)textLabelSize {
    CGSize bubbleSize = CGSizeMake(textLabelSize.width, textLabelSize.height);
    bubbleSize.width = MAX(CTMSGMessageCellBubbleMinWidth, bubbleSize.width + Text_Message_Lable_Leading * 2);
    bubbleSize.height = MAX(CTMSGMessageCellBubbleMinHeight, bubbleSize.height + Text_Message_Lable_Top * 2);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CTMSGUnknownMessage *)message width:(CGFloat)collectionWidth {
    CGSize textLabelSize = [[self class] getTextLabelSize:[message conversationDigest] width:collectionWidth];
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
//    _messageLabel = [[CTMSGTipLabel alloc] init];
//    [self.baseContentView addSubview:_messageLabel];
}
@end
