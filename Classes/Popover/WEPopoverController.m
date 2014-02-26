//
//  WEPopoverController.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverController.h"
#import "WEPopoverParentView.h"
#import "UIBarButtonItem+WEPopover.h"

#define FADE_DURATION 0.3

@interface WEPopoverController()<WETouchableViewDelegate>

@end

@interface WEPopoverController(Private)

- (UIView *)keyView;
- (void)updateBackgroundPassthroughViews;
- (void)setView:(UIView *)v;
- (CGRect)displayAreaForView:(UIView *)theView;
- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated;
- (void)determineContentSize;

@end


@implementation WEPopoverController {
	UIViewController *contentViewController;
	UIView *view;
    UIView *parentView;
	WETouchableView *backgroundView;
	
	BOOL popoverVisible;
	UIPopoverArrowDirection popoverArrowDirection;
	id <WEPopoverControllerDelegate> delegate;
	CGSize popoverContentSize;
	WEPopoverContainerViewProperties *containerViewProperties;
	id <NSObject> context;
	NSArray *passthroughViews;
}

@synthesize contentViewController;
@synthesize popoverContentSize;
@synthesize popoverVisible;
@synthesize popoverArrowDirection;
@synthesize delegate;
@synthesize view;
@synthesize parentView;
@synthesize containerViewProperties;
@synthesize context;
@synthesize passthroughViews;

static WEPopoverContainerViewProperties *defaultProperties = nil;

static BOOL OSVersionIsAtLeast(float version) {
    return version <= ([[[UIDevice currentDevice] systemVersion] floatValue] + 0.0001);
}

+ (void)setDefaultContainerViewProperties:(WEPopoverContainerViewProperties *)properties {
    if (properties != defaultProperties) {
        [defaultProperties release];
        defaultProperties = [properties retain];
    }
}

//Enable to use the simple popover style
+ (WEPopoverContainerViewProperties *)defaultContainerViewProperties {
    
    if (defaultProperties) {
        return defaultProperties;
    } else {
        WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] autorelease];
        
        NSString *bgImageName = nil;
        CGFloat bgMargin = 0.0;
        CGFloat bgCapSize = 0.0;
        CGFloat contentMargin = 0.0;
        
        if (OSVersionIsAtLeast(7.0)) {
            
            bgImageName = @"popoverBg-white.png";
            
            contentMargin = 4.0;
            
            bgMargin = 12;
            bgCapSize = 31;
            
            props.arrowMargin = 4.0;
            
            props.upArrowImageName = @"popoverArrowUp-white.png";
            props.downArrowImageName = @"popoverArrowDown-white.png";
            props.leftArrowImageName = @"popoverArrowLeft-white.png";
            props.rightArrowImageName = @"popoverArrowRight-white.png";
            
        } else {
            bgImageName = @"popoverBg.png";
            
            // These constants are determined by the popoverBg.png image file and are image dependent
            bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
            bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
            
            contentMargin = 4.0;
            
            props.arrowMargin = 4.0;
        
            props.upArrowImageName = @"popoverArrowUp.png";
            props.downArrowImageName = @"popoverArrowDown.png";
            props.leftArrowImageName = @"popoverArrowLeft.png";
            props.rightArrowImageName = @"popoverArrowRight.png";
        }
        
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
        
        return props;
    }
}


- (id)init {
	if ((self = [super init])) {
	}
	return self;
}

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
	[passthroughViews release];
	self.context = nil;
	[super dealloc];
}

- (void)setContentViewController:(UIViewController *)vc {
	if (vc != contentViewController) {
		[contentViewController release];
		contentViewController = [vc retain];
		popoverContentSize = CGSizeZero;
	}
}

- (BOOL)forwardAppearanceMethods {
    return ![contentViewController respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)];
}

