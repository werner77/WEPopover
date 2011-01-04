//
//  WhiteboardNodeDetailsView.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties

@synthesize bgImageName, upArrowImageName, downArrowImageName, leftArrowImageName, rightArrowImageName, topBgMargin, bottomBgMargin, leftBgMargin, rightBgMargin, topBgCapSize, leftBgCapSize;
@synthesize leftContentMargin, rightContentMargin, topContentMargin, bottomContentMargin;

- (void)dealloc {
	self.bgImageName = nil;
	self.upArrowImageName = nil;
	self.downArrowImageName = nil;
	self.leftArrowImageName = nil;
	self.rightArrowImageName = nil;
	[super dealloc];
}

@end

@interface WEPopoverContainerView(Private)

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)props;

@end

@implementation WEPopoverContainerView

@synthesize arrowDirection, contentView;

- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
			 displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)theProperties {
	if (self = [super initWithFrame:CGRectZero]) {
		
		self.properties = theProperties;
		correctedSize = CGSizeMake(theSize.width + properties.leftBgMargin + properties.rightBgMargin + properties.leftContentMargin + properties.rightContentMargin, 
								   theSize.height + properties.topBgMargin + properties.bottomBgMargin + properties.topContentMargin + properties.bottomContentMargin);	
		[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
		
		CGRect theFrame = CGRectOffset(CGRectUnion(bgRect, arrowRect), offset.x, offset.y);
		self.frame = theFrame;
		
		self.backgroundColor = [UIColor clearColor];
		UIImage *theImage = [UIImage imageNamed:properties.bgImageName];
		bgImage = [[theImage stretchableImageWithLeftCapWidth:properties.leftBgCapSize topCapHeight:properties.topBgCapSize] retain];

		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)dealloc {
	[contentView release];
	[bgImage release];
	[arrowImage release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[bgImage drawInRect:bgRect blendMode:kCGBlendModeNormal alpha:1.0];
	[arrowImage drawInRect:arrowRect blendMode:kCGBlendModeNormal alpha:1.0]; 
}

- (void)updatePositionWithAnchorRect:(CGRect)anchorRect 
						 displayArea:(CGRect)displayArea
			permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
	[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
	CGRect theFrame = CGRectOffset(CGRectUnion(bgRect, arrowRect), offset.x, offset.y);
	self.frame = theFrame;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return CGRectContainsPoint(self.contentRect, point);	
} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)setContentView:(UIView *)v {
	if (v != contentView) {
		[contentView release];
		contentView = [v retain];		
		contentView.frame = self.contentRect;		
		[self addSubview:contentView];
	}
}



@end

@implementation WEPopoverContainerView(Private)

- (CGSize)contentSize {
	return self.contentRect.size;
}

- (CGRect)contentRect {
	CGRect rect = CGRectMake(properties.leftBgMargin + properties.leftContentMargin, properties.topBgMargin + properties.topContentMargin, 
									bgRect.size.width - properties.leftBgMargin - properties.rightBgMargin - properties.leftContentMargin - properties.rightContentMargin,
									bgRect.size.height - properties.topBgMargin - properties.bottomBgMargin - properties.topContentMargin - properties.bottomContentMargin);
	return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)props {
	if (properties != props) {
		[properties release];
		properties = [props retain];
	}
}

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	offset =  CGPointZero;
	bgRect = CGRectZero;
	arrowRect = CGRectZero;
	arrowDirection = UIPopoverArrowDirectionUnknown;
	
	CGFloat biggestSurface = 0.0;
	
	UIImage *upArrowImage = [UIImage imageNamed:properties.upArrowImageName];
	UIImage *downArrowImage = [UIImage imageNamed:properties.downArrowImageName];
	UIImage *leftArrowImage = [UIImage imageNamed:properties.leftArrowImageName];
	UIImage *rightArrowImage = [UIImage imageNamed:properties.rightArrowImageName];
		
	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if ((supportedArrowDirections & theArrowDirection)) {
			
			CGRect theBgRect = CGRectZero;
			CGRect theArrowRect = CGRectZero;
			CGPoint theOffset = CGPointZero;
			CGFloat xArrowOffset = 0.0;
			CGFloat yArrowOffset = 0.0;
			CGPoint anchorPoint = CGPointZero;
			
			switch (theArrowDirection) {
				case UIPopoverArrowDirectionUp:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMaxY(anchorRect));
					
					xArrowOffset = theSize.width / 2 - upArrowImage.size.width / 2;
					yArrowOffset = properties.topBgMargin - upArrowImage.size.height;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - upArrowImage.size.width / 2, anchorPoint.y  - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, upArrowImage.size.width, upArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionDown:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
					
					xArrowOffset = theSize.width / 2 - downArrowImage.size.width / 2;
					yArrowOffset = theSize.height - properties.bottomBgMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - downArrowImage.size.width / 2, anchorPoint.y - yArrowOffset - downArrowImage.size.height);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					theArrowRect = CGRectMake(xArrowOffset , yArrowOffset, downArrowImage.size.width, downArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionLeft:
					
					anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = properties.leftBgMargin - leftArrowImage.size.width;
					yArrowOffset = theSize.height / 2  - leftArrowImage.size.height / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset - leftArrowImage.size.height / 2);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, leftArrowImage.size.width, leftArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionRight:
					
					anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = theSize.width - properties.rightBgMargin;
					yArrowOffset = theSize.height / 2  - rightArrowImage.size.width / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - rightArrowImage.size.width, anchorPoint.y - yArrowOffset - rightArrowImage.size.height / 2);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, rightArrowImage.size.width, rightArrowImage.size.height);
					
					break;
			}
			
			
			CGRect intersection = CGRectIntersection(displayArea, CGRectOffset(theBgRect, theOffset.x, theOffset.y));
			CGFloat surface = intersection.size.width * intersection.size.height;
			
			if (surface > biggestSurface) {
				biggestSurface = surface;
				offset = theOffset;
				arrowRect = theArrowRect;
				bgRect = theBgRect;
				arrowDirection = theArrowDirection;
			}
		}
		
		theArrowDirection <<= 1;
	}
	
	switch (arrowDirection) {
		case UIPopoverArrowDirectionUp:
			arrowImage = [upArrowImage retain];
			break;
		case UIPopoverArrowDirectionDown:
			arrowImage = [downArrowImage retain];
			break;
		case UIPopoverArrowDirectionLeft:
			arrowImage = [leftArrowImage retain];
			break;
		case UIPopoverArrowDirectionRight:
			arrowImage = [rightArrowImage retain];
			break;
	}
}

@end