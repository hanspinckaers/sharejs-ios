//
//  NSString+Identifier.m
//  ShareJS
//
//  Created by Hans Pinckaers on 01-09-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "NSString+Identifier.h"

@implementation NSString (Identifier)

+ (NSString *)randomString:(NSInteger)lenght
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:lenght];
    
    for (int i=0; i<lenght; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

@end
