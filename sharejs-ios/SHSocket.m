//
//  SHSocket.m
//  ShareJS
//
//  Created by Hans Pinckaers on 08-09-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHSocket.h"

@interface SHSocket () 

@property (strong) NSMutableArray *queue;

@end


@implementation SHCallback

+ (id)callbackWithSuccessBlock:(SHMessageSuccessCallback)successBlock
                  failureBlock:(SHMessageFailureCallback)failureBlock
          shouldHandleResponse:(SHMessageShouldHandleCallback)shouldHandleResponseBlock
{
    SHMessage *message = [[[self class] alloc] init];
    
    if(message)
    {
        message.successCallback = successBlock;
        message.failureCallback = failureBlock;
        message.shouldHandleResponseBlock = shouldHandleResponseBlock;
    }
    
    return message;
}

@end

@implementation SHMessage

+ (id)messageWithMessage:(NSData *)messageData
                 success:(SHMessageSuccessCallback)successBlock
                 failure:(SHMessageFailureCallback)failureBlock
    shouldHandleResponse:(SHMessageShouldHandleCallback)shouldHandleResponseBlock;
{
    SHMessage *message = [[[self class] alloc] init];
        
    if(message)
    {
        message.successCallback = successBlock;
        message.failureCallback = failureBlock;
        message.shouldHandleResponseBlock = shouldHandleResponseBlock;
        
        message.message = messageData;
        message.once = YES;
    }
    
    return message;
}

+ (id)messageWithDictionary:(NSDictionary *)dictionary
                    success:(SHMessageSuccessCallback)successBlock
                    failure:(SHMessageFailureCallback)failureBlock
       shouldHandleResponse:(SHMessageShouldHandleCallback)shouldHandleResponseBlock
{
    SHMessage *message = [[[self class] alloc] init];
    
    if(message)
    {
        message.successCallback = successBlock;
        message.failureCallback = failureBlock;
        message.shouldHandleResponseBlock = shouldHandleResponseBlock;
            
        NSError *error;
        NSData *messageData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONReadingMutableContainers error:&error];
        if(!error) message.message = messageData;

        message.once = YES;
    }
    
    return message;
}

@end

@implementation SHSocket

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _url = url;
    }
    return self;
}

- (void)connectToSocket
{
    if(!_socket)
    {
        _socket = [[SRWebSocket alloc] initWithURL:self.url];
        _socket.delegate = self;
    }
    
    [_socket open];
}

#pragma mark - Socket communicator

//- (void)addMessageToQueue:(SHMessage *)message
//{
//    if(!_queue) _queue = [NSMutableArray array];
//    [_queue addObject:message];
//    [self sendNextMessageOfQueue];
//}
//
//- (void)sendNextMessageOfQueue
//{
//    if([_queue count] == 0 || _inflightMessage) return;
//    
//    _inflightMessage = [_queue lastObject];
//    [_queue removeLastObject];
//    if(_inflightMessage.message) [_socket send:_inflightMessage.message];
//}

- (void)sendMessage:(SHMessage *)message
{
    if(!_queue) _queue = [NSMutableArray array];
    if(!_callbacks) _callbacks = [NSMutableArray array];

    [_queue addObject:message];
    
    [_callbacks addObject:message];
    [_socket send:message.message];
}

- (void)addCallback:(SHCallback *)callback
{
    if(!_callbacks) _callbacks = [NSMutableArray array];
    [_callbacks addObject:callback];
}

- (void)removeCallback:(SHCallback *)callback
{
    [_callbacks removeObject:callback];
}

#pragma mark - SocketRocket delegate methods

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"didReceiveMessage: %@", message);
        
    if(![message isKindOfClass:[NSString class]]) return;
    
    NSMutableArray *shouldDeleteCallbacks = [NSMutableArray array];
    for(SHCallback *callback in _callbacks)
    {
        BOOL handle = NO;
        callback.shouldHandleResponseBlock(message, &handle);
        if(handle)
        {
            callback.successCallback(message);
            if(callback.once) [shouldDeleteCallbacks addObject:callback];
        }
    }
    for(SHCallback *shouldDeleteCallback in shouldDeleteCallbacks)
    {
        if([_queue containsObject:shouldDeleteCallback]) [_queue removeObject:shouldDeleteCallback];
        [_callbacks removeObject:shouldDeleteCallback];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);

}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{

}

@end
