//
//  VCPage.h
//  VCReader
//
//  Created by victor on 1/27/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface VCPage : NSObject

@property (strong, nonatomic) UITextView *textView;
@property (assign) long int pageNumber;
@end
