//
//  NSDictionary+Safe.m
//  CheddarKit
//
//  Created by Sam Soffes on 6/4/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "NSDictionary+Safe.h"

@implementation NSDictionary (Safe)

// Borrowed from CheddarKit
- (id)safeObjectForKey:(id)key {
	id value = [self valueForKey:key];
	if (value == [NSNull null]) {
		return nil;
	}
	return value;
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
