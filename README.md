# WEPopover

The WEPopover is designed to mimic the behavior and appearance of the UIPopover only available on iPad. It is designed to work on iPad, iPhone, and includes support for Retina displays.


## Example Usage

	// Header .h
	#include "WEPopoverController.h"
	...
	WEPopoverController *navPopover;

	// Implementation .m

	// Create a label with custom text 
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
	[label setText:@"Bookmark it!"];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:[UIColor whiteColor]];
	[label setTextAlignment:UITextAlignmentCenter];

	UIFont *font = [UIFont boldSystemFontOfSize:20];
	[label setFont:font];
	CGSize size = [label.text sizeWithFont:font];
	CGRect frame = CGRectMake(0, 0, size.width + 10, size.height + 10); // add a bit of a border around the text
	label.frame = frame;

	//  place inside a temporary view controller and add to popover
	UIViewController *viewCon = [[UIViewController alloc] init];
	viewCon.view = label;
	viewCon.contentSizeForViewInPopover = frame.size;		// Set the content size

	navPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
	[navPopover presentPopoverFromRect:CGRectMake(0, 0, 50, 57)
	                                   inView:self.view
	                 permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
	                                 animated:YES];
## iOS

![iPhone](http://paulsolt.com/wp-content/uploads/2011/04/iPhone.jpg)
![iPhone 4](http://paulsolt.com/wp-content/uploads/2011/04/iPhone4.jpg)


