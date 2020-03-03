//
//  CTMSGMessageBaseCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGMessageBaseCell.h"
#import "NSDate+CTMSG_Date.h"
#import "CTMSGCommadnNotificationMessage.h"
#import "CTMSGInformationNotificationMessage.h"
#import "CTMSGMessageModel.h"

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

- (void)layoutSubviews {
    
}


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
        CTMSGCommadnNotificationMessage * command = (CTMSGCommadnNotificationMessage *)_model.content;
        _messageTimeLabel.text = command.showContent;
    }
    else if ([_model.objectName isEqualToString:CTMSGInformationNotificationMessageIdentifier]) {
        CTMSGInformationNotificationMessage * notification = (CTMSGInformationNotificationMessage *)_model.content;
        _messageTimeLabel.text = notification.message;
    }
    [_messageTimeLabel sizeToFit];
    
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height;
    CGRect frame = self.contentView.bounds;
    if (_model.isDisplayMessageTime) {
        frame = (CGRect){0, CTMSGMessageCellTimeZoneHeight, width, height - CTMSGMessageCellTimeZoneHeight};
        self.messageTimeLabel.center = (CGPoint){width / 2, CTMSGMessageCellTimeZoneHeight / 2};
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
        formatter.dateFormat = @"MM月dd日";
    } else {
        formatter.dateFormat = @"yyyy年MM月dd日";
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
        [self.contentView addSubview:_messageTimeLabel];
    }
    return _messageTimeLabel;
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
    _messageTimeLabel = [[CTMSGTipLabel alloc] init];
    [self.contentView addSubview:_messageTimeLabel];
}



@end
