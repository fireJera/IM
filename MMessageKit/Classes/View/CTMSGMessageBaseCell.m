//
//  CTMSGMessageBaseCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageBaseCell.h"
#import "NSDate+CTMSG_Cat.h"
//#import "CTMSGCommandNotificationMessage.h"
//#import "CTMSGInformationNotificationMessage.h"
#import <MessageLib/MessageLib.h>
#import "CTMSGMessageModel.h"
#import "UIColor+CTMSG_Hex.h"

NSString * const KNotificationMessageBaseCellUpdateSendingStatus = @"KNotificationMessageBaseCellUpdateSendingStatus";

const int CTMSGMessageCellTimeZoneHeight = 45;
const int CTMSGMessageCellBaseTop = 10;
const int CTMSGMessageCellBaseBottom = 10;
const int CTMSGMessageCellExtraHeight = CTMSGMessageCellBaseTop + CTMSGMessageCellBaseBottom + CTMSGMessageCellTimeZoneHeight;

const int CTMSGMessageCellTimeLeading = 10;
const int CTMSGMessageCellTimeMinTop = 10;

@implementation CTMSGMessageBaseCell

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    return (CGSize){collectionViewWidth, extraHeight};
}

#pragma mark - layout

//- (void)layoutSubviews {
//    [super layoutSubviews];
////    _baseContentView.frame = self.contentView.bounds;
//}

#pragma mark - notification

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {

}

#pragma mark - setter

- (void)setModel:(CTMSGMessageModel *)model {
    _model = model;
    [self p_ctmsg_updateBaseCell];
}

- (void)p_ctmsg_updateBaseCell {
    if ([_model.objectName isEqualToString:CTMSGCommandNotificationMessageIdentifier]) {
        CTMSGCommandNotificationMessage * command = (CTMSGCommandNotificationMessage *)_model.content;
        _messageTimeLabel.text = command.showContent;
    }
    else if ([_model.objectName isEqualToString:CTMSGInformationNotificationMessageIdentifier]) {
        CTMSGInformationNotificationMessage * notification = (CTMSGInformationNotificationMessage *)_model.content;
        _messageTimeLabel.text = notification.message;
    }
    [_messageTimeLabel sizeToFit];
    
    CGFloat width = _model.cellSize.width;
    CGFloat height = _model.cellSize.height;
    CGRect frame = self.contentView.bounds;
    if (_model.isDisplayMessageTime) {
        if (_model.sentTime > 0 || _model.receivedTime > 0) {
            self.messageTimeLabel.text = [self timeStr];
        } else {
            self.messageTimeLabel.text = _model.timeStringToShow;
        }
        [_messageTimeLabel sizeToFit];
        frame = (CGRect){0, CTMSGMessageCellTimeZoneHeight, width, height - CTMSGMessageCellTimeZoneHeight};
        _messageTimeLabel.center = (CGPoint){width / 2, CTMSGMessageCellTimeZoneHeight / 2};
    }
    else {
        _messageTimeLabel.text = nil;
    }
    _baseContentView.frame = frame;
}

#pragma mark - getter

- (BOOL)isDisplayMessageTime {
    return _model.isDisplayMessageTime;
}

- (NSString *)timeStr {
    long long time = _model.messageDirection == CTMSGMessageDirectionSend ? _model.sentTime : _model.receivedTime;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    if ([date isToday]) {
        formatter.dateFormat = @"HH:mm";
    } else if ([date isYesterday]) {
        return @"昨天";
    } else if ([date isThisYear]) {
        formatter.dateFormat = @"MM-dd";
    } else {
        formatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return [formatter stringFromDate:date];
}

- (CTMSGMessageDirection)messageDirection {
    return _model.messageDirection;
}

#pragma mark - lazy

- (UIView *)baseContentView {
    if (!_baseContentView) {
        _baseContentView = [[UIView alloc] init];
        [self.contentView addSubview:_baseContentView];
    }
    return _baseContentView;
}

- (CTMSGTipLabel *)messageTimeLabel {
    if (!_messageTimeLabel) {
        _messageTimeLabel = [[CTMSGTipLabel alloc] init];
        _messageTimeLabel.textAlignment = NSTextAlignmentCenter;
        _messageTimeLabel.font = [UIFont systemFontOfSize:14];
        _messageTimeLabel.textColor = [UIColor ctmsg_colorB1B1B1];
        [self.contentView addSubview:_messageTimeLabel];
    }
    return _messageTimeLabel;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
//    [self p_ctmsg_initView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        [self p_ctmsg_initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    [self p_ctmsg_initView];
}

//- (void)p_ctmsg_initView {
//    _messageTimeLabel = [[CTMSGTipLabel alloc] init];
//    [self.contentView addSubview:_messageTimeLabel];
//}

@end
