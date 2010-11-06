//
//  WEPopoverViewController.m
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverViewController.h"
#import "WEPopoverController.h"
#import "WEPopoverContentViewController.h"

@implementation WEPopoverViewController

@synthesize popoverController;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[self.popoverController dismissPopoverAnimated:NO];
	self.popoverController = nil;
}

- (IBAction)onButtonClick:(UIButton *)button {
	
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
		[button setTitle:@"Show Popover" forState:UIControlStateNormal];
	} else {
		UIViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
		
		self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentViewController] autorelease];
		[self.popoverController presentPopoverFromRect:button.frame 
												inView:self.view 
							  permittedArrowDirections:UIPopoverArrowDirectionDown
											  animated:YES];
		[contentViewController release];
		[button setTitle:@"Hide Popover" forState:UIControlStateNormal];
	}
}

- (void)dealloc {
	[self viewDidUnload];
    [super dealloc];
}

@end
