//
//  SHSocket.h
//  ShareJS
//
//  Created by Hans Pinckaers on 08-09-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

typedef void(^SHMessageSuccessCallback)(NSString* message);
typedef void(^SHMessageFailureCallback)(NSError* error);
typedef void(^SHMessageShouldHandleCallback)(NSString* message, BOOL *handle);

@interface SHCallback : NSObject

@property (copy) SHMessageSuccessCallback successCallback;
@property (copy) SHMessageFailureCallback failureCallback;
@property (copy) SHMessageShouldHandleCallback shouldHandleResponseBlock;

@property (assign) BOOL once;

+ (id)callbackWithSuccessBlock:(SHMessageSuccessCallback)successBlock
                  failureBlock:(SHMessageFailureCallback)failureBlock
          shouldHandleResponse:(SHMessageShouldHandleCallback)shouldHandleResponseBlock;

@end

@interface SHMessage : SHCallback

@property (strong) NSData *message;

+ (id)messageWithMessage:(NSData *)message
                 success:(SHMessageSuccessCallback)successBlock
                 failure:(SHMessageFailureCallback)failureBlock
    shouldHandleResponse:(SHMessageShouldHandleCallback)shouldHandleResponseBlock;

+ (id)messageWithDictionary:(NSDictionary *)dictionary
                    success:(SHMessageSuccessCallback)successBlock
                    failure:(SHMessageFailureCallback)failureBlock
       shouldHandleResponse:(SHMessageShouldHandleCallback)shouldHandleResponseBlock;

@end

@interface SHSocket : NSObject <SRWebSocketDelegate>

@property (strong) NSURL *url;
@property (strong) SHMessage *inflightMessage;
@property (strong) NSMutableArray *callbacks;
@property (strong) SRWebSocket *socket;

- (id)initWithURL:(NSURL *)url;

// connect or reconnect to the doc
- (void)connectToSocket;

//// add message to queue
//- (void)addMessageToQueue:(SHMessage *)message;

- (void)sendMessage:(SHMessage *)message;

// add a callback
- (void)addCallback:(SHCallback *)callback;

// removes a callback
- (void)removeCallback:(SHCallback *)callback;

@end
