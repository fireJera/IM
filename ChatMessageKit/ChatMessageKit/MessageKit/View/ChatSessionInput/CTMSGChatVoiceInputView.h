//
//  CTMSGChatVoiceInputView.h
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/5.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CTMSGChatVoiceInputViewDelegate;

@interface CTMSGChatVoiceInputView : UIView

@property (nonatomic, weak) id<CTMSGChatVoiceInputViewDelegate> delegate;
@property (nonatomic, strong) UIButton * recordBtn;
@property (nonatomic, strong) UIImageView * playIcon;
@property (nonatomic, strong) UIImageView * trashIcon;
@property (nonatomic, strong) UIImageView * animatedImage;
@property (nonatomic, strong) UILabel * timeLabel NS_UNAVAILABLE;
@property (nonatomic, strong) UIButton * cancelBtn;
@property (nonatomic, strong) UIButton * sendBtn;

@end

@protocol CTMSGChatVoiceInputViewDelegate <NSObject>

- (void)voiceReocordStart:(CTMSGChatVoiceInputView *)inputView;
- (void)voiceReocordCancel:(CTMSGChatVoiceInputView *)inputView;
- (void)voiceReocordEndAndSend:(CTMSGChatVoiceInputView *)inputView;

@end

NS_ASSUME_NONNULL_END
