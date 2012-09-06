//
//  SHJSONClient.m
//  ShareJS
//
//  Created by Hans Pinckaers on 31-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHJSONClient.h"
#import "SHJSONOperation.h"

@interface SHJSONClient ()

@property (strong) NSMutableDictionary *jsonCallbacks;

@end

@implementation SHJSONClient

- (NSString *)addCallback:(SHCallbackBlock)callback forPath:(SHPath *)path type:(SHType)type
{
    if(!_jsonCallbacks) _jsonCallbacks = [NSMutableDictionary dictionary];
    NSDictionary *callbackDict = @{ @"callback" : callback, @"path": path, @"type": [NSNumber numberWithInteger:type] };
    NSString *identifier = [NSString randomString:10];
    [_jsonCallbacks setObject:callbackDict forKey:identifier];
    return identifier;
}

- (void)removeCallbackForKeyPath:(SHPath*)path type:(SHType)type
{
    NSString __block *identifier = nil;
    [_jsonCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *callbackDict = (NSDictionary *)obj;
        if(callbackDict[@"path"] == path && [callbackDict[@"type"] integerValue] == type)
        {
            identifier = (NSString *)key;
            *stop = YES;
        }
    }];
    
    if(identifier) [super removeCallbackWithIdentifier:identifier];
}

- (void)removeAllCallbacks
{
    [super removeAllCallbacks];
    _jsonCallbacks = nil;
}

- (NSArray *)callbacksForOperation:(id<SHOperation>)operation
{
    NSMutableArray *callbacks = [[super callbacksForOperation:operation] mutableCopy];
    [_jsonCallbacks enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj[@"type"] integerValue] == operation.type)
        {
            if([(SHPath *)obj[@"path"] parentOfPath:operation.path])
            {
                [callbacks addObject:obj];
            }
        }
    }];
    return callbacks;
}

- (id<SHOperation>)operationForJSONDictionary:(NSDictionary *)jsonDictionary
{
    return [SHJSONOperation operationWithJSONDictionary:jsonDictionary];
}

@end
