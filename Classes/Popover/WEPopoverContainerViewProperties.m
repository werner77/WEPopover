//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 19/11/15.
//  Copyright © 2015 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerViewProperties.h"

@implementation WEPopoverContainerViewProperties {
    
}

#define IMAGE_FOR_NAME(arrowImage, arrowImageName)	((arrowImage != nil) ? (arrowImage) : (arrowImageName == nil ? nil : [UIImage imageNamed:arrowImageName]))

- (id)init {
    if ((self = [super init])) {
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
