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
#import "WEPopoverContainerView.h"

static const NSTimeInterval kDefaultPrimaryAnimationDuration = 0.3;
static const NSTimeInterval kDefaultSecundaryAnimationDuration = 0.15;

@interface WEPopoverController()<WETouchableViewDelegate, WEPopoverContainerViewDelegate>

@property (nonatomic, strong) WEPopoverContainerView *containerView;
@property (nonatomic, strong) WETouchableView *backgroundView;
@property (nonatomic, assign, getter=isPresenting) BOOL presenting;
@property (nonatomic, assign, getter=isDismissing) BOOL dismissing;

@end

@interface WEPopoverController(Private)

- (UIView *)keyViewForView:(UIView *)theView;
- (void)updateBackgroundPassthroughViews;
- (CGRect)displayAreaForView:(UIView *)theView;
- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated completion:(WEPopoverCompletionBlock)completion;
- (void)determineContentSize;
- (CGSize)effectivePopoverContentSize;
- (void)removeView;
- (void)repositionContainerViewForFrameChange;
- (CGRect)collapsedFrameFromFrame:(CGRect)frame forArrowDirection:(UIPopoverArrowDirection)arrowDirection;

@end

NSString * const WEPopoverControllerWillShowNotification = @"WEPopoverWillShowNotification";
NSString * const WEPopoverControllerDidDismissNotification = @"WEPopoverDidDismissNotification";

#define ANIMATE(duration, animationBlock, completionBlock) [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:animationBlock completion:completionBlock]

@implementation WEPopoverController {
    BOOL _popoverVisible;
    CGSize _effectivePopoverContentSize;
    WETouchableView *_backgroundView;
}

static WEPopoverContainerViewProperties *defaultProperties = nil;

static BOOL OSVersionIsAtLeast(float version) {
    return version <= ([[[UIDevice currentDevice] systemVersion] floatValue] + 0.0001);
}

+ (void)setDefaultContainerViewProperties:(WEPopoverContainerViewProperties *)properties {
    if (properties != defaultProperties) {
        defaultProperties = properties;
    }
}

//Enable to use the simple popover style
+ (WEPopoverContainerViewProperties *)defaultContainerViewProperties {
    
    if (defaultProperties) {
        return defaultProperties;
    } else {
        WEPopoverContainerViewProperties *props = [[WEPopoverContainerViewProperties alloc] init];
        
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
        
        props.backgroundMargins = UIEdgeInsetsMake(bgMargin, bgMargin, bgMargin, bgMargin);

        props.leftBgCapSize = bgCapSize;
        props.topBgCapSize = bgCapSize;
        props.bgImageName = bgImageName;

        props.contentMargins = UIEdgeInsetsMake(contentMargin, contentMargin, contentMargin, contentMargin - 1);

        return props;
    }
}


- (id)init {
	if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        self.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        self.animationType = WEPopoverAnimationTypeCrossFade;
        self.primaryAnimationDuration = kDefaultPrimaryAnimationDuration;
        self.secundaryAnimationDuration = kDefaultSecundaryAnimationDuration;
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
}

- (void)setContentViewController:(UIViewController *)vc {
    if (!self.isDismissing) {
        if (vc != _contentViewController) {
            _contentViewController = vc;
        }
    }
}

- (void)repositionForContentViewController:(UIViewController *)vc animated:(BOOL)animated {
    [self setContentViewController:vc];
    [self repositionPopoverFromRect:_presentedFromRect inView:_presentedFromView permittedArrowDirections:_popoverArrowDirection animated:animated];
}

//Overridden setter to copy the passthroughViews to the background view if it exists already
- (void)setPassthroughViews:(NSArray *)array {
	_passthroughViews = nil;
	if (array) {
		_passthroughViews = [[NSArray alloc] initWithArray:array];
	}
	[self updateBackgroundPassthroughViews];
}

