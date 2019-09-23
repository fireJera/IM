#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "amrFileCodec.h"
#import "interf_dec.h"
#import "interf_enc.h"
#import "dec_if.h"
#import "if_rom.h"
#import "NSData+CTMSG_Base64.h"
#import "NSString+CTMSG_Temp.h"
#import "UIImage+CTMSG_String.h"
#import "CTMSGEnumDefine.h"
#import "CTMSGCommandMessage.h"
#import "CTMSGCommandNotificationMessage.h"
#import "CTMSGImageMessage.h"
#import "CTMSGInformationNotificationMessage.h"
#import "CTMSGLocationMessage.h"
#import "CTMSGMessage.h"
#import "CTMSGMessageContent.h"
#import "CTMSGRecallNotificationMessage.h"
#import "CTMSGRichContentMessage.h"
#import "CTMSGTextMessage.h"
#import "CTMSGTypingStatusMessage.h"
#import "CTMSGUnknownMessage.h"
#import "CTMSGVideoMessage.h"
#import "CTMSGVoiceMessage.h"
#import "CTMSGConversation.h"
#import "CTMSGMetionedInfo.h"
#import "CTMSGReceiptInfo.h"
#import "CTMSGSearchConversationResult.h"
#import "CTMSGUserInfo.h"
#import "CTMSGAMRDataConverter.h"
#import "CTMSGChatAliOSS.h"
#import "CTMSGDataBaseManager.h"
#import "CTMSGIMClient.h"
#import "CTMSGNetManager.h"
#import "CTMSGUploadMediaStatusListener.h"

FOUNDATION_EXPORT double MessageLibVersionNumber;
FOUNDATION_EXPORT const unsigned char MessageLibVersionString[];

