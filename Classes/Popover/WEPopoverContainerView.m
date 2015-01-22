//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties {
    
}

#define IMAGE_FOR_NAME(arrowImage, arrowImageName)	((arrowImage != nil) ? (arrowImage) : (arrowImageName == nil ? nil : [UIImage imageNamed:arrowImageName]))

- (id)init {
    if ((self = [super init])) {
        self.maskInsets = CGSizeZero;
    }
    return self;
}

- (UIImage *)upArrowImage {
    return IMAGE_FOR_NAME(_upArrowImage, _upArrowImageName);
}

- (UIImage *)downArrowImage {
    return IMAGE_FOR_NAME(_downArrowImage, _downArrowImageName);
}

- (UIImage *)leftArrowImage {
    return IMAGE_FOR_NAME(_leftArrowImage, _leftArrowImageName);
}

- (UIImage *)rightArrowImage {
    return IMAGE_FOR_NAME(_rightArrowImage, _rightArrowImageName);
}

- (UIImage *)bgImage {
    return IMAGE_FOR_NAME(_bgImage, _bgImageName);
}


@end

@interface WEPopoverContainerView(Private)

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)props;
- (void)initFrame;

@end

@implementation WEPopoverContainerView {
    UIImage *_bgImage;
    UIImage *_arrowImage;
    
    WEPopoverContainerViewProperties *_properties;
    
    CGRect _arrowRect;
    CGRect _bgRect;
    CGPoint _offset;
    CGPoint _arrowOffset;
    
    CGSize _correctedSize;
    CGRect _calculatedFrame;
}

- (id)initWithSize:(CGSize)theSize
        anchorRect:(CGRect)anchorRect
       displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
        properties:(WEPopoverContainerViewProperties *)theProperties {
    if ((self = [super initWithFrame:CGRectZero])) {
        
        [self setProperties:theProperties];
        _correctedSize = CGSizeMake(theSize.width + _properties.leftBgMargin + _properties.rightBgMargin + _properties.leftContentMargin + _properties.rightContentMargin,
                                    theSize.height + _properties.topBgMargin + _properties.bottomBgMargin + _properties.topContentMargin + _properties.bottomContentMargin);
        [self determineGeometryForSize:_correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *theImage = _properties.bgImage;
        _bgImage = [theImage stretchableImageWithLeftCapWidth:_properties.leftBgCapSize topCapHeight:_properties.topBgCapSize];
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        [self initFrame];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [_bgImage drawInRect:_bgRect blendMode:kCGBlendModeNormal alpha:1.0];
    [_arrowImage drawInRect:_arrowRect blendMode:kCGBlendModeNormal alpha:1.0];
    
    BOOL shouldClip = _properties.maskCornerRadius > 0.0f || !CGSizeEqualToSize(_properties.maskInsets, CGSizeZero);
    if (shouldClip) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        
        CGFloat maskInsetWidth = MIN(_properties.maskInsets.width, self.bounds.size.width/2.0f);
        CGFloat maskInsetHeight = MIN(_properties.maskInsets.height, self.bounds.size.height/2.0f);
        CGRect insetRect = CGRectInset(self.bounds, maskInsetWidth, maskInsetHeight);
        insetRect.size.width = MAX(insetRect.size.width, 0);
        insetRect.size.height = MAX(insetRect.size.height, 0);
        
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:_properties.maskCornerRadius].CGPath;
        
        CGFloat borderWidth = _properties.maskBorderWidth;
        UIColor *borderColor = _properties.maskBorderColor;
        
        if (borderWidth > 0.0f && borderColor != nil) {
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            
            [borderLayer setPath:path];
            [borderLayer setLineWidth:borderWidth * 2.0f];
            [borderLayer setStrokeColor:borderColor.CGColor];
            [borderLayer setFillColor:[UIColor clearColor].CGColor];
            
            borderLayer.frame = self.bounds;
            [self.layer addSublayer:borderLayer];
        }
        
        [maskLayer setPath:path];
        [maskLayer setFillRule:kCAFillRuleEvenOdd];
        maskLayer.frame = self.bounds;
        [self.layer setMask:maskLayer];
    }
}

