//
//  SHClient.m
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHClient.h"
#import "SRWebSocket.h"
#import "NSDictionary+Safe.h"

@interface SHClient () <SRWebSocketDelegate>

@property (strong) SRWebSocket *socket;
@property (strong) NSMutableDictionary *callbacks;

@end

@implementation SHClient

- (id)initWithURL:(NSURL *)url docName:(NSString *)docName
{
    self = [super init];
    
    if(self)
    {
        _socket = [[SRWebSocket alloc] initWithURL:url];
        _socket.delegate = self;
        [_socket open];
    }
    
    return self;
}

- (void)submitOperation:(id<SHOperation>)operation
{
    // should queue and remove from queue when we get a confirmation
    [_socket send:[operation jsonDictionary]];
}

// find the right callbacks for this operation
- (NSArray *)callbacksForOperation:(id<SHOperation>)operation
{
    NSMutableArray *callbacks = [NSMutableArray array];
    [_callbacks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj[@"type"] integerValue] == operation.type)
        {
            [callbacks addObject:obj];
        }
    }];
    return callbacks;
}

// add a callback for a certain operation type
- (NSString *)addCallback:(SHCallbackBlock)callback type:(SHType)type
{
    if(!_callbacks) _callbacks = [NSMutableDictionary dictionary];
    NSDictionary *callbackDict = @{ @"callback" : callback, @"type" : [NSNumber numberWithInteger:type] };
    NSString *identifier = [NSString randomString:10];
    [_callbacks setObject:callbackDict forKey:identifier];
    return identifier;
}

// remove callback with this identifier
- (void)removeCallbackWithIdentifier:(NSString *)identifier
{
    [_callbacks removeObjectForKey:identifier];
}

// removes all callbacks for a certain type
- (void)removeCallbacksForType:(SHType)type
{
    NSMutableDictionary *newCallbacks = [_callbacks mutableCopy];
    [_callbacks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj[@"type"] integerValue] == type)
        {
            [newCallbacks removeObjectForKey:key];
        }
    }];
    _callbacks = newCallbacks;
}

// removes all callbacks
- (void)removeAllCallbacks
{
    _callbacks = nil;
}

// returns callback with this identifier
- (SHCallbackBlock)callbackForIdentifier:(NSString *)identifier
{
    return [_callbacks objectForKey:identifier][@"callback"];
}


- (void)removeCallbackForIdentifier:(NSString *)identifier
{
    [_callbacks removeObjectForKey:identifier];
}


#pragma mark - SocketRocket delegate methods

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"didReceiveMessage");
    
    NSError *e = nil;
    
    NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:[(NSString* )message dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&e];
    
    if(!e)
    {
        if(_auth == nil && messageDict[@"auth"] != nil)
        {
            _auth = messageDict[@"auth"];
            NSLog(@"auth");
        }
        else {
            id<SHOperation> operation = [self operationForJSONDictionary:messageDict];
            NSArray *callbacks = [self callbacksForOperation:operation];
            [callbacks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SHCallbackBlock callback = (SHCallbackBlock)obj[@"callback"];
                callback(operation.type, operation);
            }];
        }
    }
    else {
        NSLog(@"No valid JSON respons: %@, JSON: %@", e, message);
    }
    
}

- (id<SHOperation>)operationForJSONDictionary:(NSDictionary *)jsonDictionary
{
    return nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
     NSLog(@"didFailWithError");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
     NSLog(@"didCloseWithCode");   
}

@end
