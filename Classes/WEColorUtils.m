//
//  WEColorUtils.m
//  WEPopover
//
//  Created by Werner Altewischer on 19/02/16.
//  Copyright © 2016 Werner IT Consultancy. All rights reserved.
//

#import "WEColorUtils.h"

@implementation WEColorUtils

UIColor *UIColorMakeRGB8(CGFloat red, CGFloat green, CGFloat blue)
{
    return UIColorMakeRGB8Alpha(red, green, blue, 1.0);
}

UIColor *UIColorMakeRGB8Alpha(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
    return [UIColor colorWithRed:red / 255. green:green / 255. blue:blue / 255. alpha:alpha];
}

UIColor *UIColorMakeHex(NSInteger hex)
{
    return UIColorMakeHexAlpha(hex, 1.0);
}

UIColor *UIColorMakeHex32(NSInteger hex)
{
    CGFloat red = (CGFloat)((hex & 0xFF000000) >> 24);
    CGFloat green = (CGFloat)((hex & 0xFF0000) >> 16);
    CGFloat blue = (CGFloat)((hex & 0xFF00) >> 8);
    CGFloat alpha = (CGFloat)(hex & 0xFF);
    
    return UIColorMakeRGB8Alpha(red, green, blue, alpha);
}

UIColor *UIColorMakeHexAlpha(NSInteger hex, CGFloat alpha)
{
    CGFloat red = (CGFloat)((hex & 0xFF0000) >> 16);
    CGFloat green = (CGFloat)((hex & 0xFF00) >> 8);
    CGFloat blue = (CGFloat)(hex & 0xFF);
    
    return UIColorMakeRGB8Alpha(red, green, blue, alpha);
}

@end
