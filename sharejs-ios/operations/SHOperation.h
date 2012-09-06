//
//  SHOperation.h
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPath.h"

typedef enum 
{
    SHTypeNone,
    SHTypeAddsNumber,
    SHTypeInsertString,
    SHTypeDeleteString,
    SHTypeInsertItemToList,
    SHTypeDeleteItemInList,
    SHTypeReplacesObjectInList,
    SHTypeMovesObject,
    SHTypeInsertObjectInObject,
    SHTypeDeletesObjectInObject,
    SHTypeReplaceObjectInObject
} SHType;

@protocol SHOperation <NSObject>

- (NSDictionary *)jsonDictionary;
+ (id)operationWithJSONDictionary:(NSDictionary *)JSONDictionary;
- (id)initWithJSONDictionary:(NSDictionary *)JSONDictionary;

- (void)runOnObject:(NSObject**)object;

@property (strong) SHPath *path;
@property (assign) SHType type;

@end