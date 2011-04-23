//
//  WEPopoverTableViewController.m
//  WEPopover
//
//  Created by X082540 on 1/4/11.
//  Copyright 2011 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverTableViewController.h"
#import "WEPopoverContentViewController.h"

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	currentPopoverCellIndex = -1;
	
	UIBarButtonItem *leftButton = [[UIBarButtonItem	alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(bookmarks:)];
	
    
	self.navigationItem.leftBarButtonItem = leftButton;
	self.navigationItem.rightBarButtonItem = rightButton;
	
	[leftButton release];
	[rightButton release];
}

- (void)add:(id)sender {
	NSLog(@"Add Button Pressed");
}

- (void)bookmarks:(id)sender {
	NSLog(@"Bookmarks Button Pressed");
    
    static int x = 50;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [label setText:@"Hello World"];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    UIViewController *viewCon = [[UIViewController alloc] init];
    viewCon.view = label;
    viewCon.contentSizeForViewInPopover = CGSizeMake(100, 36);
    
    
    NSLog(@"Label Frame: %@", NSStringFromCGRect(label.frame));
    NSLog(@"Popover size: %@", NSStringFromCGSize(viewCon.contentSizeForViewInPopover));
    NSLog(@"ViewCon: %@", NSStringFromCGRect(viewCon.view.frame));
    
    WEPopoverController *pop = [[WEPopoverController alloc] initWithContentViewController:viewCon];
    [pop presentPopoverFromRect:CGRectMake(360-x, 0, 50, 57)
                                            inView:self.navigationController.view
                          permittedArrowDirections:UIPopoverArrowDirectionUp//UIPopoverArrowDirectionDown|
     
                                          animated:YES];

    
    x+=40;

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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


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
		
		self.popoverController = [[[WEPopoverController alloc] initWithContentViewController:contentViewController] autorelease];
		[self.popoverController presentPopoverFromRect:frame 
												inView:self.view 
							  permittedArrowDirections:UIPopoverArrowDirectionDown|UIPopoverArrowDirectionUp
											  animated:YES];
		
		currentPopoverCellIndex = indexPath.row;
		
		[contentViewController release];
	}
	
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

