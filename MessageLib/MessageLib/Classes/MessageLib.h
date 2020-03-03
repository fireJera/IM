//
//  MessageLib.h
//  MessageLib
//
//  Created by Jeremy on 2019/7/22.
//  Copyright © 2019 InterestChat. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for MessageLib.
FOUNDATION_EXPORT double MessageLibVersionNumber;

//! Project version string for MessageLib.
FOUNDATION_EXPORT const unsigned char MessageLibVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MessageLib/PublicHeader.h>


#import <MessageLib/CTMSGIMClient.h>
#import <MessageLib/CTMSGUserInfo.h>
#import <MessageLib/CTMSGEnumDefine.h>

#import <MessageLib/CTMSGMessageContent.h>
#import <MessageLib/CTMSGMessage.h>
#import <MessageLib/CTMSGTextMessage.h>
#import <MessageLib/CTMSGImageMessage.h>
#import <MessageLib/CTMSGVoiceMessage.h>
#import <MessageLib/CTMSGVideoMessage.h>
#import <MessageLib/CTMSGLocationMessage.h>
#import <MessageLib/CTMSGUnknownMessage.h>
#import <MessageLib/CTMSGRichContentMessage.h>
#import <MessageLib/CTMSGInformationNotificationMessage.h>
#import <MessageLib/CTMSGCommandNotificationMessage.h>
#import "MessageLib/CTMSGCommandMessage.h"

#import <MessageLib/CTMSGConversation.h>
//#import "CTMSGAMRDataConverter.h"

//#import <MessageLib/CTMSGChatAliOSS.h>
#import <MessageLib/CTMSGDataBaseManager.h>
#import <MessageLib/CTMSGNetManager.h>
#import <MessageLib/CTMSGUploadMediaStatusListener.h>
