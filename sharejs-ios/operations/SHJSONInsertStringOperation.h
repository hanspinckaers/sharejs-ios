//
//  SHJSONInsertStringOperation.h
//  ShareJS
//
//  Created by Hans Pinckaers on 29-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHJSONOperation.h"
#import "SHPath.h"

@interface SHJSONInsertStringOperation : SHJSONOperation

- (id)initWithPath:(SHPath *)path insertedString:(NSString *)string;
+ (id)operationWithPath:(SHPath *)path insertedString:(NSString *)string;

@property (strong) NSString *insertedString;

@end
