//
//  WEColorUtils.h
//  WEPopover
//
//  Created by Werner Altewischer on 19/02/16.
//  Copyright © 2016 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WEColorUtils : NSObject


UIColor *UIColorMakeRGB8(CGFloat red, CGFloat green, CGFloat blue);
UIColor *UIColorMakeRGB8Alpha(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
UIColor *UIColorMakeHex(NSInteger hex);
UIColor *UIColorMakeHex32(NSInteger hex);
UIColor *UIColorMakeHexAlpha(NSInteger hex, CGFloat alpha);

@end
