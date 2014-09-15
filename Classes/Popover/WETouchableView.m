//
//  WETouchableView.m
//  WEPopover
//
//  Created by Werner Altewischer on 12/21/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WETouchableView.h"

@interface WETouchableView(Private)

- (BOOL)isPassthroughView:(UIView *)v;

@end

@implementation WETouchableView {
	BOOL _testHits;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (_testHits) {
		return nil;
	} else if (_touchForwardingDisabled) {
		return self;
	} else {
		UIView *hitView = [super hitTest:point withEvent:event];
		
		if (hitView == self) {
			//Test whether any of the passthrough views would handle this touch
			_testHits = YES;
			UIView *superHitView = [self.superview hitTest:point withEvent:event];
			_testHits = NO;
			
			if ([self isPassthroughView:superHitView]) {
				hitView = superHitView;
			}
		}
		
		return hitView;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.delegate viewWasTouched:self];
}

@end

@implementation WETouchableView(Private)

- (BOOL)isPassthroughView:(UIView *)v {
	
	if (v == nil) {
		return NO;
	}
	
	if ([_passthroughViews containsObject:v]) {
		return YES;
	}
	
	return [self isPassthroughView:v.superview];
}

@end
