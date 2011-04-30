//
//  WEPopoverAppDelegate.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class WEPopoverViewController;
@class WEPopoverTableViewController;

@interface WEPopoverAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
//    WEPopoverViewController *viewController;
	WEPopoverTableViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet WEPopoverViewController *viewController;
@property (nonatomic, retain) IBOutlet WEPopoverTableViewController *viewController;


@end

