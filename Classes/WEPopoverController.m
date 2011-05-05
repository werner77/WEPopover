//
//  WEPopoverController.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverController.h"
#import "WEPopoverParentView.h"

#define FADE_DURATION 0.25

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

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController {
	if (self = [self init]) {
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
		[backgroundView removeFromSuperview];
		[backgroundView release];
		backgroundView = nil;
	}
}

- (void)dismissPopoverAnimated:(BOOL)animated {
	
	if (self.view) {
		[contentViewController viewWillDisappear:animated];
		popoverVisible = NO;
		[self.view resignFirstResponder];
		if (animated) {
			
			self.view.userInteractionEnabled = NO;
			[UIView beginAnimations:@"FadeOut" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
			
			[UIView setAnimationDuration:FADE_DURATION];
			
			self.view.alpha = 0.0;
			
			[UIView commitAnimations];
		} else {
			[contentViewController viewDidDisappear:animated];
			[self.view removeFromSuperview];
			self.view = nil;
			[backgroundView removeFromSuperview];
			[backgroundView release];
			backgroundView = nil;
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
	
	backgroundView = [[WETouchableView alloc] initWithFrame:theView.bounds];
	backgroundView.backgroundColor = [UIColor clearColor];
	backgroundView.delegate = self;
	
	[theView addSubview:backgroundView];
	
	[backgroundView addSubview:containerView];
	
	containerView.contentView = contentViewController.view;
	
	self.view = containerView;
	[contentViewController viewWillAppear:animated];
	[self.view becomeFirstResponder];
	
	if (animated) {
		self.view.alpha = 0.0;
		
		[UIView beginAnimations:@"FadeIn" context:nil];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationDuration:FADE_DURATION];
		
		self.view.alpha = 1.0;
		
		[UIView commitAnimations];
	} else {
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

#pragma mark -
#pragma mark WETouchableViewDelegate implementation

- (void)viewWasTouched:(WETouchableView *)view {
	if (popoverVisible) {
		if (!delegate || [delegate popoverControllerShouldDismissPopover:self]) {
			[self dismissPopoverAnimated:YES];
			[delegate popoverControllerDidDismissPopover:self];
		}
	}
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
	WEPopoverContainerViewProperties *ret = [[WEPopoverContainerViewProperties new] autorelease];
	
	CGSize imageSize = CGSizeMake(30.0f, 30.0f);
	NSString *bgImageName = @"popoverBg.png";
	CGFloat bgMargin = 5.0;
	CGFloat contentMargin = 3.0;
	
	ret.leftBgMargin = bgMargin;
	ret.rightBgMargin = bgMargin;
	ret.topBgMargin = bgMargin;
	ret.bottomBgMargin = bgMargin;
	ret.leftBgCapSize = imageSize.width/2;
	ret.topBgCapSize = imageSize.height/2;
	ret.bgImageName = bgImageName;
	ret.leftContentMargin = contentMargin;
	ret.rightContentMargin = contentMargin;
	ret.topContentMargin = contentMargin;
	ret.bottomContentMargin = contentMargin;
	
	ret.upArrowImageName = @"popoverArrowUp.png";
	ret.downArrowImageName = @"popoverArrowDown.png";
	ret.leftArrowImageName = @"popoverArrowLeft.png";
	ret.rightArrowImageName = @"popoverArrowRight.png";
	return ret;
}

@end
