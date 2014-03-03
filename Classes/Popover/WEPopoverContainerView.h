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

@property(nonatomic, retain) NSString *bgImageName;
@property(nonatomic, retain) NSString *upArrowImageName;
@property(nonatomic, retain) NSString *downArrowImageName;
@property(nonatomic, retain) NSString *leftArrowImageName;
@property(nonatomic, retain) NSString *rightArrowImageName;
@property(nonatomic, assign) CGFloat leftBgMargin;
@property(nonatomic, assign) CGFloat rightBgMargin;
@property(nonatomic, assign) CGFloat topBgMargin;
@property(nonatomic, assign) CGFloat bottomBgMargin;
@property(nonatomic, assign) CGFloat leftContentMargin;
@property(nonatomic, assign) CGFloat rightContentMargin;
@property(nonatomic, assign) CGFloat topContentMargin;
@property(nonatomic, assign) CGFloat bottomContentMargin;
@property(nonatomic, assign) NSInteger topBgCapSize;
@property(nonatomic, assign) NSInteger leftBgCapSize;
@property(nonatomic, assign) CGFloat arrowMargin;

@end

@class WEPopoverContainerView;

/**
 * Container/background view for displaying a popover view.
 */
@interface WEPopoverContainerView : UIView

/**
 * The current arrow direction for the popover.
 */
@property (nonatomic, readonly) UIPopoverArrowDirection arrowDirection;

/**
 * The content view being displayed.
 */
@property (nonatomic, retain) UIView *contentView;

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

@end
