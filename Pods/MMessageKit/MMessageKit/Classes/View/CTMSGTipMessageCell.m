//
//  CTMSGTipMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGTipMessageCell.h"
#import "CTMSGMessageModel.h"
//#import "CTMSGCommandNotificationMessage.h"
//#import "CTMSGInformationNotificationMessage.h"
#import <MessageLib/MessageLib.h>
#import "UIColor+CTMSG_Hex.h"
#import "CTMSGUtilities.h"

@implementation CTMSGTipMessageCell

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CTMSGInformationNotificationMessage *message = (CTMSGInformationNotificationMessage *)model.content;
    CGSize size = [self getBubbleBackgroundViewSize:message width:collectionViewWidth];
    
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
    if ([self.model.objectName isEqualToString:CTMSGInformationNotificationMessageIdentifier]) {
        CTMSGInformationNotificationMessage * notification = (CTMSGInformationNotificationMessage *)self.model.content;
        _tipMessageLabel.text = notification.message;
    }
    [self.messageTimeLabel sizeToFit];
    [self p_ctmsg_updateFrame];
}

#pragma mark - layout

- (void)p_ctmsg_updateFrame {
    CTMSGInformationNotificationMessage * message = (CTMSGInformationNotificationMessage *)self.model.content;
    CGSize textLabelSize = [[self class] getTextLabelSize:message width:CTMSGSCREENWIDTH];
    _tipMessageLabel.frame = (CGRect){CGPointZero, textLabelSize};
    _tipMessageLabel.center = self.contentView.center;
}

#pragma mark - private
+ (CGSize)getTextLabelSize:(CTMSGInformationNotificationMessage *)message width:(CGFloat)collectionWidth {
    if ([message.message length] > 0) {
        float maxWidth = collectionWidth - CTMSGMessageCellTimeLeading * 2;
        CGRect textRect = [message.message
                           boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                           options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                    NSStringDrawingUsesFontLeading)
                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}
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
    bubbleSize.height = MAX(CTMSGMessageCellTimeZoneHeight, bubbleSize.height + CTMSGMessageCellTimeMinTop * 2);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(CTMSGInformationNotificationMessage *)message width:(CGFloat)collectionWidth {
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
    _tipMessageLabel = [[CTMSGTipLabel alloc] init];
    [self.baseContentView addSubview:_tipMessageLabel];
}

@end
