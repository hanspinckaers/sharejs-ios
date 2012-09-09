//
//  SHClient.m
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHClient.h"
#import "Categories+Safe.h"

@interface SHClient ()

@property (strong) NSMutableDictionary *shareCallbacks;
@property (strong) NSMutableArray *unsendedOperations;

@end

@implementation SHClient

- (id)initWithURL:(NSURL *)url docName:(NSString *)docName
{
    self = [super init];
    
    if(self)
    {        
        self.url = url;
        _docName = docName;
        [self connectToSocket];
    }
    
    return self;
}

- (void)connectToSocket
{    
    SHMessage *authMessage = [SHMessage messageWithMessage:nil success:^(NSString* message)
    {
        NSDictionary *messageDict = [message dictionaryRepresentation];
        
        if(_auth == nil && messageDict[@"auth"] != nil)
            _auth = messageDict[@"auth"];

        NSLog(@"_auth %@", _auth);
        
        [self openDocument:_docName];
      
    } failure:^(NSError *error) {
        
    } shouldHandleResponse:^(NSString *message, BOOL *handle) {
        
        NSDictionary *messageDict = [message dictionaryRepresentation];
        if(messageDict && [messageDict hasKey:@"auth"]) *handle = YES;
        
    }];
    
    [self sendMessage:authMessage];

    [super connectToSocket];
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
    
    SHMessage *message = [SHMessage messageWithMessage:[operation data]
                                               success:^(id message)
    {
        
        NSDictionary *respons = [message dictionaryRepresentation];
        id<SHOperation> operation = [self operationForJSONDictionary:respons];
        NSArray *callbacks = [self callbacksForOperation:operation];
        [callbacks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SHCallbackBlock callback = (SHCallbackBlock)obj[@"callback"];
            callback(operation.type, operation);
        }];
        [_unsendedOperations removeObject:operation];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Error sending message: %@", error);
        
    } shouldHandleResponse:^(NSString *message, BOOL *handle) {
        
    }];
    
    [self sendMessage:message];
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
    [_shareCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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
    if(!_shareCallbacks) _shareCallbacks = [NSMutableDictionary dictionary];
    NSDictionary *callbackDict = @{ @"callback" : callback, @"type" : [NSNumber numberWithInteger:type] };
    NSString *identifier = [NSString randomString:10];
    [_shareCallbacks setObject:callbackDict forKey:identifier];
    return identifier;
}

// remove callback with this identifier
- (void)removeCallbackWithIdentifier:(NSString *)identifier
{
    [_shareCallbacks removeObjectForKey:identifier];
}

// removes all callbacks for a certain type
- (void)removeCallbacksForType:(SHType)type
{
    NSMutableDictionary *newCallbacks = [_shareCallbacks mutableCopy];
    [_shareCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj[@"type"] integerValue] == type)
        {
            [newCallbacks removeObjectForKey:key];
        }
    }];
    _shareCallbacks = newCallbacks;
}

// removes all callbacks
- (void)removeAllCallbacks
{
    _shareCallbacks = nil;
}

// returns callback with this identifier
- (SHCallbackBlock)callbackForIdentifier:(NSString *)identifier
{
    return [_shareCallbacks objectForKey:identifier][@"callback"];
}


- (void)removeCallbackForIdentifier:(NSString *)identifier
{
    [_shareCallbacks removeObjectForKey:identifier];
}

#pragma mark - SocketRocket delegate methods

//- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
//{
//    NSLog(@"%@", error);
//    _inflightMessage.failureCallback(error);
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
//{
//    NSError *error = [[NSError alloc] initWithDomain:nil
//                                                code:code
//                                            userInfo:[NSDictionary dictionaryWithObject:reason
//                                                                                 forKey:NSLocalizedDescriptionKey]];
//    
//    _inflightMessage.failureCallback(error);
//}

@end
