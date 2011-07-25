//
//  WEPopoverViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WEPopoverController;

@interface WEPopoverViewController : UIViewController {
	WEPopoverController *popoverController;
}

@property (nonatomic, retain) WEPopoverController *popoverController;

- (IBAction)onButtonClick:(UIButton *)button;

@end

