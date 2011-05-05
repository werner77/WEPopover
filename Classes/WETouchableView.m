//
//  WETouchableView.m
//  WEPopover
//
//  Created by Werner Altewischer on 12/21/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WETouchableView.h"

@implementation WETouchableView

@synthesize touchForwardingDisabled, delegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (touchForwardingDisabled) {
		return self;
	} else {
		return [super hitTest:point withEvent:event];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.delegate viewWasTouched:self];
}

@end
