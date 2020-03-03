//
//  CTMSGLocationMessageCell.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGLocationMessageCell.h"
#import "CTMSGMessageModel.h"
#import "CTMSGLocationMessage.h"
#import "CTMSGContentView.h"
#import "UIFont+CTMSG_Font.h"

@implementation CTMSGLocationMessageCell

//@synthesize model = self.model;
//@synthesize delegate = _delegate;
//@synthesize messageDirection = _messageDirection;
//@synthesize messageTimeLabel = _messageTimeLabel;
//@synthesize baseContentView = _baseContentView;
//
//@synthesize portraitBtn = _portraitBtn;
//@synthesize messageContentView = self.messageContentView;
//@synthesize statusContentView = _statusContentView;
//@synthesize messageFailedStatusView = _messageFailedStatusView;
//@synthesize messageActivityIndicatorView = _messageActivityIndicatorView;

+ (CGSize)sizeForMessageModel:(CTMSGMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    return (CGSize){collectionViewWidth, extraHeight};
}

- (void)setModel:(CTMSGMessageModel *)model {
    [super setModel:model];
    [self p_ctmsg_updateCell];
}

- (void)p_ctmsg_updateCell {
    if ([self.model.objectName isEqualToString:CTMSGLocationMessageTypeIdentifier]) {
        CTMSGLocationMessage * message = (CTMSGLocationMessage *)self.model.content;
        _pictureView.image = message.thumbnailImage;
    }
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    //    CTMSGLocationMessage * message = (CTMSGLocationMessage *)self.model.content;
    //    CGFloat width = self.contentView.frame.size.width;
    //    CGFloat height = self.contentView.frame.size.height;
    
    //    CGSize textLabelSize = [[self class] getTextLabelSize:message];
    //    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize:textLabelSize];
    //    CGRect messageContentViewRect = self.messageContentView.frame;
    
    //拉伸图片
    //    if (self.messageDirection == CTMSGMessageDirectionReceive) {
    //        self.textLabel.frame = CGRectMake(20, 7, textLabelSize.width, textLabelSize.height);
    //
    //        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
    //        self.messageContentView.frame = messageContentViewRect;
    //
    //        self.bubbleBackgroundView.frame =
    //        CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
    //        //        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
    //        UIImage *image = [UIImage imageNamed:@""];
    //        self.bubbleBackgroundView.image =
    //        [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8,
    //                                                            image.size.height * 0.2, image.size.width * 0.2)];
    //    } else {
    //        self.textLabel.frame = CGRectMake(12, 7, textLabelSize.width, textLabelSize.height);
    //
    //        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
    //        messageContentViewRect.size.height = bubbleBackgroundViewSize.height;
    //        messageContentViewRect.origin.x =
    //        self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + HeadAndContentSpacing +
    //                                                  CTMSGMessageCellAvatarWith + 10);
    //        self.messageContentView.frame = messageContentViewRect;
    //
    //        self.bubbleBackgroundView.frame =
    //        CGRectMake(0, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
    //        //        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
    //        UIImage *image = [UIImage imageNamed:@""];
    //        self.bubbleBackgroundView.image =
    //        [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2,
    //                                                            image.size.height * 0.2, image.size.width * 0.8)];
    //    }
}
//#pragma mark - notification
//
//- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
//
//}

#pragma mark - CTMSGAttributedLabelDelegate

- (void)attributedLabel:(CTMSGAttributedLabel *)label didTapLabel:(NSString *)content {
    
}

- (void)attributedLabel:(CTMSGAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
}

- (void)attributedLabel:(CTMSGAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    
}

+ (CGSize)getCellSize:(CTMSGLocationMessage *)message {
    return message.thumbnailImage.size;
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
    _pictureView = [[UIImageView alloc] init];
    [self.messageContentView addSubview:_pictureView];
    _locationNameLabel = [[UILabel alloc] init];
    [self.messageContentView addSubview:_locationNameLabel];
}

@end
