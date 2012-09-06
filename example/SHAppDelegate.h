//
//  SHAppDelegate.h
//  ShareJS
//
//  Created by Hans Pinckaers on 28-08-12.
//  Copyright (c) 2012 Hans Pinckaers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SHViewController;

@interface SHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SHViewController *viewController;

@end
