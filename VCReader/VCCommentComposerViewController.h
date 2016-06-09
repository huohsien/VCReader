//
//  VCCommentComposerViewController.h
//  VCReader
//
//  Created by victor on 6/4/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface VCCommentComposerViewController : UIViewController<NSURLConnectionDataDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
