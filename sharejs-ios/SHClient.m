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
@property (strong) NSMutableArray *queue;
@property (strong) NSMutableArray *unsendedOperations;

@end

@implementation SHMessage

+ (id)messageWithDictionary:(NSDictionary *)dictionary
                    success:(SHMessageSuccessCallback)successBlock
                    failure:(SHMessageFailureCallback)failureBlock
{
    SHMessage *message = [[[self class] alloc] init];
    
    if(message)
    {
        message.messageDict = dictionary;
        message.successCallback = successBlock;
        message.failureCallback = failureBlock;
    }
    
    return message;
}

- (NSData *)messageData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_messageDict options:NSJSONReadingMutableContainers error:&error];
    if(jsonData) return jsonData;
    NSLog(@"error converting to messageData: %@", error);
    return nil;
}

@end

@implementation SHClient

- (id)initWithURL:(NSURL *)url docName:(NSString *)docName
{
    self = [super init];
    
    if(self)
    {        
        _url = url;
        _docName = docName;
        [self connectToSocket];
    }
    
    return self;
}

- (void)connectToSocket
{
    if(!_socket)
    {
        _socket = [[SRWebSocket alloc] initWithURL:_url];
        _socket.delegate = self;
    }

    SHMessage *authMessage = [SHMessage messageWithDictionary:nil success:^(NSDictionary *respons)
    {
        if(_auth == nil && respons[@"auth"] != nil)
            _auth = respons[@"auth"];

        NSLog(@"_auth %@", _auth);
        
        [self openDocument:_docName];
      
    } failure:^(NSError *error) {}];
    
    [self addMessageToQueue:authMessage];

    [_socket open];
}

- (void)openDocument:(NSString *)docName
{
    // subclass should have this function
}

#pragma mark - Submitting

- (void)submitOperation:(id<SHOperation>)operation
{
    if(!_unsendedOperations) _unsendedOperations = [NSMutableArray array];
    [_unsendedOperations addObject:operation];
    
    SHMessage *message = [SHMessage messageWithDictionary:[operation jsonDictionary]
                                                  success:^(NSDictionary *respons)
    {
        id<SHOperation> operation = [self operationForJSONDictionary:respons];
        NSArray *callbacks = [self callbacksForOperation:operation];
        [callbacks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SHCallbackBlock callback = (SHCallbackBlock)obj[@"callback"];
            callback(operation.type, operation);
        }];
        [_unsendedOperations removeObject:operation];
    } failure:^(NSError *error) {
        NSLog(@"Error sending message: %@", error);
    }];
    
    [self addMessageToQueue:message];
}

#pragma mark - Callback handling

- (id<SHOperation>)operationForJSONDictionary:(NSDictionary *)jsonDictionary
{
    return nil;
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

#pragma mark - Socket communicator

- (void)addMessageToQueue:(SHMessage *)message
{
    if(!_queue) _queue = [NSMutableArray array];
    [_queue addObject:message];
    [self sendNextMessageOfQueue];
}

- (void)sendNextMessageOfQueue
{
    if([_queue count] == 0 || _inflightMessage) return;
    
    _inflightMessage = [_queue lastObject];
    [_queue removeLastObject];
    if(_inflightMessage.messageDict) [_socket send:_inflightMessage.messageData];
}

#pragma mark - SocketRocket delegate methods

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"didReceiveMessage: %@", message);
    
    NSError *e = nil;
    
    NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:[(NSString* )message dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&e];
    
    SHMessage *oldInflight = _inflightMessage;
    _inflightMessage = nil;
    
    if(e) oldInflight.failureCallback(e);
    else oldInflight.successCallback(messageDict);
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    _inflightMessage.failureCallback(error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSError *error = [[NSError alloc] initWithDomain:nil
                                                code:code
                                            userInfo:[NSDictionary dictionaryWithObject:reason
                                                                                 forKey:NSLocalizedDescriptionKey]];
    
    _inflightMessage.failureCallback(error);
}

@end
