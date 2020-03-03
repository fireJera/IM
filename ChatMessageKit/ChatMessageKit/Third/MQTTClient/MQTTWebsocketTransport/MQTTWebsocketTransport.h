//
//  MQTTWebsocketTransport.h
//  MQTTClient
//
//  Created by Christoph Krey on 06.12.15.
//  Copyright © 2015-2017 Christoph Krey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTTransport.h"
#if __has_include (<SocketRocket/SRWebSocket.h>)
#import <SocketRocket/SRWebSocket.h>
#else
#import "SRWebSocket.h"
#endif

/** MQTTCFSocketTransport
 * implements an MQTTTransport on top of Websockets (SocketRocket)
 */
@interface MQTTWebsocketTransport : MQTTTransport <MQTTTransport, SRWebSocketDelegate>

/** host an NSString containing the hostName or IP address of the host to connect to
 * defaults to @"localhost"
*/
@property (nonatomic, strong) NSString *host;

/** url an NSURL containing the presigned URL
 * defaults to nil
 */
@property (nonatomic, strong) NSURL *url;

/** port an unsigned 32 bit integer containing the IP port number to connect to
 * defaults to 80
 */
@property (nonatomic) UInt32 port;

/** tls a boolean indicating whether the transport should be using security 
 * defaults to NO
 */
@property (nonatomic) BOOL tls;

/** path an NSString indicating the path component of the websocket URL request
 * defaults to @"/html"
 */
@property (nonatomic, strong) NSString *path;

/** allowUntrustedCertificates a boolean indicating whether self signed or expired certificates should be accepted
 * defaults to NO
 */
@property (nonatomic) BOOL allowUntrustedCertificates;

/** pinnedCertificates an NSArray containing certificates to validate server certificates against
 * defaults to nil
 */
@property (nonatomic, strong) NSArray *pinnedCertificates;
  
/** additionalHeaders an NSDictionary containing extra headers sent when establishing the websocket connection. Useful for custom authorization protocols. e.g. AWS IoT Custom Auth.
 * defaults to an empty dictionary
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString*> *additionalHeaders;
  


@end