- (void)dismissPopoverAnimated:(BOOL)animated {
    [self dismissPopoverAnimated:animated completion:nil];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item
			   permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
							   animated:(BOOL)animated {
	
    [self presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated completion:nil];
}

- (void)presentPopoverFromRect:(CGRect)rect
						inView:(UIView *)theView
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
					  animated:(BOOL)animated {
    [self presentPopoverFromRect:rect inView:theView permittedArrowDirections:arrowDirections animated:animated completion:nil];
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
    
    [self repositionPopoverFromRect:rect inView:theView permittedArrowDirections:arrowDirections animated:animated completion:nil];
}

- (void)dismissPopoverAnimated:(BOOL)animated completion:(WEPopoverCompletionBlock)completion {
    [self dismissPopoverAnimated:animated userInitiated:NO completion:completion];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                               animated:(BOOL)animated
                             completion:(WEPopoverCompletionBlock)completion {
    
    UIView *v = [self keyViewForView:nil];
    CGRect rect = [item weFrameInView:v];
    return [self presentPopoverFromRect:rect inView:v permittedArrowDirections:arrowDirections animated:animated completion:completion];
}

- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)theView
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                      animated:(BOOL)animated
                    completion:(WEPopoverCompletionBlock)completion {
    
    if (!self.isPresenting && !self.isDismissing) {
        [self dismissPopoverAnimated:NO];
        
        self.presenting = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WEPopoverControllerWillShowNotification object:self];
        
        _popoverVisible = YES;
        
        //First force a load view for the contentViewController so the popoverContentSize is properly initialized
        [_contentViewController view];
        
        [self determineContentSize];
        
        CGRect displayArea = [self displayAreaForView:theView];
        
        UIView *keyView = [self keyViewForView:theView];
        
        _backgroundView = [[WETouchableView alloc] initWithFrame:keyView.bounds];
        _backgroundView.contentMode = UIViewContentModeScaleToFill;
        _backgroundView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth |
                                            UIViewAutoresizingFlexibleHeight);
        _backgroundView.fillColor = self.backgroundColor;
        _backgroundView.delegate = self;
        
        [keyView addSubview:_backgroundView];
        
        WEPopoverContainerViewProperties *props = self.containerViewProperties ? self.containerViewProperties : [[self class] defaultContainerViewProperties];
        WEPopoverContainerView *containerView = [[WEPopoverContainerView alloc] initWithSize:self.effectivePopoverContentSize anchorRect:rect displayArea:displayArea permittedArrowDirections:arrowDirections properties:props];
        containerView.delegate = self;
        _popoverArrowDirection = containerView.arrowDirection;
        
        [_backgroundView addSubview:containerView];
        
        containerView.frame = [theView convertRect:containerView.calculatedFrame toView:containerView.superview];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        containerView.contentView = _contentViewController.view;
        
        self.containerView = containerView;
        [self updateBackgroundPassthroughViews];
        
        [self.containerView becomeFirstResponder];
        
        void (^animationCompletionBlock)(BOOL finished) = ^(BOOL finished) {
            self.containerView.userInteractionEnabled = YES;
            _presentedFromRect = rect;
            _presentedFromView = theView;
            self.presenting = NO;
            if (completion) {
                completion();
            }
        };
        
        if (animated) {
            self.backgroundView.fillView.alpha = 0.0;
            
            if (self.animationType == WEPopoverAnimationTypeSlide) {
                
                CGRect finalFrame = self.containerView.frame;
                
                CGRect initialFrame = [self collapsedFrameFromFrame:finalFrame forArrowDirection:_popoverArrowDirection];
                
                self.containerView.frame = initialFrame;
                self.containerView.alpha = 1.0;
                self.containerView.arrowCollapsed = YES;
                
                NSTimeInterval firstAnimationDuration = self.primaryAnimationDuration;
                NSTimeInterval secondAnimationDuration = self.secundaryAnimationDuration;
                
                ANIMATE(firstAnimationDuration, ^{
                    
                    self.containerView.frame = finalFrame;
                    self.backgroundView.fillView.alpha = 1.0;
                    
                }, ^(BOOL finished) {
                    
                    ANIMATE(secondAnimationDuration, ^{
                        self.containerView.arrowCollapsed = NO;
                    }, animationCompletionBlock);
                    
                });
                
            } else {
                self.containerView.alpha = 0.0;
                self.containerView.arrowCollapsed = NO;
                
                ANIMATE(self.primaryAnimationDuration, ^{
                    
                    self.containerView.alpha = 1.0;
                    self.backgroundView.fillView.alpha = 1.0;
                    
                }, animationCompletionBlock);
            }
            
        } else {
            self.containerView.alpha = 1.0;
            self.containerView.arrowCollapsed = NO;
            self.backgroundView.fillView.alpha = 1.0;
            animationCompletionBlock(YES);
        }
    }
}

