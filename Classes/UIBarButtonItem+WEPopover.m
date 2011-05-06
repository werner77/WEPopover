/*
 *  UIBarButtonItem+WEPopover.m
 *  WEPopover
 *
 *  Created by Werner Altewischer on 07/05/11.
 *  Copyright 2010 Werner IT Consultancy. All rights reserved.
 *
 */

#import "UIBarButtonItem+WEPopover.h" 

@implementation UIBarButtonItem(WEPopover)

- (CGRect)frameInView:(UIView *)v {

	UIView *currentCustomView = [self.customView retain];
	UIView *tempView = [[UIView alloc] initWithFrame:CGRectZero];

	self.customView = tempView;

	[tempView release];

	UIView *parentView = self.customView.superview;

	NSUInteger indexOfView = [parentView.subviews indexOfObject:self.customView];

	self.customView = currentCustomView;
	[currentCustomView release];

	UIView *button = [parentView.subviews objectAtIndex:indexOfView];

	return [parentView convertRect:button.frame toView:v];
}

@end
