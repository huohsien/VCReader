//
//  VCTextView.m
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCTextView.h"

@implementation VCTextView

@synthesize responder = _responder;

+(void) removeAllInView:(UIView *)view {

    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:[VCTextView class]]) {
            
            VCLOG(@"found");
            [v removeFromSuperview];
            
        } else {
            
            VCLOG(@"not found");

        }
    }
}

- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    // If not dragging, send event to next responder
    if (!self.dragging)
        [_responder touchesBegan: touches withEvent:event];
    else
        [super touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // If not dragging, send event to next responder
    if (!self.dragging)
        [_responder touchesMoved: touches withEvent:event];
    else
        [super touchesMoved: touches withEvent: event];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
    // If not dragging, send event to next responder
    if (!self.dragging)
        [_responder touchesEnded: touches withEvent:event];
    else
        [super touchesEnded: touches withEvent: event];
}
@end