- (void)repositionPopoverFromRect:(CGRect)rect
                           inView:(UIView *)theView
         permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated
                       completion:(WEPopoverCompletionBlock)completion {
    
    if ([self isPopoverVisible] && !self.isDismissing) {
        _presentedFromRect = CGRectZero;
        _presentedFromView = nil;
        
        UIView *newContentView = [_contentViewController view];
        if (newContentView != self.containerView.contentView) {
            [self.containerView setContentView:newContentView withAnimationDuration:(animated ? self.primaryAnimationDuration : 0.0)];
        }
        
        [self determineContentSize];
        
        CGRect displayArea = [self displayAreaForView:theView];
        WEPopoverContainerView *containerView = self.containerView;
        
        void (^animationBlock)(void) = ^(void) {
            [containerView updatePositionWithSize:self.effectivePopoverContentSize
                                       anchorRect:rect
                                      displayArea:displayArea
                         permittedArrowDirections:arrowDirections];
            _popoverArrowDirection = containerView.arrowDirection;
            containerView.frame = [theView convertRect:containerView.calculatedFrame toView:containerView.superview];
            _presentedFromView = theView;
            _presentedFromRect = rect;
        };
        
        void (^animationCompletionBlock)(BOOL finished) = ^(BOOL finished) {
            if (completion) {
                completion();
            }
        };
        
        if (animated) {
            ANIMATE(self.primaryAnimationDuration, animationBlock, animationCompletionBlock);
        } else {
            animationBlock();
            animationCompletionBlock(YES);
        }
    }
}

#pragma mark - 
#pragma mark WEPopoverContainerViewDelegate

- (CGRect)popoverContainerView:(WEPopoverContainerView *)containerView willChangeFrame:(CGRect)newFrame {
    CGRect rect = newFrame;
    if (_presentedFromView != nil) {
        rect = containerView.frame;
        //Call async because all views will need their frames to be adjusted before we can recalculate
        [self performSelector:@selector(repositionContainerViewForFrameChange) withObject:nil afterDelay:0];
    }
    return rect;
}

#pragma mark -
#pragma mark WETouchableViewDelegate implementation

- (void)viewWasTouched:(WETouchableView *)view {
	if (_popoverVisible) {
		if (!_delegate || ![_delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)] || [_delegate popoverControllerShouldDismissPopover:self]) {
			[self dismissPopoverAnimated:YES userInitiated:YES completion:nil];
		}
	}
}

- (CGRect)fillRectForView:(WETouchableView *)view {
    CGRect rect = view.bounds;
    if ([self.delegate respondsToSelector:@selector(backgroundAreaForPopoverController:relativeToView:)]) {
        rect = [self.delegate backgroundAreaForPopoverController:self relativeToView:view];
    }
    return rect;
}