- (void)updatePositionWithSize:(CGSize)theSize
                    anchorRect:(CGRect)anchorRect
                   displayArea:(CGRect)displayArea
      permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
    
    _correctedSize = CGSizeMake(theSize.width + _properties.leftBgMargin + _properties.rightBgMargin + _properties.leftContentMargin + _properties.rightContentMargin,
                                theSize.height + _properties.topBgMargin + _properties.bottomBgMargin + _properties.topContentMargin + _properties.bottomContentMargin);
    
    [self determineGeometryForSize:_correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
    [self initFrame];
    [self setNeedsDisplay];
    
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
    if (v != _contentView) {
        _contentView = v;
        _contentView.frame = self.contentRect;
        [self addSubview:_contentView];
    }
}

- (CGRect)calculatedFrame {
    return _calculatedFrame;
}

- (void)setFrame:(CGRect)frame {
    if ([self.delegate respondsToSelector:@selector(popoverContainerView:willChangeFrame:)]) {
        frame = [self.delegate popoverContainerView:self willChangeFrame:frame];
    }
    [super setFrame:frame];
}

@end

@implementation WEPopoverContainerView(Private)

- (void)initFrame {
    CGRect theFrame = CGRectOffset(CGRectUnion(_bgRect, _arrowRect), _offset.x, _offset.y);
    
    //If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
    _arrowOffset = CGPointMake(MAX(0, -_arrowRect.origin.x), MAX(0, -_arrowRect.origin.y));
    _bgRect = CGRectOffset(_bgRect, _arrowOffset.x, _arrowOffset.y);
    _arrowRect = CGRectOffset(_arrowRect, _arrowOffset.x, _arrowOffset.y);
    _calculatedFrame = CGRectIntegral(theFrame);
}

- (CGSize)contentSize {
    return self.contentRect.size;
}

- (CGRect)contentRect {
    CGRect rect = CGRectMake(_properties.leftBgMargin + _properties.leftContentMargin + _arrowOffset.x,
                             _properties.topBgMargin + _properties.topContentMargin + _arrowOffset.y,
                             _bgRect.size.width - _properties.leftBgMargin - _properties.rightBgMargin - _properties.leftContentMargin - _properties.rightContentMargin,
                             _bgRect.size.height - _properties.topBgMargin - _properties.bottomBgMargin - _properties.topContentMargin - _properties.bottomContentMargin);
    return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)props {
    if (_properties != props) {
        _properties = props;
    }
}

