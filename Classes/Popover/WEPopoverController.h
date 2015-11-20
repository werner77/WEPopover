//
//  WEPopoverController.h
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WEPopoverContainerViewProperties.h"
#import "WETouchableView.h"

/**
 Notifications for showing/dismissing.
 */
extern NSString * const WEPopoverControllerWillShowNotification;
extern NSString * const WEPopoverControllerDidDismissNotification;

@class WEPopoverController;

/**
 Delegate for popover events.
 */
@protocol WEPopoverControllerDelegate<NSObject>

@optional
/**
 Called when the popover is dismissed by the user.
 
 Not called when the popover is dismissed manually.
 */
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController;

/**
 Return YES to allow dismissal of the popover (default), NO otherwise.
 */
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController;

/**
 Called when the popover will reposition.
 
 The rect and view can be manipulated.
 */
- (void)popoverController:(WEPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view;

/**
 If implemented restricts the popover to the specified area within the specified parentView (by default the parent view is the top most UIView in the view hierarchy).
    The popoverLayoutMargins are applied on top of this display area
 */
- (CGRect)displayAreaForPopoverController:(WEPopoverController *)popoverController relativeToView:(UIView *)parentView;

/**
 If implemented restricts the area that is tinted with the background color. 
 
 Defaults to the whole parentview.
 */
- (CGRect)backgroundAreaForPopoverController:(WEPopoverController *)popoverController relativeToView:(UIView *)parentView;

@end

/**
 Popover animation types.
 */
typedef NS_ENUM(NSUInteger, WEPopoverAnimationType) {
    WEPopoverAnimationTypeCrossFade = 0,
    WEPopoverAnimationTypeSlide = 1
};

typedef void(^WEPopoverCompletionBlock)(void);

/**
 Custom popover controller for iOS, mimicing the iPad UIPopoverController interface. See that class for more details.
 
 This class adds more configuration and layout options.
 */
@interface WEPopoverController : NSObject

/**
 The content view controller to display.
 
 If set while presented, use one of the reposition methods to auto-size the popover for the new content.
 Use the method repositionForContentViewController:animated: for setting the contentViewController and repositioning at the same time.
 
 The content view controller cannot be changed while the popover is dismissing.
 */
@property(nonatomic, strong) UIViewController *contentViewController;

/**
 Returns whether or not the popover is currently presenting (animating to be presented).
 */
@property (nonatomic, readonly, getter=isPresenting) BOOL presenting;

/**
 Returns whether or not the popover is currently dismissing (animating to be dismissed).
 */
@property (nonatomic, readonly, getter=isDismissing) BOOL dismissing;

/**
 The view from which the popover was presented.
 
 Used together with presentedFromRect as anchor point for auto-rotation.
 */
@property(nonatomic, weak, readonly) UIView *presentedFromView;

/**
 The rect from which the popover was presented.
 
 Used together with presentedFromView as anchor point for auto-rotation.
 */
@property(nonatomic, assign, readonly) CGRect presentedFromRect;

/**
 The background color for the background behind the popover.
 
 To tint the background of the popover container view itself, use the containerViewProperties.backgroundColor.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 Returns whether or not the popover is currently visible.
 */
@property (nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;

/**
 The displayed arrow direction for the popover.
 */
@property (nonatomic, readonly) UIPopoverArrowDirection popoverArrowDirection;

/**
 The delegate.
 */
@property (nonatomic, weak) id <WEPopoverControllerDelegate> delegate;

/**
 Content size preferred for the popover.
 
 If set to something other than CGSizeZero this overrides the UIViewController methods preferredContentSize and contentSizeForViewInPopover.
 */
@property (nonatomic, assign) CGSize popoverContentSize;

/**
 Display and layout properties for the popover container view.
 */
@property (nonatomic, strong) WEPopoverContainerViewProperties *containerViewProperties;

/**
 Optional context object to attach to the popover for convenience.
 */
@property (nonatomic, strong) id <NSObject> context;

/**
 If set: this view is used as parent view for the popover.
 
 The background color is applied as overlay to this view. By default this is the first subview of the current key window.
 */
@property (nonatomic, weak) UIView *parentView;

/**
 Array of views that should receive touch events while the popover is visible.
 
 By default the popover blocks all touches from its parent view.
 */
@property (nonatomic, copy) NSArray *passthroughViews;

/**
 The animation type to use.

 Default is WEPopoverAnimationTypeCrossFade
 */
@property (nonatomic, assign) WEPopoverAnimationType animationType;

/**
 Animation duration for fading in/sliding in content.
 
 Default is .3 seconds
 */
@property (nonatomic, assign) NSTimeInterval primaryAnimationDuration;

/**
 Animation duration for sliding in the arrow for animation type WEPopoverAnimationTypeSlide. Is not used for animation type WEPopoverAnimationTypeCrossFade.
 
 Default is .15 seconds
 */
@property (nonatomic, assign) NSTimeInterval secundaryAnimationDuration;

/**
 Layout margins to offset the popover from the edges of its parent view.
 
 Default is 10 pixels each side.
 */
@property(nonatomic, assign) UIEdgeInsets popoverLayoutMargins;

/**
 The default container view properties to be used by the popover.
 */
+ (WEPopoverContainerViewProperties *)defaultContainerViewProperties;
+ (void)setDefaultContainerViewProperties:(WEPopoverContainerViewProperties *)properties;

/**
 Intializes with the specified content view controller.
 */
- (id)initWithContentViewController:(UIViewController *)theContentViewController;

/**
 Dismisses the popover, optionally animating.
 */
- (void)dismissPopoverAnimated:(BOOL)animated;

/**
 Dismisses the popover, optionally animating.
 
 The completion block is called when done.
 */
- (void)dismissPopoverAnimated:(BOOL)animated completion:(WEPopoverCompletionBlock)completion;

/**
 Presents the popover from the specified rect relative to the specified view and permitted arrow directions, optionally animating the presentation.
 
 The view and rect are used as anchor for automatic reposition during rotation.
 */
- (void)presentPopoverFromRect:(CGRect)rect 
						inView:(UIView *)view 
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
					  animated:(BOOL)animated;

/**
 Presents the popover from the specified rect relative to the specified view and permitted arrow directions, optionally animating the presentation.
 
 The completion block is called when done.
 
 The view and rect are used as anchor for automatic reposition during rotation.
 */
- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                      animated:(BOOL)animated
                    completion:(WEPopoverCompletionBlock)completion;

/**
 Presents the popover from the specified bar button item and allowed arrow directions, optionally animating the presentation.
 */
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                               animated:(BOOL)animated;

/**
 Presents the popover from the specified bar button item and allowed arrow directions, optionally animating the presentation.
 
 Calls the completion block when done.
 */
- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                               animated:(BOOL)animated
                             completion:(WEPopoverCompletionBlock)completion;

/**
 Sets the specified content view controller and repositions at the same time using the current anchor frame/arrow direction, optionally animating the reposition.
 
 For more control, assign the contentViewController and call one of the other reposition methods manually.
 
 This method has no effect if the popover is currently dismissing or hasn't been presented yet.
 */
- (void)repositionForContentViewController:(UIViewController *)vc animated:(BOOL)animated;

/**
 Repositions the popover to the specified anchor frame (rect relative to view) and obeying the new permitted arrow directions.
 
 The reposition is optionally animated.
 
 This method has no effect if the popover is currently dismissing or hasn't been presented yet.
 */
- (void)repositionPopoverFromRect:(CGRect)rect
						   inView:(UIView *)view
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated;

/**
 Repositions the popover to the specified anchor frame (rect relative to view) and obeying the new permitted arrow directions.
 
 The reposition is optionally animated.
 The completion block is called when done.
 
 This method has no effect if the popover is currently dismissing or hasn't been presented yet.
 */
- (void)repositionPopoverFromRect:(CGRect)rect
                           inView:(UIView *)view
         permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated
                       completion:(WEPopoverCompletionBlock)completion;

@end
