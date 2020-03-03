//
//  MQTTProperties.h
//  MQTTClient
//
//  Created by Christoph Krey on 04.04.17.
//  Copyright © 2017 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, MQTTPropertyIdentifier) {
    MQTTPayloadFormatIndicator = 1,
    MQTTPublicationExpiryInterval = 2,
    MQTTContentType = 3,
    MQTTResponseTopic = 8,
    MQTTCorrelationData = 9,
    MQTTSubscriptionIdentifier = 11,
    MQTTSessionExpiryInterval = 17,
    MQTTAssignedClientIdentifier = 18,
    MQTTServerKeepAlive = 19,
    MQTTAuthMethod = 21,
    MQTTAuthData = 22,
    MQTTRequestProblemInformation = 23,
    MQTTWillDelayInterval = 24,
    MQTTRequestResponseInformation = 25,
    MQTTResponseInformation = 26,
    MQTTServerReference = 28,
    MQTTReasonString = 31,
    MQTTReceiveMaximum = 33,
    MQTTTopicAliasMaximum = 34,
    MQTTTopicAlias = 35,
    MQTTMaximumQoS = 36,
    MQTTRetainAvailable = 37,
    MQTTUserProperty = 38,
    MQTTMaximumPacketSize = 39,
    MQTTWildcardSubscriptionAvailable = 40,
    MQTTSubscriptionIdentifiersAvailable = 41,
    MQTTSharedSubscriptionAvailable = 42
};


@interface MQTTProperties : NSObject

@property (nonatomic, strong) NSNumber *payloadFormatIndicator;
@property (nonatomic, strong) NSNumber *publicationExpiryInterval;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *responseTopic;
@property (nonatomic, strong) NSData *correlationData;
@property (nonatomic, strong) NSNumber *subscriptionIdentifier;
@property (nonatomic, strong) NSNumber *sessionExpiryInterval;
@property (nonatomic, strong) NSString *assignedClientIdentifier;
@property (nonatomic, strong) NSNumber *serverKeepAlive;
@property (nonatomic, strong) NSString *authMethod;
@property (nonatomic, strong) NSData *authData;
@property (nonatomic, strong) NSNumber *requestProblemInformation;
@property (nonatomic, strong) NSNumber *willDelayInterval;
@property (nonatomic, strong) NSNumber *requestResponseInformation;
@property (nonatomic, strong) NSString *responseInformation;
@property (nonatomic, strong) NSString *serverReference;
@property (nonatomic, strong) NSString *reasonString;
@property (nonatomic, strong) NSNumber *receiveMaximum;
@property (nonatomic, strong) NSNumber *topicAliasMaximum;
@property (nonatomic, strong) NSNumber *topicAlias;
@property (nonatomic, strong) NSNumber *maximumQoS;
@property (nonatomic, strong) NSNumber *retainAvailable;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *userProperty;
@property (nonatomic, strong) NSNumber *maximumPacketSize;
@property (nonatomic, strong) NSNumber *wildcardSubscriptionAvailable;
@property (nonatomic, strong) NSNumber *subscriptionIdentifiersAvailable;
@property (nonatomic, strong) NSNumber *sharedSubscriptionAvailable;

- (instancetype)initFromData:(NSData *)data NS_DESIGNATED_INITIALIZER;
+ (int)getVariableLength:(NSData *)data;
+ (int)variableIntLength:(int)length;

@end
