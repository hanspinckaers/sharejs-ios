//
//  NSDictionary+Safe.h
//  
//
//  Created by Sam Soffes on 6/4/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)

- (id)safeObjectForKey:(id)key;
- (BOOL)hasKey:(id)testKey;
- (BOOL)hasKeys:(NSArray *)keys;

@end

@interface NSArray (Safe)

- (id)safeObjectAtIndex:(NSInteger)index;

@end

@interface NSString (Safe)

- (NSDictionary *)dictionaryRepresentation;
- (NSArray *)arrayRepresentation;

@end