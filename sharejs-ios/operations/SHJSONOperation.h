//
//  SHJSONOperation.h
//  ShareJS
//
//  Created by Hans Pinckaers on 29-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHOperation.h"

@interface SHJSONOperation : NSObject <SHOperation>

+ (void)registerClass:(Class)class forOperationType:(SHType)type;
- (void)useClassForObjectTranslation:(Class)class;

- (void)runOnDictionary:(NSDictionary **)dictionary;
- (void)runOnArray:(NSArray **)array;

@end
