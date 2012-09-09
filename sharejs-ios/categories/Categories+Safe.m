//
//  NSDictionary+Safe.m
//  CheddarKit
//
//  Created by Sam Soffes on 6/4/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "Categories+Safe.h"

@implementation NSDictionary (Safe)

// Borrowed from CheddarKit
- (id)safeObjectForKey:(id)key
{
	id value = [self valueForKey:key];
	if (value == [NSNull null])
    {
		return nil;
	}
	return value;
}

- (BOOL)hasKeys:(NSArray *)keys
{
    for(id key in keys)
    {
        if(![self hasKey:key]) return NO;
    }
    return YES;
}

- (BOOL)hasKey:(id)testKey
{
    return ([self objectForKey:testKey] != nil);
}

@end

@implementation NSArray (Safe)

- (id)safeObjectAtIndex:(NSInteger)index
{
    if(index < [self count])
    {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSString (Safe)

- (NSDictionary *)dictionaryRepresentation
{
    NSError *e = nil;
    id dict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                              options:NSJSONReadingMutableContainers
                                                error:&e];
    
    if(e) return nil;
    if([dict isKindOfClass:[NSDictionary class]]) return dict;
    else return nil;
}

- (NSArray *)arrayRepresentation
{
    NSError *e = nil;
    id arr = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                             options:NSJSONReadingMutableContainers
                                               error:&e];
    
    if(e) return nil;
    if([arr isKindOfClass:[NSArray class]]) return arr;
    else return nil;
}

@end
