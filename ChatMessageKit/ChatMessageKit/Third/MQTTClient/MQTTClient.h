//
//  MQTTClient.h
//  MQTTClient
//
//  Created by Christoph Krey on 13.01.14.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

/**
 Include this file to use MQTTClient classes in your application
 
 @author Christoph Krey c@ckrey.de
 @see http://mqtt.org
 */

#import <Foundation/Foundation.h>

//#if __has_include(<MQTTClient/MQTTSessionManager.h>)
//#import <MQTTClient/MQTTSessionManager.h>
//#else
//#import "MQTTSessionManager.h"
//#endif

#if __has_include(<MQTTClient>)
#import <MQTTClient/MQTTSessionManager.h>
#import <MQTTClient/MQTTSession.h>
#import <MQTTClient/MQTTDecoder.h>
#import <MQTTClient/MQTTSessionLegacy.h>
#import <MQTTClient/MQTTSessionSynchron.h>
#import <MQTTClient/MQTTProperties.h>
#import <MQTTClient/MQTTMessage.h>
#import <MQTTClient/MQTTTransport.h>
#import <MQTTClient/MQTTCFSocketTransport.h>
#import <MQTTClient/MQTTCoreDataPersistence.h>
#import <MQTTClient/MQTTSSLSecurityPolicyTransport.h>
#else
#import "MQTTSessionManager.h"
#import "MQTTSession.h"
#import "MQTTDecoder.h"
#import "MQTTSessionLegacy.h"
#import "MQTTSessionSynchron.h"
#import "MQTTProperties.h"
#import "MQTTMessage.h"
#import "MQTTTransport.h"
#import "MQTTCFSocketTransport.h"
#import "MQTTCoreDataPersistence.h"
#import "MQTTSSLSecurityPolicyTransport.h"
#endif

#if __has_include(<MQTTClient/MQTTSessionManager.h>)
#import <MQTTClient/MQTTSessionManager.h>
#endif

//! Project version number for MQTTClient.
FOUNDATION_EXPORT double MQTTClientVersionNumber;

//! Project version string for MQTTClient&lt;.
FOUNDATION_EXPORT const unsigned char MQTTClientVersionString[];

