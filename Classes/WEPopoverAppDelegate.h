//
//  WEPopoverAppDelegate.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WEPopoverViewController;

@interface WEPopoverAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;

@end