//Overridden setter to copy the passthroughViews to the background view if it exists already
- (void)setPassthroughViews:(NSArray *)array {
	[passthroughViews release];
	passthroughViews = nil;
	if (array) {
		passthroughViews = [[NSArray alloc] initWithArray:array];
	}
	[self updateBackgroundPassthroughViews];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)theContext {
	
	if ([animationID isEqual:@"FadeIn"]) {
		self.view.userInteractionEnabled = YES;
		popoverVisible = YES;
        
        if ([self forwardAppearanceMethods]) {
            [contentViewController viewDidAppear:YES];
        }
	} else if ([animationID isEqual:@"FadeOut"]) {
		popoverVisible = NO;
        
        if ([self forwardAppearanceMethods]) {
            [contentViewController viewDidDisappear:YES];
        }
		[self.view removeFromSuperview];
		self.view = nil;
		[backgroundView removeFromSuperview];
		[backgroundView release];
		backgroundView = nil;
		
		BOOL userInitiatedDismissal = [(NSNumber *)theContext boolValue];
		
		if (userInitiatedDismissal) {
			//Only send message to delegate in case the user initiated this event, which is if he touched outside the view
            if ([delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
                [delegate popoverControllerDidDismissPopover:self];
            }
		}
	}
}

- (void)dismissPopoverAnimated:(BOOL)animated {
	
	[self dismissPopoverAnimated:animated userInitiated:NO];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item 
			   permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
							   animated:(BOOL)animated {
	
	UIView *v = [self keyView];
	CGRect rect = [item frameInView:v];
	
	return [self presentPopoverFromRect:rect inView:v permittedArrowDirections:arrowDirections animated:animated];
}

- (void)presentPopoverFromRect:(CGRect)rect 
						inView:(UIView *)theView 
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
					  animated:(BOOL)animated {
	
	
	[self dismissPopoverAnimated:NO];
    
    _presentedFromRect = rect;
    _presentedFromView = theView;
	
	//First force a load view for the contentViewController so the popoverContentSize is properly initialized
	[contentViewController view];
	
	[self determineContentSize];
	
	CGRect displayArea = [self displayAreaForView:theView];
	
	WEPopoverContainerViewProperties *props = self.containerViewProperties ? self.containerViewProperties : [[self class] defaultContainerViewProperties];
	WEPopoverContainerView *containerView = [[[WEPopoverContainerView alloc] initWithSize:self.popoverContentSize anchorRect:rect displayArea:displayArea permittedArrowDirections:arrowDirections properties:props] autorelease];
	popoverArrowDirection = containerView.arrowDirection;
	
	UIView *keyView = self.keyView;
	
	backgroundView = [[WETouchableView alloc] initWithFrame:keyView.bounds];
	backgroundView.contentMode = UIViewContentModeScaleToFill;
	backgroundView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin |
									   UIViewAutoresizingFlexibleWidth |
									   UIViewAutoresizingFlexibleRightMargin |
									   UIViewAutoresizingFlexibleTopMargin |
									   UIViewAutoresizingFlexibleHeight |
									   UIViewAutoresizingFlexibleBottomMargin);
	backgroundView.backgroundColor = [UIColor clearColor];
	backgroundView.delegate = self;
	
	[keyView addSubview:backgroundView];
	
	containerView.frame = [theView convertRect:containerView.frame toView:backgroundView];
	
	[backgroundView addSubview:containerView];
	
	containerView.contentView = contentViewController.view;
	containerView.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin |
									  UIViewAutoresizingFlexibleRightMargin);
	
	self.view = containerView;
	[self updateBackgroundPassthroughViews];
	
    if ([self forwardAppearanceMethods]) {
        [contentViewController viewWillAppear:animated];
    }
	[self.view becomeFirstResponder];
	popoverVisible = YES;
	if (animated) {
		self.view.alpha = 0.0;
        
        [UIView animateWithDuration:FADE_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             self.view.alpha = 1.0;
                             
                         } completion:^(BOOL finished) {
                             
                             [self animationDidStop:@"FadeIn" finished:[NSNumber numberWithBool:finished] context:nil];
                         }];
        		
	} else {
        if ([self forwardAppearanceMethods]) {
            [contentViewController viewDidAppear:animated];
        }
	}	
}

- (void)repositionPopoverFromRect:(CGRect)rect
						   inView:(UIView *)theView
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
{

    [self repositionPopoverFromRect:rect 
                             inView:theView 
           permittedArrowDirections:arrowDirections 
                           animated:NO];
}

