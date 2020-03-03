//
//  CTMSGAttributedLabel.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/3.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGAttributedLabel.h"
#import "UIFont+CTMSG_Font.h"

@implementation CTMSGAttributedLabel

#pragma mark - CTMSGAttributedDataSource

- (NSDictionary *)attributeDictionaryForTextType:(NSTextCheckingTypes)textType {
    return nil;
}

- (NSDictionary *)highlightedAttributeDictionaryForTextType:(NSTextCheckingType)textType {
    return nil;
}

#pragma mark - public
//- (void)setTextCheckingTypes:(NSTextCheckingTypes)textCheckingTypes {
//
//}

- (void)setTextHighlighted:(BOOL)highlighted atPoint:(CGPoint)point {
    
}

- (void)setText:(NSString *)text dataDetectorEnabled:(BOOL)dataDetectorEnabled {
    
}

@end
