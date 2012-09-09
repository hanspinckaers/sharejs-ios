//
//  SHClient.h
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//
// This class is responsible for queuing operations and sending them to our server
// It will call the appropriate callbacks when a operation is received
// 

#import <Foundation/Foundation.h>
#import "SHOperation.h"
#import "NSString+Identifier.h"
#import "SHSocket.h"


typedef void(^SHCallbackBlock)(SHType type, id<SHOperation>operation);

@interface SHClient : SHSocket

- (id)initWithURL:(NSURL *)url docName:(NSString *)docName;

@property (strong) NSString *docName;
@property (strong) NSString *auth;

// opens a document on the server
- (void)openDocument:(NSString*)docName;

// find the right callbacks for this operation
- (NSArray *)callbacksForOperation:(id<SHOperation>)operation;

// add a callback for a certain operation type
- (NSString *)addCallback:(SHCallbackBlock)callback type:(SHType)type;

// remove callback with this identifier
- (void)removeCallbackWithIdentifier:(NSString *)identifier;

// removes all callbacks for a certain type
- (void)removeCallbacksForType:(SHType)type;

// removes all callbacks
- (void)removeAllCallbacks;

// returns callback with this identifier
- (SHCallbackBlock)callbackForIdentifier:(NSString *)identifier;

// should be subclassed
- (id<SHOperation>)operationForJSONDictionary:(NSDictionary *)jsonDictionary;

// ques an operation, sended when we have connection
- (void)submitOperation:(id<SHOperation>)operation;

@end
