//
//  SHJSONOperation.m
//  ShareJS
//
//  Created by Hans Pinckaers on 29-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHJSONOperation.h"
#import "NSDictionary+Safe.h"

static NSMutableDictionary *operationClasses;

@implementation SHJSONOperation
@synthesize path = _path, type = _type;

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (id)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    self = [super init];
    if (self)
    {
        _path = [SHPath pathWithKeyPath:JSONDictionary[@"p"]];
    }
    return self;
}

+ (void)registerClass:(Class<SHOperation>)class forOperationType:(SHType)type
{
    if(!operationClasses) operationClasses = [NSMutableDictionary dictionary];
    [operationClasses setObject:class forKey:[NSNumber numberWithInteger:type]];
}

+ (id)operationWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    SHType type = [self extractTypeFromJSONDictionary:JSONDictionary];
    Class<SHOperation> operationClass = [operationClasses safeObjectForKey:[NSNumber numberWithInteger:type]];
    return [operationClass operationWithJSONDictionary:JSONDictionary];
}

+ (SHType)extractTypeFromJSONDictionary:(NSDictionary *)JSONDictionary
{
    // 'type' string is nothing more than parameters after the path parameter
    NSMutableArray *keys = [[JSONDictionary allKeys] mutableCopy];
    [keys removeObjectAtIndex:0];
    NSString *typeString = [keys componentsJoinedByString:@""];

    if(typeString == @"na") return SHTypeAddsNumber;
    else if(typeString == @"si") return SHTypeInsertString;
    else if(typeString == @"sd") return SHTypeDeleteString;
    else if(typeString == @"li") return SHTypeInsertItemToList;
    else if(typeString == @"ld") return SHTypeDeleteItemInList;
    else if(typeString == @"ldli") return SHTypeReplacesObjectInList;
    else if(typeString == @"lm") return SHTypeMovesObject;
    else if(typeString == @"oi") return SHTypeInsertObjectInObject;
    else if(typeString == @"od") return SHTypeDeleteItemInList;
    else if(typeString == @"odoi") return SHTypeReplaceObjectInObject;
    return SHTypeNone;
}

- (NSDictionary *)jsonDictionary
{
    return nil;
}

- (void)runOnObject:(NSObject**)object;
{
    if([*object isKindOfClass:[NSArray class]])
    {
        NSArray __autoreleasing **array = (NSArray**)object;
        [self runOnArray:array];
    }
    else if([*object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary __autoreleasing **dict = (NSDictionary**)object;
        [self runOnDictionary:dict];
    }
    else {
        NSLog(@"%@ not supported by %@ operation.", NSStringFromClass([*object class]), self);
    }
}

- (void)useClassForObjectTranslation:(Class)class
{
    // ok
}

- (void)runOnDictionary:(NSDictionary **)dictionary
{
    return;
}

- (void)runOnArray:(NSArray **)array
{
    return;
}



@end
