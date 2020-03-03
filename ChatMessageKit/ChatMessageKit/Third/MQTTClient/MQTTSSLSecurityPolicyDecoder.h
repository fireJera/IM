//
// MQTTSSLSecurityPolicyDecoder.h
// MQTTClient.framework
// 
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTSSLSecurityPolicy.h"
#import "MQTTCFSocketDecoder.h"

@interface MQTTSSLSecurityPolicyDecoder : MQTTCFSocketDecoder

@property(nonatomic, strong) MQTTSSLSecurityPolicy *securityPolicy;
@property(nonatomic, strong) NSString *securityDomain;

@end