- (CGRect)roundedRect:(CGRect)rect {
    return CGRectMake(roundf(rect.origin.x), roundf(rect.origin.y), roundf(rect.size.width), roundf(rect.size.height));
}

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {
    
    theSize.width = MIN(displayArea.size.width, theSize.width);
    theSize.height = MIN(displayArea.size.height, theSize.height);
    
    //Determine the frame, it should not go outside the display area
    UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
    
    _offset =  CGPointZero;
    _bgRect = CGRectZero;
    _arrowRect = CGRectZero;
    _arrowDirection = UIPopoverArrowDirectionUnknown;
    
    CGFloat biggestSurface = 0.0f;
    CGFloat currentMinMargin = 0.0f;
    
    UIImage *upArrowImage = _properties.upArrowImage;
    UIImage *downArrowImage = _properties.downArrowImage;
    UIImage *leftArrowImage = _properties.leftArrowImage;
    UIImage *rightArrowImage = _properties.rightArrowImage;
    
    while (theArrowDirection <= UIPopoverArrowDirectionRight) {
        
        if ((supportedArrowDirections & theArrowDirection)) {
            
            CGRect theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
            CGRect theArrowRect = CGRectZero;
            CGPoint theOffset = CGPointZero;
            CGFloat xArrowOffset = 0.0;
            CGFloat yArrowOffset = 0.0;
            CGPoint anchorPoint = CGPointZero;
            
            switch (theArrowDirection) {
                case UIPopoverArrowDirectionUp:
                    
                    anchorPoint = CGPointMake(CGRectGetMidX(anchorRect) - displayArea.origin.x, CGRectGetMaxY(anchorRect) - displayArea.origin.y);
                    
                    xArrowOffset = theSize.width / 2 - upArrowImage.size.width / 2;
                    yArrowOffset = _properties.topBgMargin - upArrowImage.size.height;
                    
                    theOffset = CGPointMake(anchorPoint.x - xArrowOffset - upArrowImage.size.width / 2, anchorPoint.y  - yArrowOffset);
                    
                    if (theOffset.x < 0) {
                        xArrowOffset += theOffset.x;
                        theOffset.x = 0;
                    } else if (theOffset.x + theSize.width > displayArea.size.width) {
                        xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
                        theOffset.x = displayArea.size.width - theSize.width;
                    }
                    
                    //Cap the arrow offset
                    xArrowOffset = MAX(xArrowOffset, _properties.leftBgMargin + _properties.arrowMargin);
                    xArrowOffset = MIN(xArrowOffset, theSize.width - _properties.rightBgMargin - _properties.arrowMargin - upArrowImage.size.width);
                    
                    theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, upArrowImage.size.width, upArrowImage.size.height);
                    
                    break;
                case UIPopoverArrowDirectionDown:
                    
                    anchorPoint = CGPointMake(CGRectGetMidX(anchorRect)  - displayArea.origin.x, CGRectGetMinY(anchorRect) - displayArea.origin.y);
                    
                    xArrowOffset = theSize.width / 2 - downArrowImage.size.width / 2;
                    yArrowOffset = theSize.height - _properties.bottomBgMargin;
                    
                    theOffset = CGPointMake(anchorPoint.x - xArrowOffset - downArrowImage.size.width / 2, anchorPoint.y - yArrowOffset - downArrowImage.size.height);
                    
                    if (theOffset.x < 0) {
                        xArrowOffset += theOffset.x;
                        theOffset.x = 0;
                    } else if (theOffset.x + theSize.width > displayArea.size.width) {
                        xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
                        theOffset.x = displayArea.size.width - theSize.width;
                    }
                    
                    //Cap the arrow offset
                    xArrowOffset = MAX(xArrowOffset, _properties.leftBgMargin + _properties.arrowMargin);
                    xArrowOffset = MIN(xArrowOffset, theSize.width - _properties.rightBgMargin - _properties.arrowMargin - downArrowImage.size.width);
                    
                    theArrowRect = CGRectMake(xArrowOffset , yArrowOffset, downArrowImage.size.width, downArrowImage.size.height);
                    
                    break;
                case UIPopoverArrowDirectionLeft:
                    
                    anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect) - displayArea.origin.x, CGRectGetMidY(anchorRect) - displayArea.origin.y);
                    
                    xArrowOffset = _properties.leftBgMargin - leftArrowImage.size.width;
                    yArrowOffset = theSize.height / 2  - leftArrowImage.size.height / 2;
                    
                    theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset - leftArrowImage.size.height / 2);
                    
                    if (theOffset.y < 0) {
                        yArrowOffset += theOffset.y;
                        theOffset.y = 0;
                    } else if (theOffset.y + theSize.height > displayArea.size.height) {
                        yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
                        theOffset.y = displayArea.size.height - theSize.height;
                    }
                    
                    //Cap the arrow offset
                    yArrowOffset = MAX(yArrowOffset, _properties.topBgMargin + _properties.arrowMargin);
                    yArrowOffset = MIN(yArrowOffset, theSize.height - _properties.bottomBgMargin - _properties.arrowMargin - leftArrowImage.size.height);
                    
                    theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, leftArrowImage.size.width, leftArrowImage.size.height);
                    
                    break;
                case UIPopoverArrowDirectionRight:
                    
                    anchorPoint = CGPointMake(CGRectGetMinX(anchorRect) - displayArea.origin.x, CGRectGetMidY(anchorRect) - displayArea.origin.y);
                    
                    xArrowOffset = theSize.width - _properties.rightBgMargin;
                    yArrowOffset = theSize.height / 2  - rightArrowImage.size.width / 2;
                    
                    theOffset = CGPointMake(anchorPoint.x - xArrowOffset - rightArrowImage.size.width, anchorPoint.y - yArrowOffset - rightArrowImage.size.height / 2);
                    
                    if (theOffset.y < 0) {
                        yArrowOffset += theOffset.y;
                        theOffset.y = 0;
                    } else if (theOffset.y + theSize.height > displayArea.size.height) {
                        yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
                        theOffset.y = displayArea.size.height - theSize.height;
                    }
                    
                    //Cap the arrow offset
                    yArrowOffset = MAX(yArrowOffset, _properties.topBgMargin + _properties.arrowMargin);
                    yArrowOffset = MIN(yArrowOffset, theSize.height - _properties.bottomBgMargin - _properties.arrowMargin - rightArrowImage.size.height);
                    
                    theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, rightArrowImage.size.width, rightArrowImage.size.height);
                    
                    break;
                default:
                    break;
            }
            
            CGRect bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
            
            CGFloat minMarginLeft = CGRectGetMinX(bgFrame);
            CGFloat minMarginRight = CGRectGetWidth(displayArea) - CGRectGetMaxX(bgFrame);
            CGFloat minMarginTop = CGRectGetMinY(bgFrame);
            CGFloat minMarginBottom = CGRectGetHeight(displayArea) - CGRectGetMaxY(bgFrame);
            
            BOOL adjustRightArrow = NO;
            if (minMarginLeft < 0) {
                // Popover is clipped on the left;
                // move it to the right
                theOffset.x -= minMarginLeft;
                minMarginRight += minMarginLeft;
                minMarginLeft = 0;
                adjustRightArrow = YES;
            }
            if (minMarginRight < 0) {
                theBgRect.size.width += minMarginRight;
                minMarginRight = 0;
                adjustRightArrow = YES;
            }
            
            if (adjustRightArrow && theArrowDirection == UIPopoverArrowDirectionRight) {
                theArrowRect.origin.x = CGRectGetMaxX(theBgRect) - _properties.rightBgMargin;
            }

            BOOL adjustDownArrow = NO;
            if (minMarginTop < 0) {
                // Popover is clipped at the top
                
                // Move it down
                theOffset.y -= minMarginTop;
                minMarginBottom += minMarginTop;
                minMarginTop = 0;
                adjustDownArrow = YES;
            }
            if (minMarginBottom < 0) {
                // Popover is clipped at the bottom:
                
                // Decrease the height:
                theBgRect.size.height += minMarginBottom;
                minMarginBottom = 0;
                adjustDownArrow = YES;
            }
            
            if (adjustDownArrow && theArrowDirection == UIPopoverArrowDirectionDown) {
                //Move the arrow to proper position for clipping at the bottom
                theArrowRect.origin.y = CGRectGetMaxY(theBgRect) - _properties.bottomBgMargin;
            }
            
            
            CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
            minMargin = MIN(minMargin, minMarginTop);
            minMargin = MIN(minMargin, minMarginBottom);
            
            // Calculate intersection and surface
            CGFloat surface = theBgRect.size.width * theBgRect.size.height;
            
            if (surface >= biggestSurface && minMargin >= currentMinMargin) {
                biggestSurface = surface;
                _offset = CGPointMake(roundf(theOffset.x + displayArea.origin.x), roundf(theOffset.y + displayArea.origin.y));
                _arrowRect = [self roundedRect:theArrowRect];
                _bgRect = [self roundedRect:theBgRect];
                _arrowDirection = theArrowDirection;
                currentMinMargin = minMargin;
            }
        }
        
        theArrowDirection <<= 1;
    }
    
    switch (_arrowDirection) {
        case UIPopoverArrowDirectionUp:
            _arrowImage = upArrowImage;
            break;
        case UIPopoverArrowDirectionDown:
            _arrowImage = downArrowImage;
            break;
        case UIPopoverArrowDirectionLeft:
            _arrowImage = leftArrowImage;
            break;
        case UIPopoverArrowDirectionRight:
            _arrowImage = rightArrowImage;
            break;
        default:
            break;
    }
}

@end