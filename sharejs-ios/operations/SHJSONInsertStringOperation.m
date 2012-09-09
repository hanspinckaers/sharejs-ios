//
//  SHJSONInsertStringOperation.m
//  ShareJS
//
//  Created by Hans Pinckaers on 29-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHJSONInsertStringOperation.h"
#import "Categories+Safe.h"

@implementation SHJSONInsertStringOperation
@synthesize path = _path, type = _type;

+ (id)operationWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    // init with JSONDictionary
    return [[[self class] alloc] initWithJSONDictionary:JSONDictionary];
}

- (id)initWithJSONDictionary:(NSDictionary *)JSONDictionary
{
    self = [super initWithJSONDictionary:JSONDictionary];
    
    if(self)
    {
        _type = SHTypeInsertString;
        _insertedString = [JSONDictionary safeObjectForKey:@"si"];
    }
    
    return self;
}

- (id)initWithPath:(SHPath *)path insertedString:(NSString *)string
{
    self = [super init];
    
    if(self)
    {
        _insertedString = string;
    }
    
    return self;
}

+ (id)operationWithPath:(SHPath *)path insertedString:(NSString *)string
{
    return [[[self class] alloc] initWithPath:path insertedString:string];
}

- (NSDictionary *)jsonDictionary
{
    return @{ @"p" : _path, @"si" : _insertedString };
}

- (void)runOnArray:(NSArray **)array
{
    NSObject *object = [_path objectInArray:*array];
    if([object isKindOfClass:[NSMutableArray class]])
    {
        [(NSMutableArray *)object addObject:_insertedString];
    }
}

- (void)runOnDictionary:(NSDictionary **)dictionary
{
    NSObject *object = [_path objectInDictionary:*dictionary];
    if([object isKindOfClass:[NSMutableArray array]])
    {
        [(NSMutableArray *)object addObject:_insertedString];
    }
}

@end
