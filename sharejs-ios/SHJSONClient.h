//
//  SHJSONClient.h
//  ShareJS
//
//  Created by Hans Pinckaers on 31-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHClient.h"

@interface SHJSONClient : SHClient

// this should be in the JSONClient?
- (NSString *)addCallback:(SHCallbackBlock)callback forPath:(SHPath *)path type:(SHType)type; // return identifier

// remove a callback for a certain keypath and type
- (void)removeCallbackForKeyPath:(NSString*)keypath type:(SHType)type;

@end
