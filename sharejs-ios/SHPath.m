//
//  SHPath.m
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHPath.h"
#import "NSDictionary+Safe.h"

@implementation SHPath

- (NSObject *)objectInArray:(NSArray *)array
{
    return [self objectInObject:array];
}

- (NSObject *)objectInDictionary:(NSDictionary *)dictionary
{
    return [self objectInDictionary:dictionary];
}

- (NSObject *)objectInObject:(NSObject *)object
{
    NSObject *current = object;
    for(NSObject *subpath in _path)
    {
        if([subpath isKindOfClass:[NSNumber class]] && [current isKindOfClass:[NSArray class]])
        {
            current = [(NSArray *)current safeObjectAtIndex:[(NSNumber*)subpath integerValue]];
        }
        else if([subpath isKindOfClass:[NSString class]] && [current isKindOfClass:[NSDictionary class]])
        {
            current = [(NSDictionary *)current safeObjectForKey:subpath];
        }
        if(!current)
        {
            return nil; // not found
        }
    }
    return current;
}

+ (SHPath *)pathWithKeyPath:(NSString *)keyPath
{
    return nil;
}

+ (SHPath *)pathWithObject:(NSString *)object inArray:(NSArray *)rootArray
{
        return nil;
}

+ (SHPath *)pathWithObject:(NSString *)object inDictionary:(NSArray *)rootDictionary
{
        return nil;
}

- (BOOL)parentOfPath:(SHPath *)path
{
    return NO;
}

- (BOOL)childOfPath:(SHPath *)path
{
    return NO;
}

@end
