//
//  INTCTFastTextView.h
//  InterestChat
//
//  Created by Jeremy on 2019/7/30.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface INTCTFastTextView : UIView

@property (nonatomic, strong) UIButton * closeBtn;
@property (nonatomic, strong, readonly) NSArray<UIButton *> * textBtns;

- (instancetype)initWithTexts:(NSArray<NSString *> *)texts;

@end

NS_ASSUME_NONNULL_END
