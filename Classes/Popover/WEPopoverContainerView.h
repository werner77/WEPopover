//
//  WEPopoverContainerView.h
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * Properties for the container view determining the area where the actual content view can/may be displayed. Also Images can be supplied for the arrow images and background.
 */
@interface WEPopoverContainerViewProperties : NSObject

@property(nonatomic, assign) UIEdgeInsets backgroundMargins;
@property(nonatomic, assign) UIEdgeInsets contentMargins;
@property(nonatomic, assign) NSInteger topBgCapSize;
@property(nonatomic, assign) NSInteger leftBgCapSize;
@property(nonatomic, assign) CGFloat arrowMargin;

@property(nonatomic, strong) UIColor *maskBorderColor;
@property(nonatomic, assign) CGFloat maskBorderWidth;
@property(nonatomic, assign) CGFloat maskCornerRadius;
@property(nonatomic, strong) UIColor *backgroundColor;

@property(nonatomic, strong) UIImage *upArrowImage;
@property(nonatomic, strong) UIImage *downArrowImage;
@property(nonatomic, strong) UIImage *leftArrowImage;
@property(nonatomic, strong) UIImage *rightArrowImage;
@property(nonatomic, strong) UIImage *bgImage;

//Deprecated: use upArrowImage, downArrowImage, etc instead.
@property(nonatomic, strong) NSString *upArrowImageName;
@property(nonatomic, strong) NSString *downArrowImageName;
@property(nonatomic, strong) NSString *leftArrowImageName;
@property(nonatomic, strong) NSString *rightArrowImageName;
@property(nonatomic, strong) NSString *bgImageName;

@end

@class WEPopoverContainerView;

@protocol WEPopoverContainerViewDelegate <NSObject>

/**
 Implement to override the frame being set in setFrame:
 */
- (CGRect)popoverContainerView:(WEPopoverContainerView *)view willChangeFrame:(CGRect)newFrame;

@end


/**
 * Container/background view for displaying a popover view.
 */
@interface WEPopoverContainerView : UIView

@property (nonatomic, weak) id <WEPopoverContainerViewDelegate> delegate;

/**
 * The current arrow direction for the popover.
 */
@property (nonatomic, readonly) UIPopoverArrowDirection arrowDirection;

/**
 * The content view being displayed.
 */
@property (nonatomic, strong) UIView *contentView;

/**
 Whether or not the arrow is collapsed.
 */
@property (nonatomic, assign, getter=isArrowCollapsed) BOOL arrowCollapsed;

/**
 * Initializes the position of the popover with a size, anchor rect, display area and permitted arrow directions and optionally the properties. 
 * If the last is not supplied the defaults are taken (requires images to be present in bundle representing a black rounded background with partial transparency).
 */
- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)properties;

/**
 * To update the position of the popover with a new anchor rect, display area and permitted arrow directions
 */
- (void)updatePositionWithSize:(CGSize)theSize
                    anchorRect:(CGRect)anchorRect
                   displayArea:(CGRect)displayArea
      permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;

- (CGRect)calculatedFrame;

@end
