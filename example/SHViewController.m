//
//  SHViewController.m
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import "SHViewController.h"

@interface SHViewController ()

@end

@implementation SHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [NSURL URLWithString:@"ws://localhost:8000/sockjs/websocket"];
    _client = [[SHJSONClient alloc] initWithURL:url docName:@"groceries"];
    
    NSMutableArray __block *groceries = [@[ @"milk", @"bread", @"eggs" ] mutableCopy];

    [_client addCallback:^(SHType type, id<SHOperation> operation) {
        
        // item add to array items in dictionary list.
        [operation runOnObject:&groceries];
        
    } forPath:[SHPath pathWithKeyPath:@"list.items"] type:SHTypeInsertItemToList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
