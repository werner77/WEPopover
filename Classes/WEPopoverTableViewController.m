//
//  WEPopoverTableViewController.m
//  WEPopover
//
//  Created by Werner Altewischer on 1/4/11.
//  Copyright 2011 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverTableViewController.h"
#import "WEPopoverContentViewController.h"
#import "UIBarButtonItem+WEPopover.h"

@implementation WEPopoverTableViewController

@synthesize popoverController;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Try setting this to UIPopoverController to use the iPad popover. The API is exactly the same!
	popoverClass = [WEPopoverController class];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	currentPopoverCellIndex = -1;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return interfaceOrientation == UIInterfaceOrientationPortrait;
	return YES;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[self.popoverController dismissPopoverAnimated:NO];
	self.popoverController = nil;
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 100;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/**
 Thanks to Paul Solt for supplying these background images and container view properties
 */
- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] autorelease];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13 
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin; 
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	BOOL shouldShowNewPopover = indexPath.row != currentPopoverCellIndex;
	
	if (self.popoverController) {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
		currentPopoverCellIndex = -1;
	} 
	
	if (shouldShowNewPopover) {
		UIViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
		CGRect frame = [tableView cellForRowAtIndexPath:indexPath].frame;
		//double percentage =  (rand() / ((double)RAND_MAX));
		//double percentage = 0.95;
		//CGRect rect = CGRectMake(frame.size.width * percentage, frame.origin.y, 1, frame.size.height); 
		CGRect rect = frame;
		
		self.popoverController = [[[popoverClass alloc] initWithContentViewController:contentViewController] autorelease];
		
		if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
			[self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
		}
		
		self.popoverController.delegate = self;
		
		//Uncomment the line below to allow the table view to handle events while the popover is displayed.
		//Otherwise the popover is dismissed automatically if a user touches anywhere outside of its view.
		
		self.popoverController.passthroughViews = [NSArray arrayWithObject:self.tableView];
		
		[self.popoverController presentPopoverFromRect:rect  
												inView:self.view 
							  permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown|
														UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight)
											  animated:YES];
		currentPopoverCellIndex = indexPath.row;
		
		[contentViewController release];
	}
	
}

#pragma mark -
#pragma mark Actions

- (IBAction)showPopover:(id)sender {
	
	if (!self.popoverController) {
		
		UIViewController *contentViewController = [[WEPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
		self.popoverController = [[[popoverClass alloc] initWithContentViewController:contentViewController] autorelease];
		self.popoverController.delegate = self;
		self.popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
		
		[self.popoverController presentPopoverFromBarButtonItem:sender 
									   permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown) 
													   animated:YES];
		 
		[contentViewController release];
	} else {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
	}
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}


@end

