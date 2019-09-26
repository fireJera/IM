//
//  CTMSGChatVoiceInputView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTMSGVoiceViewType) {
    CTMSGVoiceViewTypeRecord,
    CTMSGVoiceViewTypePreview,
};

@protocol CTMSGChatVoiceInputViewDelegate;

@interface CTMSGChatVoiceInputView : UIView

@property (nonatomic, weak) id<CTMSGChatVoiceInputViewDelegate> delegate;
@property (nonatomic, strong) UIImageView * recordImageView;
@property (nonatomic, strong) UIImageView * playIcon;
@property (nonatomic, strong) UIImageView * trashIcon;
//@property (nonatomic, strong) UIImageView * animatedImage;
@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UIButton * cancelBtn;
@property (nonatomic, strong) UIButton * sendBtn;

@property (nonatomic, assign, readonly) CTMSGVoiceViewType viewType;
@property (readonly) BOOL recordTooShort;

@end

@protocol CTMSGChatVoiceInputViewDelegate <NSObject>

- (void)voiceReocordStart:(CTMSGChatVoiceInputView *)inputView;
- (void)voiceReocordCancel:(CTMSGChatVoiceInputView *)inputView;
- (void)voiceReocordEndAndSend:(CTMSGChatVoiceInputView *)inputView;

@end

NS_ASSUME_NONNULL_END
