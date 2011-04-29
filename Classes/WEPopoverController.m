//
//  PopupViewController.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverController.h"
#import "WEPopoverParentView.h"

#define FADE_DURATION 0.2

@interface WEPopoverController(Private)

- (void)setView:(UIView *)v;
- (CGRect)displayAreaForView:(UIView *)theView;
- (WEPopoverContainerViewProperties *)defaultContainerViewProperties;

@end


@implementation WEPopoverController

@synthesize contentViewController;
@synthesize popoverContentSize;
@synthesize popoverVisible;
@synthesize popoverArrowDirection;
@synthesize delegate;
@synthesize view;
@synthesize containerViewProperties;
@synthesize context;

- (id)initWithContentViewController:(UIViewController *)viewController {
	if ((self = [self init])) {
		self.contentViewController = viewController;
	}
	return self;
}

- (void)dealloc {
	[self dismissPopoverAnimated:NO];
	[contentViewController release];
	[containerViewProperties release];
	self.context = nil;
	[super dealloc];
}

- (void)setContentViewController:(UIViewController *)vc {
	if (vc != contentViewController) {
		[contentViewController release];
		contentViewController = [vc retain];
		popoverContentSize = [vc contentSizeForViewInPopover];
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
	if ([animationID isEqual:@"FadeIn"]) {
		self.view.userInteractionEnabled = YES;
		popoverVisible = YES;
		[contentViewController viewDidAppear:YES];
	} else {
		popoverVisible = NO;
		[contentViewController viewDidDisappear:YES];
		[self.view removeFromSuperview];
		self.view = nil;
	}
}

- (void)dismissPopoverAnimated:(BOOL)animated {
	
	if (self.view) {
		[contentViewController viewWillDisappear:animated];
		
		if (animated) {
			
			self.view.userInteractionEnabled = NO;
			[UIView beginAnimations:@"FadeOut" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			
			[UIView setAnimationDuration:FADE_DURATION];
			
			self.view.alpha = 0.0;
			
			[UIView commitAnimations];
		} else {
			popoverVisible = NO;
			[contentViewController viewDidDisappear:animated];
			[self.view removeFromSuperview];
			self.view = nil;
		}
	}
}

- (void)presentPopoverFromRect:(CGRect)rect 
						inView:(UIView *)theView 
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
					  animated:(BOOL)animated {
	
	
	[self dismissPopoverAnimated:NO];
	
	CGRect displayArea = [self displayAreaForView:theView];
	
	WEPopoverContainerViewProperties *props = self.containerViewProperties ? self.containerViewProperties : [self defaultContainerViewProperties];
	WEPopoverContainerView *containerView = [[[WEPopoverContainerView alloc] initWithSize:self.popoverContentSize anchorRect:rect displayArea:displayArea permittedArrowDirections:arrowDirections properties:props] autorelease];
	popoverArrowDirection = containerView.arrowDirection;
	[theView addSubview:containerView];

	containerView.contentView = contentViewController.view;
	
	self.view = containerView;
	
	[contentViewController viewWillAppear:animated];
	
	if (animated) {
		self.view.userInteractionEnabled = NO;
		self.view.alpha = 0.0;
		
		[UIView beginAnimations:@"FadeIn" context:nil];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDuration:FADE_DURATION];
		
		self.view.alpha = 1.0;
		
		[UIView commitAnimations];
	} else {
		self.view.userInteractionEnabled = YES;
		popoverVisible = YES;
		[contentViewController viewDidAppear:animated];
	}
}

- (void)repositionPopoverFromRect:(CGRect)rect
	   permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections {
	[(WEPopoverContainerView *)self.view updatePositionWithAnchorRect:rect
														displayArea:[self displayAreaForView:self.view.superview]
										   permittedArrowDirections:arrowDirections];
	popoverArrowDirection = ((WEPopoverContainerView *)self.view).arrowDirection;
}


@end


@implementation WEPopoverController(Private)

- (void)setView:(UIView *)v {
	if (view != v) {
		[view release];
		view = [v retain];
	}
}

- (CGRect)displayAreaForView:(UIView *)theView {
	CGRect displayArea = CGRectZero;
	if ([theView conformsToProtocol:@protocol(WEPopoverParentView)] && [theView respondsToSelector:@selector(displayAreaForPopover)]) {
		displayArea = [(id <WEPopoverParentView>)theView displayAreaForPopover];
	} else if ([theView isKindOfClass:[UIScrollView class]]) {
		CGPoint contentOffset = [(UIScrollView *)theView contentOffset];
		displayArea = CGRectMake(contentOffset.x, contentOffset.y, theView.frame.size.width, theView.frame.size.height);
	} else {
		displayArea = CGRectMake(0, 0, theView.frame.size.width, theView.frame.size.height);
	}
	return displayArea;
}

- (WEPopoverContainerViewProperties *)defaultContainerViewProperties {
	WEPopoverContainerViewProperties *ret = [[WEPopoverContainerViewProperties alloc] autorelease];
	
    // Values based on the provided popoverBgSmall.png image, using stretchable UIImage caps
    // popoverBgSmall.png is 94x94 pixels
    // 18x18 pixel image with dropshaow
    
	//static const NSInteger CAP_SIZE = 44/2; //94; //94; 
	//static const CGFloat BG_IMAGE_MARGIN = 26/ 2; //76/ 2; //76;
			
	CGSize theSize = self.popoverContentSize;
	
	NSLog(@"TheSize: %@", NSStringFromCGSize(theSize));
	
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
    
    bgImageName = @"popoverBg.png";
    bgMargin = 13; // minimum margin width of 13 pixels on all sides popoverBg.png //14; //52-26 / 2 // 17; // (Imagesize - 18 pixels)/2 //15; //BG_IMAGE_MARGIN / 2; 
    bgCapSize = 31; //26; // ImageSize/2  //44-18; //CAP_SIZE / 2;

	ret.leftBgMargin = bgMargin;
	ret.rightBgMargin = bgMargin;
	ret.topBgMargin = bgMargin;
	ret.bottomBgMargin = bgMargin;
	ret.leftBgCapSize = bgCapSize;
	ret.topBgCapSize = bgCapSize;
	ret.bgImageName = bgImageName;
	ret.leftContentMargin = contentMargin;
	ret.rightContentMargin = contentMargin - 1;// + 1;// + 2;
	ret.topContentMargin = contentMargin; // + 1;
	ret.bottomContentMargin = contentMargin; // + 1;
	
	ret.upArrowImageName = @"popoverArrowUp.png";
	ret.downArrowImageName = @"popoverArrowDown.png";
	ret.leftArrowImageName = @"popoverArrowLeft.png";
	ret.rightArrowImageName = @"popoverArrowRight.png";
	return ret;
}

@end
