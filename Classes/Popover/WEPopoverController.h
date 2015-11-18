//
//  WEPopoverController.h
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WEPopoverContainerView.h"
#import "WETouchableView.h"

@class WEPopoverController;

@protocol WEPopoverControllerDelegate<NSObject>

@optional
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController;
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController;
- (void)popoverController:(WEPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view;

//If implemented restricts the popover to the specified area within the specified parentView (by default the parent view is the top most UIView in the view hierarchy).
//The popoverLayoutMargins are applied on top of this display area
- (CGRect)displayAreaForPopoverController:(WEPopoverController *)popoverController relativeToView:(UIView *)parentView;

//If implemented restricts the area that is tinted with the background color. Defaults to the whole parentview.
- (CGRect)backgroundAreaForPopoverController:(WEPopoverController *)popoverController relativeToView:(UIView *)parentView;

@end

typedef NS_ENUM(NSUInteger, WEPopoverAnimationType) {
    WEPopoverAnimationTypeCrossFade = 0,
    WEPopoverAnimationTypeSlide = 1
};

typedef void(^WEPopoverCompletionBlock)(void);

/**
 * Popover controller for the iPhone, mimicing the iPad UIPopoverController interface. See that class for more details.
 */
@interface WEPopoverController : NSObject

@property(nonatomic, strong) UIViewController *contentViewController;

@property(nonatomic, weak, readonly) UIView *presentedFromView;
@property(nonatomic, assign, readonly) CGRect presentedFromRect;

@property (weak, nonatomic, readonly) UIView *view;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;
@property (nonatomic, readonly) UIPopoverArrowDirection popoverArrowDirection;
@property (nonatomic, weak) id <WEPopoverControllerDelegate> delegate;
@property (nonatomic, assign) CGSize popoverContentSize;
@property (nonatomic, strong) WEPopoverContainerViewProperties *containerViewProperties;
@property (nonatomic, strong) id <NSObject> context;

//If set: this view is used as parent view for the popover.
//The background color is applied as overlay to this view. By default this is the first subview of the window.
@property (nonatomic, weak) UIView *parentView;

@property (nonatomic, copy) NSArray *passthroughViews;

//Default is WEPopoverAnimationTypeCrossFade
@property (nonatomic, assign) WEPopoverAnimationType animationType;

//Default is .3 seconds
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property(nonatomic, assign) UIEdgeInsets popoverLayoutMargins;

+ (WEPopoverContainerViewProperties *)defaultContainerViewProperties;
+ (void)setDefaultContainerViewProperties:(WEPopoverContainerViewProperties *)properties;

- (id)initWithContentViewController:(UIViewController *)theContentViewController;

- (void)dismissPopoverAnimated:(BOOL)animated;

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item 
			   permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
							   animated:(BOOL)animated;

- (void)presentPopoverFromRect:(CGRect)rect 
						inView:(UIView *)view 
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
					  animated:(BOOL)animated;

- (void)repositionPopoverFromRect:(CGRect)rect
						   inView:(UIView *)view
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections;

- (void)repositionPopoverFromRect:(CGRect)rect
						   inView:(UIView *)view
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated;


- (void)dismissPopoverAnimated:(BOOL)animated completion:(WEPopoverCompletionBlock)completion;

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                               animated:(BOOL)animated
                             completion:(WEPopoverCompletionBlock)completion;;

- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                      animated:(BOOL)animated
                    completion:(WEPopoverCompletionBlock)completion;;

- (void)repositionPopoverFromRect:(CGRect)rect
                           inView:(UIView *)view
         permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated
                       completion:(WEPopoverCompletionBlock)completion;;

@end
