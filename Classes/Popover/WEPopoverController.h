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

@end

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
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, copy) NSArray *passthroughViews;

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

@end
