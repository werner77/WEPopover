//
//  WETouchDownGestureRecognizer.m
//  WEPopover
//
//  Created by Werner Altewischer on 18/09/14.
//  Copyright (c) 2014 Werner IT Consultancy. All rights reserved.
//

#import "WETouchDownGestureRecognizer.h"

@implementation WETouchDownGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateRecognized;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateFailed;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateFailed;
}

@end
