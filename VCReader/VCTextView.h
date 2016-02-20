//
//  VCTextView.h
//  VCReader
//
//  Created by victor on 1/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCTextView : UITextView

@property (strong, nonatomic) UIResponder *responder;

+(void) removeAllInView:(UIView *)view;

@end