- (void)repositionPopoverFromRect:(CGRect)rect
						   inView:(UIView *)theView
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated {
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:FADE_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    [self determineContentSize];
    
    CGRect displayArea = [self displayAreaForView:theView];
	WEPopoverContainerView *containerView = (WEPopoverContainerView *)self.view;
	[containerView updatePositionWithSize:self.popoverContentSize
                               anchorRect:rect
									displayArea:displayArea
					   permittedArrowDirections:arrowDirections];
	
	popoverArrowDirection = containerView.arrowDirection;
	containerView.frame = [theView convertRect:containerView.frame toView:backgroundView];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark WETouchableViewDelegate implementation

- (void)viewWasTouched:(WETouchableView *)view {
	if (popoverVisible) {
		if (!delegate || ![delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)] || [delegate popoverControllerShouldDismissPopover:self]) {
			[self dismissPopoverAnimated:YES userInitiated:YES];
		}
	}
}

- (BOOL)isPopoverVisible {
    if (!popoverVisible) {
        return NO;
    }
    UIView *sv = self.view;
    BOOL foundWindowAsSuperView = NO;
    while ((sv = sv.superview) != nil) {
        if ([sv isKindOfClass:[UIWindow class]]) {
            foundWindowAsSuperView = YES;
            break;
        }
    }
    return foundWindowAsSuperView;
}

@end


@implementation WEPopoverController(Private)

- (UIView *)keyView {
    if (self.parentView) {
        return self.parentView;
    } else {
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w.subviews.count > 0) {
            return [w.subviews objectAtIndex:0];
        } else {
            return w;
        }    
    }
}

- (void)setView:(UIView *)v {
	if (view != v) {
		[view release];
		view = [v retain];
	}
}

- (void)updateBackgroundPassthroughViews {
	backgroundView.passthroughViews = passthroughViews;
}

- (void)determineContentSize {
    if (CGSizeEqualToSize(popoverContentSize, CGSizeZero)) {
        if ([contentViewController respondsToSelector:@selector(preferredContentSize)]) {
            popoverContentSize = contentViewController.preferredContentSize;
        } else {
            popoverContentSize = contentViewController.contentSizeForViewInPopover;
        }
	}
}

- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated {
	if (self.view) {
        if ([self forwardAppearanceMethods]) {
            [contentViewController viewWillDisappear:animated];
        }
		popoverVisible = NO;
		[self.view resignFirstResponder];
		if (animated) {
			self.view.userInteractionEnabled = NO;
            
            [UIView animateWithDuration:FADE_DURATION
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 
                                 self.view.alpha = 0.0;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self animationDidStop:@"FadeOut" finished:[NSNumber numberWithBool:finished] context:[NSNumber numberWithBool:userInitiated]];
                             }];

            
		} else {
            if ([self forwardAppearanceMethods]) {
                [contentViewController viewDidDisappear:animated];
            }
			[self.view removeFromSuperview];
			self.view = nil;
			[backgroundView removeFromSuperview];
			[backgroundView release];
			backgroundView = nil;            
		}
	}
}

- (CGRect)displayAreaForView:(UIView *)theView {
	CGRect displayArea = CGRectZero;
	if ([theView conformsToProtocol:@protocol(WEPopoverParentView)] && [theView respondsToSelector:@selector(displayAreaForPopover)]) {
		displayArea = [(id <WEPopoverParentView>)theView displayAreaForPopover];
	} else {
        UIView *keyView = [self keyView];
		displayArea = [keyView convertRect:keyView.bounds toView:theView];
        //Subtract margin for status bar that may be in view
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        float margin = 10.0f;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            displayArea = CGRectMake(displayArea.origin.x + margin, displayArea.origin.y, displayArea.size.width - 2 * margin, displayArea.size.height);
        } else {
            displayArea = CGRectMake(displayArea.origin.x, displayArea.origin.y + margin, displayArea.size.width, displayArea.size.height - 2 * margin);
        }
	}
	return displayArea;
}

@end