- (BOOL)isPopoverVisible {
    if (!_popoverVisible) {
        return NO;
    }
    UIView *sv = self.containerView;
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

- (BOOL)isView:(UIView *)v1 inSameHierarchyAsView:(UIView *)v2 {
    BOOL inViewHierarchy = NO;
    while (v1 != nil) {
        if (v1 == v2) {
            inViewHierarchy = YES;
            break;
        }
        v1 = v1.superview;
    }
    return inViewHierarchy;
}

- (UIView *)keyViewForView:(UIView *)theView {
    if (self.parentView) {
        return self.parentView;
    } else {
        UIWindow *w = nil;
        if (theView.window) {
            w = theView.window;
        } else {
            w = [[UIApplication sharedApplication] keyWindow];
        }
        if (w.subviews.count > 0 && (theView == nil || [self isView:theView inSameHierarchyAsView:[w.subviews objectAtIndex:0]])) {
            return [w.subviews objectAtIndex:0];
        } else {
            return w;
        }
    }
}

- (void)updateBackgroundPassthroughViews {
	_backgroundView.passthroughViews = _passthroughViews;
}

- (void)determineContentSize {
    if (CGSizeEqualToSize(_popoverContentSize, CGSizeZero)) {
        if ([_contentViewController respondsToSelector:@selector(preferredContentSize)]) {
            _effectivePopoverContentSize = _contentViewController.preferredContentSize;
        } else {
            _effectivePopoverContentSize = _contentViewController.contentSizeForViewInPopover;
        }
	} else {
        _effectivePopoverContentSize = _popoverContentSize;
    }
}

- (CGSize)effectivePopoverContentSize {
    return _effectivePopoverContentSize;
}

- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated completion:(WEPopoverCompletionBlock)completion {
	if (self.containerView && !self.isDismissing && !self.isPresenting) {
        self.dismissing = YES;
		[self.containerView resignFirstResponder];
        
        void (^animationCompletionBlock)(BOOL finished) = ^(BOOL finished) {
            _popoverVisible = NO;
            
            [self removeView];
            
            self.dismissing = NO;
            
            if (userInitiated) {
                //Only send message to delegate in case the user initiated this event, which is if he touched outside the view
                if ([_delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
                    [_delegate popoverControllerDidDismissPopover:self];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WEPopoverControllerDidDismissNotification object:self];
            
            if (completion) {
                completion();
            }
        };
        
        //To avoid repositions happening during frame change
        self.containerView.delegate = nil;
		if (animated) {
			self.containerView.userInteractionEnabled = NO;
            
            if (self.animationType == WEPopoverAnimationTypeSlide) {
                
                CGRect collapsedFrame = [self collapsedFrameFromFrame:self.containerView.frame forArrowDirection:_popoverArrowDirection];
                
                NSTimeInterval firstAnimationDuration = self.secundaryAnimationDuration;
                NSTimeInterval secondAnimationDuration = self.primaryAnimationDuration;
                
                ANIMATE(firstAnimationDuration, ^{
                    
                    [self.containerView setArrowCollapsed:YES];
                    
                }, ^(BOOL finished) {
                    
                    ANIMATE(secondAnimationDuration, ^{
                        self.containerView.frame = collapsedFrame;
                        _backgroundView.fillView.alpha = 0.0f;
                    }, animationCompletionBlock);
                    
                });
            } else {
                ANIMATE(self.primaryAnimationDuration, ^{
                    
                    self.containerView.alpha = 0.0;
                    self.backgroundView.fillView.alpha = 0.0f;
                    
                }, animationCompletionBlock);
            }
            
		} else {
            animationCompletionBlock(YES);
		}
	}
}

- (void)removeView {
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
    
    _presentedFromView = nil;
    _presentedFromRect = CGRectZero;
}

- (CGRect)displayAreaForView:(UIView *)theView {
    
    UIView *keyView = [self keyViewForView:theView];

    BOOL inViewHierarchy = [self isView:theView inSameHierarchyAsView:keyView];
    
    if (!inViewHierarchy) {
        NSException *ex = [NSException exceptionWithName:@"WEInvalidViewHierarchyException" reason:@"The supplied view to present the popover from is not in the same view hierarchy as the parent view for the popover" userInfo:nil];
        @throw ex;
    }

	CGRect displayArea = CGRectZero;
    
    UIEdgeInsets insets = self.popoverLayoutMargins;
    
    if ([self.delegate respondsToSelector:@selector(displayAreaForPopoverController:relativeToView:)]) {
        displayArea = [self.delegate displayAreaForPopoverController:self relativeToView:keyView];
        displayArea = [keyView convertRect:displayArea toView:theView];
    } else if ([theView conformsToProtocol:@protocol(WEPopoverParentView)] && [theView respondsToSelector:@selector(displayAreaForPopover)]) {
		displayArea = [(id <WEPopoverParentView>)theView displayAreaForPopover];
	} else {
        displayArea = [keyView convertRect:keyView.bounds toView:theView];
        
        if (self.parentView == nil) {
            //Add status bar height
            insets.top += 20.0f;
        }
	}
    
    displayArea = UIEdgeInsetsInsetRect(displayArea, insets);
	return displayArea;
}

- (void)repositionContainerViewForFrameChange {
    if (_presentedFromView != nil) {
        @try {
            CGRect displayArea = [self displayAreaForView:_presentedFromView];
            WEPopoverContainerView *containerView = self.containerView;

            containerView.delegate = nil;

            [containerView updatePositionWithSize:self.effectivePopoverContentSize
                                       anchorRect:_presentedFromRect
                                      displayArea:displayArea
                         permittedArrowDirections:_popoverArrowDirection];

            UIView *theView = _backgroundView;
            CGRect theRect = [_presentedFromView convertRect:containerView.calculatedFrame toView:theView];

            if ([self.delegate respondsToSelector:@selector(popoverController:willRepositionPopoverToRect:inView:)]) {
                [self.delegate popoverController:self willRepositionPopoverToRect:&theRect inView:&theView];
                theRect = [theView convertRect:theRect toView:containerView.superview];
            }

            containerView.frame = theRect;
            containerView.delegate = self;
        }
        @catch (NSException *exception) {
            //Ignore: cannot reposition popover
        }
    }
}

- (CGRect)collapsedFrameFromFrame:(CGRect)frame forArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    CGRect ret = frame;
    if (arrowDirection == UIPopoverArrowDirectionUp) {
        ret = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
    } else if (arrowDirection == UIPopoverArrowDirectionDown) {
        ret = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, 0);
    } else if (arrowDirection == UIPopoverArrowDirectionLeft) {
        ret = CGRectMake(frame.origin.x, frame.origin.y, 0, frame.size.height);
    } else if (arrowDirection == UIPopoverArrowDirectionRight) {
        ret = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, 0, frame.size.height);
    }
    return ret;
}

@end

