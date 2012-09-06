//
//  SHPath.h
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KeyPathAdditions)

- (NSString *)keyPathForObject:(NSObject *)child;

@end

@interface NSArray (KeyPathAdditions)

- (NSString *)keyPathForObject:(NSObject *)child;

@end

@interface SHPath : NSObject

- (NSObject *)objectInArray:(NSArray *)array;
- (NSObject *)objectInDictionary:(NSDictionary *)dictionary;

+ (SHPath *)pathWithKeyPath:(NSString *)keyPath;
+ (SHPath *)pathWithObject:(NSString *)object inArray:(NSArray *)rootArray;
+ (SHPath *)pathWithObject:(NSString *)object inDictionary:(NSArray *)rootDictionary;

- (BOOL)parentOfPath:(SHPath *)path;
- (BOOL)childOfPath:(SHPath *)path;

@property (strong) NSArray *path;

@end
